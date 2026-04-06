import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/auth_session.dart';
import '../models/marketplace_product.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

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
  Future<Map<String, dynamic>> register({
    required String role,
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String phone,
    String? storeName,
    String? contactPhone,
    String? description,
  }) async {
    late final String path;
    late final Map<String, dynamic> body;

    if (role == 'customer') {
      path = '/api/public-auth/register/customer';
      body = {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'phone': phone,
      };
    } else if (role == 'seller') {
      path = '/api/public-auth/register/seller';
      body = {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'phone': phone,
        'storeName': storeName ?? '',
        'contactPhone': contactPhone ?? '',
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
  }

  return payload;
}

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

  return AuthSession.fromJson(payload);
}

String _resolveUserRole(Map<String, dynamic> mePayload) {
  final role = mePayload['role'];

  if (role is Map<String, dynamic>) {
    final candidates = <dynamic>[
      role['type'],
      role['name'],
      role['code'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim().toLowerCase() ?? '';
      if (value.isNotEmpty) {
        if (value.contains('delivery')) return 'delivery';
        if (value.contains('seller')) return 'seller';
        if (value.contains('customer')) return 'customer';
        if (value.contains('operations')) return 'operations';
      }
    }
  }

  final seller = mePayload['seller'];
  if (seller is Map<String, dynamic> && seller.isNotEmpty) {
    return 'seller';
  }

  return 'customer';
}

String _resolveDisplayName(
  Map<String, dynamic> loginUser,
  Map<String, dynamic> mePayload,
) {
  final candidates = <dynamic>[
    mePayload['firstName'],
    loginUser['firstName'],
    loginUser['username'],
    mePayload['username'],
    loginUser['email'],
  ];

  for (final candidate in candidates) {
    final text = candidate?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
  }

  return 'Usuario';
}

  Future<List<MarketplaceProduct>> fetchMarketplaceProducts({
    required String authToken,
    return payload is Map<String, dynamic> ? payload : <String, dynamic>{};
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

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final payload = await postJson(
      '/api/auth/local',
      body: {
        'identifier': identifier,
        'password': password,
      },
    );

    return AuthSession.fromJson(payload);
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
      if (name.isEmpty) {
        continue;
      }

      final price = _asDouble(item['price']);
      final category = _extractRelationName(item['category'], fallback: 'Sin categoria');
      final sellerName = _extractRelationName(item['seller'], fallback: 'Sin vendedor');
      final key = name.toLowerCase();

      final group = grouped.putIfAbsent(
        key,
        () => _GroupedProduct(
          name: name,
          categoryName: category,
          visual: _iconFor(category, name),
        ),
      );

      group.prices.add(price);
      group.sellers.add(sellerName);
    }

    return grouped.values.map((group) {
      group.prices.sort();
      final hasRange = group.prices.isNotEmpty && group.prices.first != group.prices.last;
      final priceDisplay = group.prices.isEmpty
          ? 'Sin precio'
          : hasRange
              ? '\$${group.prices.first.toStringAsFixed(0)} - \$${group.prices.last.toStringAsFixed(0)}'
              : '\$${group.prices.first.toStringAsFixed(0)}';

      return MarketplaceProduct(
        unitPrice: group.prices.isEmpty ? 0 : group.prices.first,
        name: group.name,
        categoryName: group.categoryName,
        priceDisplay: priceDisplay,
        sellerCount: group.sellers.length,
        visual: group.visual,
      );
    }).toList();
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
        _extractErrorMessage(payload, fallback: 'La solicitud no pudo completarse.'),
      );
    }

    return payload;
  }

  String _extractErrorMessage(dynamic payload, {required String fallback}) {
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

  String _iconFor(String category, String productName) {
    final normalized = '$category $productName'.toLowerCase();

    if (normalized.contains('tomate')) return 'T';
    if (normalized.contains('zanahoria') || normalized.contains('carrot')) return 'Z';
    if (normalized.contains('cebolla') || normalized.contains('onion')) return 'C';
    if (normalized.contains('brocoli') || normalized.contains('broccoli')) return 'B';
    if (normalized.contains('lechuga') || normalized.contains('lettuce')) return 'L';
    if (normalized.contains('platano') || normalized.contains('banana')) return 'P';
    if (normalized.contains('mango')) return 'M';
    if (normalized.contains('manzana') || normalized.contains('apple')) return 'A';
    if (normalized.contains('pera') || normalized.contains('pear')) return 'R';
    if (normalized.contains('fresa') || normalized.contains('strawberry')) return 'F';
    if (normalized.contains('fruta')) return 'F';
    if (normalized.contains('verdura') || normalized.contains('vegetal')) return 'V';

    return '*';
  }

  String resolveMediaUrl(String rawUrl) {
    final normalized = rawUrl.trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
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
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _GroupedProduct {
  _GroupedProduct({
    required this.name,
    required this.categoryName,
    required this.visual,
  });

  final String name;
  final String categoryName;
  final String visual;
  final List<double> prices = <double>[];
  final Set<String> sellers = <String>{};
}