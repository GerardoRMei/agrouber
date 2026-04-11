import 'dart:convert';

import 'package:agrouber/models/product_unit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/address_draft.dart';
import '../models/auth_session.dart';
import '../models/marketplace_product.dart';
import '../models/order_summary.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  String get apiBaseUrl =>
      dotenv.env['API_BASE_URL']?.trim().isNotEmpty == true
          ? dotenv.env['API_BASE_URL']!.trim()
          : 'http://localhost:1337';

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final base = Uri.parse(apiBaseUrl);
    return base.replace(
      path: '${base.path}$path',
      queryParameters: queryParameters,
    );
  }


  String _asString(dynamic value) => (value ?? '').toString().trim();

  Map<String, dynamic> normalizeEditableProfile(Map<String, dynamic> payload) {
    return {
      'id': payload['id'],
      'username': _asString(payload['username']),
      'email': _asString(payload['email']),
      'phone': _asString(payload['phone']),
    };
  }
  Future<Map<String, dynamic>> register({
    required String role,
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String phone,
    String? customerAddress,
    AddressDraft? customerAddressDraft,
    String? storeName,
    String? contactPhone,
    String? businessAddress,
    AddressDraft? businessAddressDraft,
    String? description,
  }) async {
    late final String path;
    late final Map<String, dynamic> body;

    if (role == 'customer') {
      final normalizedCustomerAddress = _resolveRegisterAddressString(
        draft: customerAddressDraft,
        fallback: customerAddress,
      );
      path = '/api/public-auth/register/customer';
      body = {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'phone': phone,
        if (normalizedCustomerAddress != null) 'address': normalizedCustomerAddress,
      };
    } else if (role == 'seller') {
      final normalizedBusinessAddress = _resolveRegisterAddressString(
        draft: businessAddressDraft,
        fallback: businessAddress,
      );
      path = '/api/public-auth/register/seller';
      body = {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'phone': phone,
        'storeName': storeName ?? '',
        'contactPhone': contactPhone ?? '',
        if (normalizedBusinessAddress != null) 'businessAddress': normalizedBusinessAddress,
        if (businessAddressDraft != null) 'address': _buildSellerAddressPayload(businessAddressDraft),
        'description': description ?? '',
      };
    } else {
      throw const ApiException('Unsupported role for public registration.');
    }

    final response = await _httpClient.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );

    final payload = _decodeBody(response.body);

    if (response.statusCode >= 400) {
      throw ApiException(
        _extractErrorMessage(
          payload,
          fallback: 'No se pudo registrar el usuario.',
        ),
      );
    }

    final data = payload is Map<String, dynamic> ? payload : <String, dynamic>{};

    final shouldSaveCustomerAddress = role == 'customer' &&
        customerAddressDraft != null &&
        customerAddressDraft.hasRequiredFields;
    final shouldSyncSellerAddress = role == 'seller' &&
        businessAddressDraft != null &&
        businessAddressDraft.hasRequiredFields;

    if (shouldSaveCustomerAddress || shouldSyncSellerAddress) {
      var authJwt = (data['jwt'] ?? '').toString().trim();
      final user = data['user'];
      var authUserId = user is Map<String, dynamic> ? _extractInt(user['id']) : null;

      if (authJwt.isEmpty || (shouldSaveCustomerAddress && authUserId == null)) {
        try {
          final session = await login(
            identifier: email,
            password: password,
          );
          authJwt = session.jwt;
          authUserId ??= session.userId;
        } catch (_) {
          // Se mantiene el flujo base de registro; abajo se valida solo lo necesario.
        }
      }

      if (shouldSaveCustomerAddress) {
        if (authJwt.isEmpty || authUserId == null) {
          throw const ApiException(
            'La cuenta se creo, pero no se pudo autenticar para guardar la direccion.',
          );
        }
        try {
          await createMyAddress(
            authToken: authJwt,
            userId: authUserId!,
            draft: customerAddressDraft!,
          );
          data['addressSaved'] = true;
        } catch (error) {
          throw ApiException(
            'La cuenta se creo, pero no se pudo guardar la direccion: $error',
          );
        }
      }

      if (shouldSyncSellerAddress && authJwt.isNotEmpty) {
        try {
          await patchDynamic(
            '/api/sellers/me/profile',
            authToken: authJwt,
            body: <String, dynamic>{
              'address': _buildSellerAddressPayload(businessAddressDraft!),
            },
          );
          data['sellerAddressSaved'] = true;
        } catch (_) {
          // Ya se envio address en el registro; este patch es respaldo.
        }
      }
    }

    return data;
  }

  /// Se conserva el endpoint custom actual porque lo usan para resolver
  /// el rol y redirigir a la pantalla correcta después del login.
  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/public-auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    final payload = _decodeBody(response.body);

    if (response.statusCode >= 400) {
      throw ApiException(
        _extractErrorMessage(
          payload,
          fallback: 'No se pudo iniciar sesión.',
        ),
      );
    }

    if (payload is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inválida del servidor.');
    }

    return AuthSession.fromJson(payload);
  }

    Future<Map<String, dynamic>> getMyProfile({
    required String authToken,
  }) async {
    final payload = await getJson(
      '/api/users/me',
      authToken: authToken,
    );

    return normalizeEditableProfile(payload);
  }

  Future<Map<String, dynamic>> updateMyBasicProfile({
    required String authToken,
    required int userId,
    required String username,
    required String email,
    required String phone,
  }) async {
    final payload = await putJson(
      '/api/users/$userId',
      authToken: authToken,
      body: {
        'username': username.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
      },
    );
    

    return normalizeEditableProfile({
      'id': payload['id'] ?? userId,
      'username': payload['username'] ?? username,
      'email': payload['email'] ?? email,
      'phone': payload['phone'] ?? phone,
    });
  }
  

  Future<List<MarketplaceProduct>> fetchMarketplaceProducts({
    required String authToken,
  }) async {
    final payload = await getJson(
      '/api/products',
      authToken: authToken,
      queryParameters: const {
        'filters[isActive][\$eq]': 'true',
        'populate[0]': 'category',
        'populate[1]': 'seller',
        'populate[2]': 'images',
        'sort': 'name:asc',
        'pagination[page]': '1',
        'pagination[pageSize]': '100',
      },
    );

    final items = (payload['data'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>();

    final grouped = <String, _GroupedProduct>{};

    for (final item in items) {
      final name = (item['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;

      final price = _asDouble(item['price']);
      final category = _extractRelationName(item['category'], fallback: 'Sin categoria');
      final sellerName = _extractRelationName(item['seller'], fallback: 'Sin vendedor');
      final productId = _extractInt(item['id']);
      final sellerId = item['seller'] is Map<String, dynamic>
          ? _extractInt((item['seller'] as Map<String, dynamic>)['id'])
          : null;
      final productVisual = _extractProductVisual(item, category, name);
      
      final unitString = (item['unit'] ?? '').toString();
      final unitEnum = ProductUnit.fromString(unitString);
      
      final key = '${name.toLowerCase()}_${unitEnum.name}';

      final group = grouped.putIfAbsent(
        key,
        () => _GroupedProduct(
          name: name,
          categoryName: category,
          visual: productVisual,
          unit: unitEnum,
        ),
      );

      if (!group.visual.startsWith('http') && productVisual.startsWith('http')) {
        group.visual = productVisual;
      }

      group.options.add(
        ProductOption(
          sellerName: sellerName,
          price: price,
          productId: productId ?? 0,
          sellerId: sellerId,
        ),
      );
    }

    return grouped.values.map((group) {
      group.options.sort((a, b) => a.price.compareTo(b.price));

      final hasRange = group.options.isNotEmpty && 
                       group.options.first.price != group.options.last.price;

      final priceDisplay = group.options.isEmpty
          ? 'Sin precio'
          : hasRange
              ? '\$${group.options.first.price.toStringAsFixed(0)} - \$${group.options.last.price.toStringAsFixed(0)} ${group.unit.suffix}'
              : '\$${group.options.first.price.toStringAsFixed(0)} ${group.unit.suffix}';

      final uniqueSellers = group.options.map((o) => o.sellerName).toSet().length;

      return MarketplaceProduct(
        name: group.name,
        categoryName: group.categoryName,
        priceDisplay: priceDisplay,
        sellerCount: uniqueSellers,
        visual: group.visual,
        options: group.options,
        unit: group.unit,
      );
    }).toList();
  }

  Future<void> changeMyPassword({
    required String authToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    await postDynamic(
      '/api/auth/change-password',
      authToken: authToken,
      body: {
        'currentPassword': currentPassword,
        'password': newPassword,
        'passwordConfirmation': newPassword,
      },
    );
  }

  Future<List<OrderSummary>> fetchCustomerOrders({
    required String authToken,
    required int userId,
  }) async {
    final attempts = <Future<dynamic> Function()>[
      () => getDynamic('/api/orders/my', authToken: authToken),
      () => getDynamic('/api/customers/me/orders', authToken: authToken),
      () => getDynamic(
            '/api/orders',
            authToken: authToken,
            queryParameters: <String, String>{
              'filters[customer][id][\$eq]': '$userId',
              'populate[0]': 'seller',
              'populate[1]': 'adress',
              'populate[items][populate][0]': 'product',
              'populate[items][populate][1]': 'seller',
              'sort': 'createdAt:desc',
              'pagination[pageSize]': '100',
            },
          ),
      () => getDynamic(
            '/api/orders',
            authToken: authToken,
            queryParameters: <String, String>{
              'filters[customer][users_permissions_user][id][\$eq]': '$userId',
              'populate[0]': 'seller',
              'populate[1]': 'adress',
              'populate[items][populate][0]': 'product',
              'populate[items][populate][1]': 'seller',
              'sort': 'createdAt:desc',
              'pagination[pageSize]': '100',
            },
          ),
    ];

    dynamic payload;
    Object? lastError;

    for (final attempt in attempts) {
      try {
        payload = await attempt();
        break;
      } catch (error) {
        lastError = error;
      }
    }

    if (payload == null) {
      throw lastError is Exception
          ? lastError
          : const ApiException('No se pudo cargar el historial de ordenes.');
    }

    final items = _normalizeCollection(payload);
    return items
        .map((item) => OrderSummary.fromJson(item, forSeller: false))
        .toList();
  }

  Future<List<OrderSummary>> fetchSellerOrders({
    required String authToken,
    required int sellerUserId,
  }) async {
    final attempts = <Future<dynamic> Function()>[
      () => getDynamic('/api/sellers/orders', authToken: authToken),
      () => getDynamic('/api/orders/seller', authToken: authToken),
      () => getDynamic(
            '/api/orders',
            authToken: authToken,
            queryParameters: <String, String>{
              'filters[seller][users_permissions_user][id][\$eq]': '$sellerUserId',
              'populate[0]': 'customer',
              'populate[1]': 'adress',
              'populate[items][populate][0]': 'product',
              'populate[items][populate][1]': 'seller',
              'sort': 'createdAt:desc',
              'pagination[pageSize]': '100',
            },
          ),
      () => getDynamic(
            '/api/orders',
            authToken: authToken,
            queryParameters: <String, String>{
              'filters[seller][id][\$eq]': '$sellerUserId',
              'populate[1]': 'customer',
              'populate[2]': 'adress',
              'populate[items][populate][0]': 'product',
              'populate[items][populate][1]': 'seller',
              'sort': 'createdAt:desc',
              'pagination[pageSize]': '100',
            },
          ),
    ];

    dynamic payload;
    Object? lastError;

    for (final attempt in attempts) {
      try {
        payload = await attempt();
        break;
      } catch (error) {
        lastError = error;
      }
    }

    if (payload == null) {
      throw lastError is Exception
          ? lastError
          : const ApiException('No se pudieron cargar las ventas.');
    }

    final items = _normalizeCollection(payload);
    return items
        .map((item) => OrderSummary.fromJson(item, forSeller: true))
        .toList();
  }

  Future<int?> fetchMyAddressId({
    required String authToken,
  }) async {
    final addresses = await fetchMyAddresses(
      authToken: authToken,
    );
    if (addresses.isEmpty) return null;
    return addresses.first['id'] as int?;
  }

  Future<String?> fetchMyAddressLabel({
    required String authToken,
  }) async {
    final addresses = await fetchMyAddresses(
      authToken: authToken,
    );
    if (addresses.isEmpty) return null;
    return (addresses.first['displayLabel'] ?? addresses.first['label'])
        ?.toString();
  }

  Future<List<Map<String, dynamic>>> fetchMyAddresses({
    required String authToken,
  }) async {
    final payload = await getDynamic(
      '/api/adress/me',
      authToken: authToken,
    );
    final items = _normalizeCollection(payload);

    if (items.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    return items
        .map(_normalizeAddressRecord)
        .where((item) => (item['id'] as int?) != null)
        .toList();
  }

  Future<void> upsertMyAddress({
    required String authToken,
    required int userId,
    required String address,
  }) async {
    final normalized = address.trim();
    if (normalized.isEmpty) return;

    final draft = tryParseSerializedAddress(normalized) ??
        AddressDraft.fromLegacyLabel(normalized);

    final existing = await fetchMyAddresses(
      authToken: authToken,
    );

    if (existing.isNotEmpty) {
      final first = existing.first;
      await updateMyAddress(
        authToken: authToken,
        userId: userId,
        addressId: first['id'] as int?,
        addressDocumentId: first['documentId']?.toString(),
        draft: draft,
      );
      return;
    }

    await createMyAddress(
      authToken: authToken,
      userId: userId,
      draft: draft,
    );
  }

  Future<String?> createMyAddress({
    required String authToken,
    required int userId,
    required AddressDraft draft,
  }) async {
    Object? lastError;
    final relationKeys = <String?>[
      'customer',
      'users_permissions_user',
      'user',
      null,
    ];

    for (final relationKey in relationKeys) {
      try {
        final payload = await postDynamic(
          '/api/adress',
          authToken: authToken,
          body: _buildAddressCreateOrUpdateBody(
            draft,
            userId: userId,
            relationKey: relationKey,
          ),
        );
        return _extractDocumentIdFromPayload(payload);
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError is Exception) {
      throw lastError;
    }

    throw const ApiException('No se pudo crear la direccion.');
  }

  Future<void> updateMyAddress({
    required String authToken,
    required int userId,
    int? addressId,
    String? addressDocumentId,
    required AddressDraft draft,
  }) async {
    final resolvedDocumentId = _normalizeDocumentId(addressDocumentId) ??
        await _findAddressDocumentId(
          authToken: authToken,
          addressId: addressId,
        );

    if (resolvedDocumentId == null) {
      throw const ApiException(
        'No se encontro documentId de la direccion para actualizar.',
      );
    }

    Object? lastError;
    final relationKeys = <String?>[
      null,
      'customer',
      'users_permissions_user',
      'user',
    ];

    for (final relationKey in relationKeys) {
      try {
        await putDynamic(
          '/api/adress/$addressId',
          authToken: authToken,
          body: _buildAddressCreateOrUpdateBody(
            draft,
            userId: userId,
            relationKey: relationKey,
          ),
        );
        return;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError is Exception) {
      throw lastError;
    }

    throw const ApiException('No se pudo actualizar la direccion.');
  }

  Future<void> deleteMyAddress({
    required String authToken,
    required int userId,
    int? addressId,
    String? addressDocumentId,
  }) async {
    await deleteDynamic(
      '/api/adress/$addressId',
      authToken: authToken,
    );
  }

  String? _normalizeDocumentId(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  Future<String?> _findAddressDocumentId({
    required String authToken,
    int? addressId,
  }) async {
    if (addressId == null) return null;
    final addresses = await fetchMyAddresses(
      authToken: authToken,
    );
    for (final address in addresses) {
      if (address['id'] == addressId) {
        return _normalizeDocumentId(address['documentId']?.toString());
      }
    }
    return null;
  }

  Map<String, dynamic> _buildAddressCreateOrUpdateBody(
    AddressDraft draft, {
    required int userId,
    String? relationKey,
  }) {
    final data = <String, dynamic>{
      'label': draft.normalizedAlias,
      'recipientName': draft.fullName.trim(),
      'phone': draft.phone.trim(),
      'street': draft.street.trim(),
      'externalNumber': draft.extNumber.trim(),
      'neighborhood': draft.neighborhood.trim(),
      'city': draft.city.trim(),
      'state': draft.state.trim(),
      'zipCode': draft.postalCode.trim(),
      'references': draft.references.trim(),
      
    };

    if (relationKey != null && relationKey.trim().isNotEmpty) {
      data[relationKey] = userId;
    }

    final internal = draft.intNumber.trim();
    if (internal.isNotEmpty) {
      data['internalNumber'] = internal;
    }

    return <String, dynamic>{'data': data};
  }

  String? _extractDocumentIdFromPayload(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return null;
    }
    final directDoc = payload['documentId']?.toString().trim();
    if (directDoc != null && directDoc.isNotEmpty) {
      return directDoc;
    }
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      final nestedDoc = data['documentId']?.toString().trim();
      if (nestedDoc != null && nestedDoc.isNotEmpty) {
        return nestedDoc;
      }
    }
    return null;
  }

  Map<String, dynamic> _normalizeAddressRecord(Map<String, dynamic> source) {
    return <String, dynamic>{
      'id': _extractInt(source['id']),
      'documentId': source['documentId']?.toString(),
      'label': (source['label'] ?? '').toString(),
      'displayLabel': _extractAddressLabel(source) ?? '',
      'recipientName': (source['recipientName'] ?? '').toString(),
      'phone': (source['phone'] ?? '').toString(),
      'street': (source['street'] ?? source['addressLine1'] ?? '').toString(),
      'externalNumber': (source['externalNumber'] ?? '').toString(),
      'internalNumber': (source['internalNumber'] ?? '').toString(),
      'neighborhood': (source['neighborhood'] ?? '').toString(),
      'city': (source['city'] ?? '').toString(),
      'state': (source['state'] ?? '').toString(),
      'zipCode': (source['zipCode'] ?? source['postalCode'] ?? '').toString(),
      'references': (source['references'] ?? '').toString(),
    };
  }

  Future<Map<String, dynamic>> checkoutOrder({
    required String authToken,
    required int adressId,
    required List<Map<String, dynamic>> items,
    required double deliveryFee,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'adressId': adressId,
      'deliveryFee': deliveryFee,
      'items': items,
    };

    if (notes != null && notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }

    final payload = await postDynamic(
      '/api/orders/checkout',
      authToken: authToken,
      body: body,
    );

    return payload is Map<String, dynamic> ? payload : <String, dynamic>{};
  }

  String? _resolveRegisterAddressString({
    required AddressDraft? draft,
    required String? fallback,
  }) {
    final fallbackValue = fallback?.trim() ?? '';
    if (draft == null) {
      return fallbackValue.isEmpty ? null : fallbackValue;
    }

    final primary = '${draft.street.trim()} ${draft.extNumber.trim()}'.trim();
    final secondary = <String>[
      if (draft.intNumber.trim().isNotEmpty) 'Int ${draft.intNumber.trim()}',
      draft.neighborhood.trim(),
      draft.city.trim(),
      draft.state.trim(),
      if (draft.postalCode.trim().isNotEmpty) 'CP ${draft.postalCode.trim()}',
    ].where((value) => value.isNotEmpty).join(', ');
    final contact = <String>[
      draft.fullName.trim(),
      draft.phone.trim(),
    ].where((value) => value.isNotEmpty).join(' / ');

    final composed = <String>[
      if (primary.isNotEmpty) primary,
      if (secondary.isNotEmpty) secondary,
      if (contact.isNotEmpty) 'Contacto: $contact',
    ].join(' | ').trim();

    if (composed.isNotEmpty) {
      return composed;
    }

    return fallbackValue.isEmpty ? null : fallbackValue;
  }

  Map<String, dynamic> _buildSellerAddressPayload(AddressDraft draft) {
    final line1 = '${draft.street.trim()} ${draft.extNumber.trim()}'.trim();
    final line2 = <String>[
      if (draft.intNumber.trim().isNotEmpty) 'Int ${draft.intNumber.trim()}',
      draft.neighborhood.trim(),
    ].where((value) => value.isNotEmpty).join(', ');

    return <String, dynamic>{
      'addressLine1': line1,
      if (line2.isNotEmpty) 'addressLine2': line2,
      'city': draft.city.trim(),
      'state': draft.state.trim(),
      'postalCode': draft.postalCode.trim(),
      if (draft.references.trim().isNotEmpty) 'reference': draft.references.trim(),
    };
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    String? authToken,
  }) async {
    final payload = await getDynamic(
      path,
      queryParameters: queryParameters,
      authToken: authToken,
    );

    return payload is Map<String, dynamic> ? payload : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final payload = await postDynamic(
      path,
      body: body,
      authToken: authToken,
    );

    return payload is Map<String, dynamic> ? payload : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final payload = await patchDynamic(
      path,
      body: body,
      authToken: authToken,
    );

    return payload is Map<String, dynamic> ? payload : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final payload = await putDynamic(
      path,
      body: body,
      authToken: authToken,
    );

    return payload is Map<String, dynamic> ? payload : <String, dynamic>{};
  }

  Future<dynamic> getDynamic(
    String path, {
    Map<String, String>? queryParameters,
    String? authToken,
  }) async {
    final response = await _httpClient.get(
      _uri(path, queryParameters),
      headers: _headers(authToken: authToken),
    );

    return _handleDynamicResponse(response);
  }

  Future<dynamic> postDynamic(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final response = await _httpClient.post(
      _uri(path),
      headers: _headers(authToken: authToken),
      body: jsonEncode(body),
    );

    return _handleDynamicResponse(response);
  }

  Future<dynamic> patchDynamic(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final response = await _httpClient.patch(
      _uri(path),
      headers: _headers(authToken: authToken),
      body: jsonEncode(body),
    );

    return _handleDynamicResponse(response);
  }

  Future<dynamic> putDynamic(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final response = await _httpClient.put(
      _uri(path),
      headers: _headers(authToken: authToken),
      body: jsonEncode(body),
    );

    return _handleDynamicResponse(response);
  }

  Future<dynamic> deleteDynamic(
    String path, {
    String? authToken,
  }) async {
    final response = await _httpClient.delete(
      _uri(path),
      headers: _headers(authToken: authToken),
    );

    return _handleDynamicResponse(response);
  }

  Future<List<Map<String, dynamic>>> uploadFiles(
    String path, {
    required List<XFile> files,
    String fieldName = 'files',
    String? authToken,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));

    if (authToken != null && authToken.trim().isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $authToken';
    }

    for (final file in files) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: file.name,
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final payload = _handleDynamicResponse(response);

    if (payload is List<dynamic>) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }

    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List<dynamic>) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }

    return <Map<String, dynamic>>[];
  }

  String resolveMediaUrl(String rawUrl) {
    final normalized = rawUrl.trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    if (normalized.startsWith('http://') ||
        normalized.startsWith('https://')) {
      return normalized;
    }

    final base = Uri.parse(apiBaseUrl);
    final origin = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
    );

    return origin.resolve(normalized).toString();
  }

  Map<String, String> _headers({String? authToken}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (authToken != null && authToken.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(body);
  }

  dynamic _handleDynamicResponse(http.Response response) {
    final payload = _decodeBody(response.body);

    if (response.statusCode >= 400) {
      throw ApiException(
        _extractErrorMessage(
          payload,
          fallback: 'La solicitud no pudo completarse.',
        ),
      );
    }

    return payload;
  }

  String _extractErrorMessage(
    dynamic payload, {
    required String fallback,
  }) {
    if (payload is! Map<String, dynamic>) {
      return fallback;
    }

    final error = payload['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    final message = payload['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }

    return fallback;
  }

  String _extractRelationName(dynamic relation, {required String fallback}) {
    if (relation is Map<String, dynamic>) {
      final name = relation['name'] ?? relation['storeName'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    return fallback;
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _extractInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  List<Map<String, dynamic>> _normalizeCollection(dynamic payload) {
    if (payload is List<dynamic>) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }

    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List<dynamic>) {
        return data.whereType<Map<String, dynamic>>().toList();
      }

      final items = payload['items'];
      if (items is List<dynamic>) {
        return items.whereType<Map<String, dynamic>>().toList();
      }
    }

    return <Map<String, dynamic>>[];
  }

  String _iconFor(String category, String productName) {
    final normalized = '$category $productName'.toLowerCase();

    if (normalized.contains('tomate')) return 'T';
    if (normalized.contains('zanahoria') || normalized.contains('carrot')) {
      return 'Z';
    }
    if (normalized.contains('cebolla') || normalized.contains('onion')) {
      return 'C';
    }
    if (normalized.contains('brocoli') || normalized.contains('broccoli')) {
      return 'B';
    }
    if (normalized.contains('lechuga') || normalized.contains('lettuce')) {
      return 'L';
    }
    if (normalized.contains('platano') || normalized.contains('banana')) {
      return 'P';
    }
    if (normalized.contains('mango')) return 'M';
    if (normalized.contains('manzana') || normalized.contains('apple')) {
      return 'A';
    }
    if (normalized.contains('pera') || normalized.contains('pear')) return 'R';
    if (normalized.contains('fresa') || normalized.contains('strawberry')) {
      return 'F';
    }
    if (normalized.contains('fruta')) return 'F';
    if (normalized.contains('verdura') || normalized.contains('vegetal')) {
      return 'V';
    }

    return '*';
  }

  String? _extractAddressLabel(Map<String, dynamic> source) {
    final direct = <dynamic>[
      source['street'],
      source['address'],
      source['addressLine1'],
      source['fullAddress'],
      source['label'],
    ];

    for (final candidate in direct) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    final parts = <String>[
      (source['addressLine1'] ?? '').toString().trim(),
      (source['addressLine2'] ?? '').toString().trim(),
      (source['neighborhood'] ?? '').toString().trim(),
      (source['city'] ?? '').toString().trim(),
      (source['state'] ?? '').toString().trim(),
      (source['zipCode'] ?? '').toString().trim(),
      (source['postalCode'] ?? '').toString().trim(),
    ].where((p) => p.isNotEmpty).toList();

    if (parts.isEmpty) {
      return null;
    }

    return parts.join(', ');
  }

  String _extractProductVisual(
    Map<String, dynamic> source,
    String category,
    String productName,
  ) {
    final images = source['images'];
    final mediaUrl = _extractFirstMediaUrl(images);
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      return resolveMediaUrl(mediaUrl);
    }
    return _iconFor(category, productName);
  }

  String? _extractFirstMediaUrl(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List<dynamic> && data.isNotEmpty) {
        final first = data.first;
        if (first is Map<String, dynamic>) {
          final attributes =
              first['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
          final source = attributes.isNotEmpty ? attributes : first;
          final url = source['url']?.toString().trim() ?? '';
          return url.isEmpty ? null : url;
        }
      }
      if (data is Map<String, dynamic>) {
        final attributes =
            data['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final source = attributes.isNotEmpty ? attributes : data;
        final url = source['url']?.toString().trim() ?? '';
        return url.isEmpty ? null : url;
      }
    }

    if (raw is List<dynamic> && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map<String, dynamic>) {
        final attributes =
            first['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final source = attributes.isNotEmpty ? attributes : first;
        final url = source['url']?.toString().trim() ?? '';
        return url.isEmpty ? null : url;
      }
    }

    return null;
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _GroupedProduct {
  final String name;
  final String categoryName;
  String visual;
  final ProductUnit unit;
  final List<ProductOption> options = [];

  _GroupedProduct({
    required this.name,
    required this.categoryName,
    required this.visual,
    required this.unit,
  });
}
