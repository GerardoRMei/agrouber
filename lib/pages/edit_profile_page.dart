import 'package:flutter/material.dart';
import '../models/auth_session.dart';

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

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(
      text: widget.session.displayName,
    );
    _usernameCtrl = TextEditingController(
      text: widget.session.displayName.replaceAll(' ', '').toLowerCase(),
    );
    _emailCtrl = TextEditingController(
      text: widget.session.email,
    );
    _phoneCtrl = TextEditingController(
      text: '',
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado localmente (placeholder).'),
      ),
    );

    Navigator.pop(context);
  }

  void _changePhotoPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aquí luego abrirás image_picker o selección de foto.'),
      ),
    );
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
        child: SingleChildScrollView(
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
                          'Pantalla placeholder lista para conectarse después al backend.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6E6259),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 46,
                                backgroundColor: Color(0xFFD8D2C8),
                                child: Icon(
                                  Icons.person,
                                  size: 46,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _changePhotoPlaceholder,
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text('Cambiar foto'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFE09A2C),
                                  side: const BorderSide(
                                    color: Color(0xFFE09A2C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        _ProfileField(
                          label: 'Nombre',
                          controller: _firstNameCtrl,
                          hint: 'Gerardo',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),

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
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1F1209),
                                  side: const BorderSide(
                                    color: Color(0xFFB9B0A7),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE09A2C),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Guardar cambios'),
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