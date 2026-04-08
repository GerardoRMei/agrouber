import 'package:flutter/material.dart';
import '../models/auth_session.dart';
import '../data/api_client.dart';

class ChangePasswordPage extends StatefulWidget {
  final AuthSession session;
  final VoidCallback? onPasswordChanged;

  const ChangePasswordPage({super.key, required this.session, this.onPasswordChanged});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _savePassword() {
    if (!_formKey.currentState!.validate()) return;

    if(_currentPasswordCtrl.text.trim() == _newPasswordCtrl.text.trim()){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña nueva no puede ser igual a la actual.'),
        ),
      );
      return;
    }

    

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña actualizada.'),
      ),
    );

    Navigator.pop(context);
  }

  int get _passwordStrength {
    final password = _newPasswordCtrl.text.trim();
    int score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\[\]~`]').hasMatch(password)) {
      score++;
    }

    return score.clamp(0, 4);
  }

  String get _passwordHint {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return 'Contraseña débil';
      case 2:
        return 'Contraseña aceptable';
      case 3:
        return 'Contraseña buena';
      case 4:
        return 'Contraseña fuerte';
      default:
        return '';
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
          'Cambiar contraseña',
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
                          'Seguridad de la cuenta',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1209),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Placeholder listo para conectarse después al endpoint real.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6E6259),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _PasswordField(
                          label: 'Contraseña actual',
                          controller: _currentPasswordCtrl,
                          obscureText: _hideCurrent,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu contraseña actual';
                            }
                            return null;
                          },
                          onToggleVisibility: () {
                            setState(() {
                              _hideCurrent = !_hideCurrent;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        _PasswordField(
                          label: 'Nueva contraseña',
                          controller: _newPasswordCtrl,
                          obscureText: _hideNew,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa una nueva contraseña';
                            }
                            if (value.trim().length < 8) {
                              return 'Debe tener al menos 8 caracteres';
                            }
                            return null;
                          },
                          onToggleVisibility: () {
                            setState(() {
                              _hideNew = !_hideNew;
                            });
                          },
                        ),

                        const SizedBox(height: 8),
                        _PasswordStrengthBar(strength: _passwordStrength),
                        const SizedBox(height: 6),
                        Text(
                          _passwordHint,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6E6259),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _PasswordField(
                          label: 'Confirmar nueva contraseña',
                          controller: _confirmPasswordCtrl,
                          obscureText: _hideConfirm,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Confirma tu nueva contraseña';
                            }
                            if (value.trim() != _newPasswordCtrl.text.trim()) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                          onToggleVisibility: () {
                            setState(() {
                              _hideConfirm = !_hideConfirm;
                            });
                          },
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
                                onPressed: _savePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE09A2C),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Actualizar'),
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
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
    this.onChanged,
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
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
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

class _PasswordStrengthBar extends StatelessWidget {
  final int strength;

  const _PasswordStrengthBar({
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final active = index < strength;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
            height: 8,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFE09A2C)
                  : const Color(0xFFD8D2C8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}