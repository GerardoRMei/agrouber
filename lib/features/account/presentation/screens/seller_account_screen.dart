import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/services/media_api_service.dart';
import '../../../../shared/theme/agrorun_theme.dart';
import '../../../auth/models/auth_session.dart';
import '../../../seller/models/seller_profile.dart';
import '../../../seller/services/seller_api_service.dart';
import '../../models/account_profile.dart';
import '../../services/account_api_service.dart';
import '../widgets/account_components.dart';

class SellerAccountScreen extends StatefulWidget {
  const SellerAccountScreen({
    super.key,
    required this.session,
    required this.onSessionChanged,
    required this.onLogout,
  });

  final AuthSession session;
  final ValueChanged<AuthSession> onSessionChanged;
  final VoidCallback onLogout;

  @override
  State<SellerAccountScreen> createState() => _SellerAccountScreenState();
}

class _SellerAccountScreenState extends State<SellerAccountScreen> {
  final AccountApiService _accountApiService = AccountApiService();
  final MediaApiService _mediaApiService = MediaApiService();
  final SellerApiService _sellerApiService = SellerApiService();
  final ImagePicker _imagePicker = ImagePicker();

  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _sellerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  AccountProfile? _accountProfile;
  SellerProfile? _sellerProfile;
  Uint8List? _localAvatarBytes;
  bool _isLoading = true;
  bool _isSavingUser = false;
  bool _isSavingSeller = false;
  bool _isUploadingAvatar = false;
  bool _isChangingPassword = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _contactPhoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _referenceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _accountApiService.fetchProfile(widget.session),
        _sellerApiService.fetchSellerStatus(widget.session),
        _sellerApiService.fetchSellerDashboard(widget.session),
        _sellerApiService.fetchWarehouseAssignment(widget.session),
      ]);

      if (!mounted) {
        return;
      }

      final account = results[0] as AccountProfile;
      final seller = (results[1] as SellerProfile)
          .copyWith(
            productCount: (results[2] as SellerProfile).productCount,
            canCreateProducts: (results[2] as SellerProfile).canCreateProducts,
            canDeliverToWarehouse:
                (results[2] as SellerProfile).canDeliverToWarehouse,
            canEditProfile: (results[2] as SellerProfile).canEditProfile,
          )
          .copyWith(
            assignedWarehouse: (results[3] as SellerProfile).assignedWarehouse,
            warehouseAssignmentStatus:
                (results[3] as SellerProfile).warehouseAssignmentStatus,
            deliveryInstructions:
                (results[3] as SellerProfile).deliveryInstructions,
          );

      _applyAccount(account);
      _applySeller(seller);
      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos cargar tu cuenta de vendedor.';
        _isLoading = false;
      });
    }
  }

  void _applyAccount(AccountProfile profile) {
    _accountProfile = profile;
    _firstNameController.text = profile.firstName ?? '';
    _usernameController.text = profile.username;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';
    _localAvatarBytes = null;
    widget.onSessionChanged(profile.toSession(widget.session));
  }

  void _applySeller(SellerProfile profile) {
    _sellerProfile = profile;
    _storeNameController.text = profile.storeName;
    _contactPhoneController.text = profile.contactPhone ?? '';
    _addressLine1Controller.text = profile.address?.addressLine1 ?? '';
    _addressLine2Controller.text = profile.address?.addressLine2 ?? '';
    _cityController.text = profile.address?.city ?? '';
    _stateController.text = profile.address?.state ?? '';
    _postalCodeController.text = profile.address?.postalCode ?? '';
    _referenceController.text = profile.address?.reference ?? '';
  }

  Future<void> _pickAvatar() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1400,
    );

    if (image == null || !mounted) {
      return;
    }

    final bytes = await image.readAsBytes();
    setState(() {
      _localAvatarBytes = bytes;
      _isUploadingAvatar = true;
      _errorMessage = null;
    });

    try {
      final media = await _mediaApiService.uploadSingleImage(
        session: widget.session,
        file: image,
      );
      final updated = await _accountApiService.updateProfile(
        session: widget.session,
        firstName: _firstNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImageId: media.id,
      );

      if (!mounted) {
        return;
      }

      _applyAccount(updated);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu foto de perfil se actualizo.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _localAvatarBytes = null;
        _errorMessage = 'No pudimos subir la imagen.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  Future<void> _saveUserProfile() async {
    if (!_userFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSavingUser = true;
      _errorMessage = null;
    });

    try {
      final updated = await _accountApiService.updateProfile(
        session: widget.session,
        firstName: _firstNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImageId: _accountProfile?.profileImage?.id,
      );

      if (!mounted) {
        return;
      }

      _applyAccount(updated);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualizamos tu informacion personal.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos actualizar tu perfil.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSavingUser = false;
        });
      }
    }
  }

  Future<void> _saveSellerProfile() async {
    if (!_sellerFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSavingSeller = true;
      _errorMessage = null;
    });

    try {
      final updated = await _sellerApiService.updateSellerProfile(
        session: widget.session,
        storeName: _storeNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        reference: _referenceController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      _applySeller(updated);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualizamos la informacion de tu tienda.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos actualizar la informacion de tu tienda.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSavingSeller = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isChangingPassword = true;
      _errorMessage = null;
    });

    try {
      await _accountApiService.changePassword(
        session: widget.session,
        password: _passwordController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      _passwordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu contrasena se actualizo.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos cambiar tu contrasena.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  void _logout() {
    widget.onLogout();
  }

  String? _required(String? value, String label) {
    if ((value ?? '').trim().isEmpty) {
      return '$label es requerido';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Tu correo es requerido';
    }
    if (!normalized.contains('@') || !normalized.contains('.')) {
      return 'Ingresa un correo valido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final seller = _sellerProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta de vendedor')),
      backgroundColor: AgrorunPalette.cream,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AgrorunPalette.forest),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  AccountHeroCard(
                    title: seller?.storeName.isNotEmpty == true
                        ? seller!.storeName
                        : 'Tu tienda',
                    subtitle:
                        'Mantén actualizada tu informacion comercial, el estado de tu cuenta y la operacion de tu tienda en Agrorun.',
                    child: ProfileAvatarEditor(
                      name: _accountProfile?.displayName ?? widget.session.displayName,
                      media: _accountProfile?.profileImage,
                      localPreviewBytes: _localAvatarBytes,
                      isUploading: _isUploadingAvatar,
                      onTap: _pickAvatar,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    InlineErrorCard(message: _errorMessage!),
                  ],
                  const SizedBox(height: 18),
                  AccountSectionCard(
                    title: 'Datos personales',
                    subtitle:
                        'Estos datos identifican a la persona responsable de tu cuenta.',
                    child: Form(
                      key: _userFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            validator: (value) => _required(value, 'Tu nombre'),
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            validator: (value) =>
                                _required(value, 'Tu nombre de usuario'),
                            decoration: const InputDecoration(
                              labelText: 'Nombre de usuario',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _emailValidator,
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) => _required(value, 'Tu telefono'),
                            decoration: const InputDecoration(
                              labelText: 'Telefono',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isSavingUser ? null : _saveUserProfile,
                              child: _isSavingUser
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Guardar datos personales'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AccountSectionCard(
                    title: 'Datos de tu tienda',
                    subtitle:
                        'Aquí vive la información operativa que revisa el equipo antes de habilitar tu operacion.',
                    child: Form(
                      key: _sellerFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _storeNameController,
                            validator: (value) =>
                                _required(value, 'El nombre de tu tienda'),
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la tienda',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contactPhoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                _required(value, 'El telefono comercial'),
                            decoration: const InputDecoration(
                              labelText: 'Telefono comercial',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressLine1Controller,
                            validator: (value) =>
                                _required(value, 'La direccion principal'),
                            decoration: const InputDecoration(
                              labelText: 'Direccion principal',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressLine2Controller,
                            decoration: const InputDecoration(
                              labelText: 'Direccion adicional',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cityController,
                            validator: (value) => _required(value, 'La ciudad'),
                            decoration: const InputDecoration(
                              labelText: 'Ciudad',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _stateController,
                            validator: (value) => _required(value, 'El estado'),
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _postalCodeController,
                            validator: (value) => _required(value, 'El codigo postal'),
                            decoration: const InputDecoration(
                              labelText: 'Codigo postal',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _referenceController,
                            decoration: const InputDecoration(
                              labelText: 'Referencia',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed:
                                  _isSavingSeller || seller?.canEditProfile == false
                                      ? null
                                      : _saveSellerProfile,
                              child: _isSavingSeller
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Guardar informacion de tienda'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AccountSectionCard(
                    title: 'Estado de tu operacion',
                    subtitle:
                        'Consulta el avance de tu cuenta, tu almacen asignado y las instrucciones que siguen para operar.',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        InfoPill(
                          icon: Icons.verified_user_outlined,
                          label: 'Cuenta ${seller?.status.name ?? 'sin registro'}',
                        ),
                        InfoPill(
                          icon: Icons.inventory_2_outlined,
                          label:
                              '${seller?.productCount ?? 0} producto${(seller?.productCount ?? 0) == 1 ? '' : 's'}',
                        ),
                        InfoPill(
                          icon: Icons.warehouse_outlined,
                          label: seller?.assignedWarehouse?.name ?? 'Almacen pendiente',
                        ),
                        if ((seller?.deliveryInstructions ?? '').isNotEmpty)
                          InfoPill(
                            icon: Icons.local_shipping_outlined,
                            label: seller!.deliveryInstructions!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AccountSectionCard(
                    title: 'Seguridad',
                    subtitle:
                        'Refuerza el acceso a tu cuenta cambiando tu contrasena cuando lo necesites.',
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (value) {
                              final normalized = value?.trim() ?? '';
                              if (normalized.isEmpty) {
                                return 'Escribe una contrasena nueva';
                              }
                              if (normalized.length < 6) {
                                return 'Tu contrasena debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Nueva contrasena',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Confirma tu contrasena nueva';
                              }
                              if (value!.trim() != _passwordController.text.trim()) {
                                return 'Las contrasenas no coinciden';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Confirmar contrasena',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed:
                                  _isChangingPassword ? null : _changePassword,
                              child: _isChangingPassword
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AgrorunPalette.forest,
                                      ),
                                    )
                                  : const Text('Actualizar contrasena'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AccountSectionCard(
                    title: 'Sesion',
                    subtitle:
                        'Cuando termines de revisar tu informacion, puedes cerrar sesion de forma segura.',
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Cerrar sesion'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
