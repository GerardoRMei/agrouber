import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/services/media_api_service.dart';
import '../../../../shared/theme/agrorun_theme.dart';
import '../../../auth/models/auth_session.dart';
import '../../models/account_profile.dart';
import '../../services/account_api_service.dart';
import '../widgets/account_components.dart';

class CustomerAccountScreen extends StatefulWidget {
  const CustomerAccountScreen({
    super.key,
    required this.session,
    required this.onSessionChanged,
    required this.onLogout,
  });

  final AuthSession session;
  final ValueChanged<AuthSession> onSessionChanged;
  final VoidCallback onLogout;

  @override
  State<CustomerAccountScreen> createState() => _CustomerAccountScreenState();
}

class _CustomerAccountScreenState extends State<CustomerAccountScreen> {
  final AccountApiService _accountApiService = AccountApiService();
  final MediaApiService _mediaApiService = MediaApiService();
  final ImagePicker _imagePicker = ImagePicker();

  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  AccountProfile? _profile;
  Uint8List? _localAvatarBytes;
  bool _isLoading = true;
  bool _isSavingProfile = false;
  bool _isChangingPassword = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _accountApiService.fetchProfile(widget.session);
      if (!mounted) {
        return;
      }
      _applyProfile(profile);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'No pudimos cargar tu informacion.';
        _isLoading = false;
      });
    }
  }

  void _applyProfile(AccountProfile profile) {
    _profile = profile;
    _firstNameController.text = profile.firstName ?? '';
    _usernameController.text = profile.username;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';
    _localAvatarBytes = null;
    widget.onSessionChanged(profile.toSession(widget.session));
    setState(() {
      _isLoading = false;
      _errorMessage = null;
    });
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

      _applyProfile(updated);
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

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSavingProfile = true;
      _errorMessage = null;
    });

    try {
      final updated = await _accountApiService.updateProfile(
        session: widget.session,
        firstName: _firstNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImageId: _profile?.profileImage?.id,
      );

      if (!mounted) {
        return;
      }

      _applyProfile(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualizamos tu perfil.')),
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
          _isSavingProfile = false;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      backgroundColor: AgrorunPalette.cream,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AgrorunPalette.forest),
            )
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  AccountHeroCard(
                    title: 'Tu cuenta',
                    subtitle:
                        'Administra tus datos personales, protege el acceso a tu cuenta y mantente al dia con tu perfil.',
                    child: ProfileAvatarEditor(
                      name: _profile?.displayName ?? widget.session.displayName,
                      media: _profile?.profileImage,
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
                        'Mantén actualizada la información con la que operas dentro de Agrorun.',
                    child: Form(
                      key: _profileFormKey,
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
                              onPressed: _isSavingProfile ? null : _saveProfile,
                              child: _isSavingProfile
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Guardar cambios'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AccountSectionCard(
                    title: 'Seguridad',
                    subtitle:
                        'Actualiza tu contrasena cuando necesites reforzar la seguridad de tu cuenta.',
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
                        'Cuando termines, puedes cerrar sesion de forma segura en este dispositivo.',
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
