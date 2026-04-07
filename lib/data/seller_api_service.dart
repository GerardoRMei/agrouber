import '../models/auth_session.dart';
import '../models/seller_category.dart';
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
