import 'package:flutter/material.dart';

import '../../auth/models/auth_session.dart';
import '../models/seller_profile.dart';
import '../models/seller_registration_request.dart';
import '../services/seller_api_service.dart';

enum SellerFlowStep {
  intro,
  form,
  status,
}

class SellerFlowController extends ChangeNotifier {
  SellerFlowController({
    SellerApiService? sellerApiService,
    AuthSession? initialSession,
  })  : _sellerApiService = sellerApiService ?? SellerApiService(),
        _authSession = initialSession;

  final SellerApiService _sellerApiService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _statusHint;
  AuthSession? _authSession;
  SellerProfile? _sellerProfile;
  SellerFlowStep _currentStep = SellerFlowStep.intro;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get statusHint => _statusHint;
  AuthSession? get authSession => _authSession;
  SellerProfile? get sellerProfile => _sellerProfile;
  SellerFlowStep get currentStep => _currentStep;

  bool get canRefreshStatus => _authSession != null;

  void goToStep(SellerFlowStep step) {
    _currentStep = step;
    _errorMessage = null;
    notifyListeners();
  }

  void attachSession(AuthSession session) {
    _authSession = session;
    notifyListeners();
  }

  Future<bool> submitRegistration(SellerRegistrationRequest request) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final profile = await _sellerApiService.registerSeller(request);
      _sellerProfile = profile;
      _statusHint = profile.message ??
          'Tu solicitud fue enviada correctamente. Inicia sesion mas tarde para consultar cualquier cambio.';
      _currentStep = SellerFlowStep.status;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshStatus() async {
    if (_authSession == null) {
      _errorMessage =
          'Necesitas iniciar sesion para consultar el estado mas reciente.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final results = await Future.wait<SellerProfile>([
        _sellerApiService.fetchSellerStatus(_authSession!),
        _sellerApiService.fetchSellerDashboard(_authSession!),
        _sellerApiService.fetchWarehouseAssignment(_authSession!),
      ]);
      final productsCount = await _sellerApiService.fetchMyProductsCount(_authSession!);

      final profile = results[0]
          .copyWith(
            productCount: results[1].productCount ?? productsCount,
            canCreateProducts: results[1].canCreateProducts,
            canDeliverToWarehouse: results[1].canDeliverToWarehouse,
            canEditProfile: results[1].canEditProfile,
          )
          .copyWith(
            assignedWarehouse: results[2].assignedWarehouse,
            warehouseAssignmentStatus: results[2].warehouseAssignmentStatus,
            deliveryInstructions: results[2].deliveryInstructions,
          );

      if (!profile.hasData) {
        _statusHint =
            'Tu cuenta existe, pero todavia no encontramos una solicitud de vendedor asociada.';
      } else {
        _statusHint = profile.deliveryInstructions ??
            'Actualizamos la informacion mas reciente de tu cuenta.';
      }
      _sellerProfile = profile;
      _currentStep = SellerFlowStep.status;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
