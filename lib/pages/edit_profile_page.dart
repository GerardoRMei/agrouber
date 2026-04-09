import 'package:flutter/material.dart';
import '../models/auth_session.dart';
import '../data/api_client.dart';

class EditProfilePage extends StatefulWidget {
  final AuthSession session;

  const EditProfilePage({
    super.key,
    required this.session,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController(text: widget.session.email);
    _phoneCtrl = TextEditingController();

    _loadProfile();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final me = await _apiClient.getMyProfile(
        authToken: widget.session.jwt,
      );

      if (!mounted) return;

      _usernameCtrl.text = (me['username'] ?? '').toString();
      _emailCtrl.text = (me['email'] ?? widget.session.email).toString();
      _phoneCtrl.text = (me['phone'] ?? '').toString();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cargar el perfil: $e'),
        ),
      );

      _usernameCtrl.text = widget.session.displayName
          .replaceAll(' ', '')
          .toLowerCase();
      _emailCtrl.text = widget.session.email;
      _phoneCtrl.text = '';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _apiClient.updateMyBasicProfile(
        authToken: widget.session.jwt,
        userId: widget.session.userId,
        username: _usernameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar el perfil: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1EA),
        elevation: 0,
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: Color(0xFF1F1209),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F1209)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Card(
                      color: const Color(0xFFF3F0EA),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información del usuario',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F1209),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Edita únicamente username, correo y teléfono.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6E6259),
                                ),
                              ),
                              const SizedBox(height: 24),

                              const Center(
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: Color(0xFFD8D2C8),
                                  child: Icon(
                                    Icons.person,
                                    size: 46,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              _ProfileField(
                                label: 'Username',
                                controller: _usernameCtrl,
                                hint: 'gerardozepeda',
                                validator: _requiredValidator,
                              ),
                              const SizedBox(height: 16),

                              _ProfileField(
                                label: 'Correo electrónico',
                                controller: _emailCtrl,
                                hint: 'correo@ejemplo.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: _emailValidator,
                              ),
                              const SizedBox(height: 16),

                              _ProfileField(
                                label: 'Teléfono',
                                controller: _phoneCtrl,
                                hint: '+52 449 000 0000',
                                keyboardType: TextInputType.phone,
                                validator: _phoneValidator,
                              ),

                              const SizedBox(height: 28),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _isSaving
                                          ? null
                                          : () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFF1F1209),
                                        side: const BorderSide(
                                          color: Color(0xFFB9B0A7),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: const Text('Cancelar'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          _isSaving ? null : _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFE09A2C),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: Text(
                                        _isSaving
                                            ? 'Guardando...'
                                            : 'Guardar cambios',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final email = value.trim();
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!regex.hasMatch(email)) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final phone = value.trim();
    final regex = RegExp(r'^[0-9+\-\s()]+$');

    if (!regex.hasMatch(phone)) {
      return 'Ingresa un teléfono válido';
    }

    return null;
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: Color(0xFF1F1209),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD8D2C8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD8D2C8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE09A2C)),
            ),
          ),
        ),
      ],
    );
  }
}