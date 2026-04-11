import 'package:image_picker/image_picker.dart';

import '../models/auth_session.dart';
import '../models/seller_category.dart';
import '../models/order_summary.dart';
import '../models/seller_sales_metrics.dart';
import '../models/seller_product.dart';
import '../models/seller_product_request.dart';
import '../models/seller_profile.dart';
import 'api_client.dart';

class SellerApiService {
  SellerApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<SellerProfile> fetchSellerStatus(AuthSession session) async {
    final response = await _apiClient.getJson(
      '/api/sellers/me',
      authToken: session.jwt,
    );

    return SellerProfile.fromMeResponse(response);
  }

  Future<SellerProfile> fetchSellerDashboard(AuthSession session) async {
    final response = await _apiClient.getJson(
      '/api/sellers/me/dashboard',
      authToken: session.jwt,
    );

    return SellerProfile.fromDashboardResponse(response);
  }

  Future<SellerProfile> fetchWarehouseAssignment(AuthSession session) async {
    final response = await _apiClient.getJson(
      '/api/sellers/warehouse-assignment',
      authToken: session.jwt,
    );

    return SellerProfile.fromWarehouseAssignmentResponse(response);
  }

  Future<List<SellerProduct>> fetchMyProducts(AuthSession session) async {
    final response = await _apiClient.getDynamic(
      '/api/sellers/products',
      authToken: session.jwt,
    );

    final items = _normalizeItems(response);
    return items.map(SellerProduct.fromJson).toList();
  }

  Future<int> fetchMyProductsCount(AuthSession session) async {
    final response = await _apiClient.getDynamic(
      '/api/sellers/products',
      authToken: session.jwt,
    );

    if (response is Map<String, dynamic>) {
      final meta = response['meta'];
      if (meta is Map<String, dynamic>) {
        final total = meta['total'];
        if (total is num) {
          return total.toInt();
        }
      }
    }

    return _normalizeItems(response).length;
  }

  Future<List<SellerCategory>> fetchCategories(AuthSession session) async {
    final response = await _apiClient.getJson(
      '/api/categories',
      authToken: session.jwt,
      queryParameters: const {
        'sort': 'name:asc',
        'pagination[pageSize]': '100',
      },
    );

    final items = (response['data'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>();
    return items.map(SellerCategory.fromStrapi).toList();
  }

  Future<SellerProduct> createProduct({
    required AuthSession session,
    required SellerProductRequest request,
  }) async {
    final response = await _apiClient.postDynamic(
      '/api/sellers/products',
      authToken: session.jwt,
      body: request.toJson(),
    );

    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return SellerProduct.fromJson(data);
      }

      return SellerProduct.fromJson(response);
    }

    throw const ApiException('No se pudo interpretar la respuesta del producto.');
  }

  Future<int> uploadProductImage({
    required AuthSession session,
    required XFile image,
  }) async {
    final uploaded = await _apiClient.uploadFiles(
      '/api/upload',
      authToken: session.jwt,
      files: <XFile>[image],
    );

    if (uploaded.isEmpty) {
      throw const ApiException('No se pudo subir la imagen del producto.');
    }

    final imageId = (uploaded.first['id'] as num?)?.toInt();
    if (imageId == null || imageId <= 0) {
      throw const ApiException('El servidor no devolvio un id de imagen valido.');
    }

    return imageId;
  }

  Future<List<OrderSummary>> fetchMySales(AuthSession session) {
    return _apiClient.fetchSellerOrders(
      authToken: session.jwt,
      sellerUserId: session.userId,
    );
  }

  Future<SellerSalesMetrics> fetchSalesMetrics(
    AuthSession session, {
    required String from,
    required String to,
  }) async {
    final response = await _apiClient.getJson(
      '/api/sellers/me/sales-metrics',
      authToken: session.jwt,
      queryParameters: <String, String>{
        'from': from,
        'to': to,
      },
    );

    return SellerSalesMetrics.fromJson(response);
  }

  Future<void> requestProductDeactivation({
    required AuthSession session,
    required int productId,
  }) async {
    Object? lastError;

    final attempts = <Future<dynamic> Function()>[
      () => _apiClient.postDynamic(
            '/api/sellers/products/$productId/deactivation-request',
            authToken: session.jwt,
            body: const <String, dynamic>{},
          ),
      () => _apiClient.postDynamic(
            '/api/sellers/products/$productId/request-deactivation',
            authToken: session.jwt,
            body: const <String, dynamic>{},
          ),
      () => _apiClient.patchDynamic(
            '/api/sellers/products/$productId',
            authToken: session.jwt,
            body: const <String, dynamic>{
              'isActive': false,
              'deactivationRequested': true,
            },
          ),
    ];

    for (final attempt in attempts) {
      try {
        await attempt();
        return;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError is Exception) {
      throw lastError;
    }
    throw const ApiException('No se pudo solicitar la baja del producto.');
  }

  List<Map<String, dynamic>> _normalizeItems(dynamic response) {
    if (response is List<dynamic>) {
      return response.whereType<Map<String, dynamic>>().toList();
    }

    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List<dynamic>) {
        return data.whereType<Map<String, dynamic>>().toList();
      }

      final items = response['items'];
      if (items is List<dynamic>) {
        return items.whereType<Map<String, dynamic>>().toList();
      }
    }

    return <Map<String, dynamic>>[];
  }
}
