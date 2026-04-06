import 'package:flutter/material.dart';

import '../../../../shared/theme/agrorun_theme.dart';
import '../../../../shared/validators/app_validators.dart';
import '../../controllers/seller_flow_controller.dart';
import '../../models/seller_registration_request.dart';
import 'seller_status_screen.dart';

class SellerProfileFormScreen extends StatefulWidget {
  const SellerProfileFormScreen({
    super.key,
    required this.controller,
  });

  final SellerFlowController controller;

  @override
  State<SellerProfileFormScreen> createState() => _SellerProfileFormScreenState();
}

class _SellerProfileFormScreenState extends State<SellerProfileFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    widget.controller.goToStep(SellerFlowStep.form);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = SellerRegistrationRequest(
      firstName: _firstNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      storeName: _storeNameController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    final success = await widget.controller.submitRegistration(request);
    if (!mounted || !success) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SellerStatusScreen(
          controller: widget.controller,
          title: 'Estado de tu solicitud',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de vendedor')),
      backgroundColor: AgrorunPalette.cream,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(
                      title: 'Crea tu perfil comercial',
                      description:
                          'Completa tu informacion principal para enviar tu solicitud. Nos enfocamos en lo necesario para activarte rapido.',
                    ),
                    if (widget.controller.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _InlineError(message: widget.controller.errorMessage!),
                    ],
                    const SizedBox(height: 18),
                    const _SectionHeader(
                      title: 'Datos de la cuenta',
                      subtitle: 'Esta informacion nos ayuda a identificarte y mantener segura tu cuenta.',
                    ),
                    const SizedBox(height: 12),
                    _FormCard(
                      child: Column(
                        children: [
                          _buildField(
                            controller: _firstNameController,
                            label: 'Nombre completo',
                            hintText: 'Ej. Raymondo Muñoz',
                            validator: (value) => AppValidators.requiredField(
                              value,
                              label: 'El nombre completo',
                            ),
                          ),
                          _buildField(
                            controller: _usernameController,
                            label: 'Nombre de usuario',
                            hintText: 'Ej. campo_lindo',
                            validator: (value) => AppValidators.minLength(
                              value,
                              label: 'El nombre de usuario',
                              min: 3,
                            ),
                          ),
                          _buildField(
                            controller: _emailController,
                            label: 'Correo electronico',
                            hintText: 'tu@negocio.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: AppValidators.email,
                          ),
                          _buildField(
                            controller: _passwordController,
                            label: 'Contrasena',
                            hintText: 'Minimo 6 caracteres',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            validator: (value) => AppValidators.minLength(
                              value,
                              label: 'La contrasena',
                              min: 6,
                            ),
                          ),
                          _buildField(
                            controller: _phoneController,
                            label: 'Telefono personal',
                            hintText: 'Numero del responsable',
                            keyboardType: TextInputType.phone,
                            validator: (value) => AppValidators.requiredField(
                              value,
                              label: 'El telefono personal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SectionHeader(
                      title: 'Informacion de tu tienda',
                      subtitle: 'Estos datos se usan para identificar tu negocio y dar seguimiento a la solicitud.',
                    ),
                    const SizedBox(height: 12),
                    _FormCard(
                      child: Column(
                        children: [
                          _buildField(
                            controller: _storeNameController,
                            label: 'Nombre de la tienda',
                            hintText: 'Como quieres que se conozca tu negocio',
                            validator: (value) => AppValidators.requiredField(
                              value,
                              label: 'El nombre de la tienda',
                            ),
                          ),
                          _buildField(
                            controller: _contactPhoneController,
                            label: 'Telefono de contacto',
                            hintText: 'Si es distinto al personal, agregalo aqui',
                            keyboardType: TextInputType.phone,
                          ),
                          _buildField(
                            controller: _descriptionController,
                            label: 'Descripcion del negocio',
                            hintText: 'Que vendes, zona de operacion o tipo de productos',
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.controller.isLoading ? null : _submit,
                        child: widget.controller.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Enviar solicitud'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? Function(String?)? validator,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AgrorunPalette.forestDark,
            AgrorunPalette.forest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.storefront_rounded, color: Colors.white, size: 30),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFE6F0E7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AgrorunPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AgrorunPalette.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3B19F)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF8A2E1B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
