import 'package:flutter/material.dart';

import '../../auth/models/auth_session.dart';
import '../models/seller_category.dart';
import '../models/seller_product.dart';
import '../models/seller_product_request.dart';
import '../services/seller_api_service.dart';

class SellerProductsController extends ChangeNotifier {
  SellerProductsController({
    required AuthSession session,
    SellerApiService? sellerApiService,
  })  : _session = session,
        _sellerApiService = sellerApiService ?? SellerApiService();

  final AuthSession _session;
  final SellerApiService _sellerApiService;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<SellerProduct> _products = <SellerProduct>[];
  List<SellerCategory> _categories = <SellerCategory>[];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<SellerProduct> get products => _products;
  List<SellerCategory> get categories => _categories;
  AuthSession get session => _session;

  void _replaceProduct(SellerProduct updated) {
    _products = _products
        .map((product) => product.id == updated.id ? updated : product)
        .toList();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _sellerApiService.fetchMyProducts(_session);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _sellerApiService.fetchCategories(_session);
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<bool> createProduct(SellerProductRequest request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _sellerApiService.createProduct(
        session: _session,
        request: request,
      );
      _products = <SellerProduct>[created, ..._products];
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> toggleActive(SellerProduct product) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _sellerApiService.toggleProductActive(
        session: _session,
        productId: product.id,
      );
      _replaceProduct(updated);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required int productId,
    required SellerProductRequest request,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _sellerApiService.updateProduct(
        session: _session,
        productId: productId,
        request: request,
      );
      _replaceProduct(updated);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
