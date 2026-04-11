import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/api_client.dart';
import '../models/address_draft.dart';
import 'address_form_sheet.dart';
import 'register_form.dart';

class RegisterFormSection extends StatefulWidget {
  final bool isMobile;
  final VoidCallback onBackToLogin;

  const RegisterFormSection({
    super.key,
    this.isMobile = false,
    required this.onBackToLogin,
  });

  @override
  State<RegisterFormSection> createState() => _RegisterFormSectionState();
}

class _RegisterFormSectionState extends State<RegisterFormSection> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _storeNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  final ApiClient _apiClient = ApiClient();

  AddressDraft? _customerAddressDraft;
  AddressDraft? _sellerBusinessAddressDraft;

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = true;
  RegisterRole _selectedRole = RegisterRole.buyer;

  bool get _isSeller => _selectedRole == RegisterRole.producer;
  bool get isMobile => widget.isMobile;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _storeNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  int get _passwordStrength {
    final password = _passwordCtrl.text.trim();
    var score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\\[\]~`]').hasMatch(password)) {
      score++;
    }

    return score.clamp(0, 4);
  }

  String get _passwordHint {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return 'Contrasena debil - usa mas caracteres';
      case 2:
        return 'Fuerza media - agrega numeros para fortalecer';
      case 3:
        return 'Fuerza media - agrega simbolos para fortalecer';
      case 4:
        return 'Contrasena fuerte';
      default:
        return '';
    }
  }

  void _onRoleSelected(RegisterRole role) {
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _openCustomerAddressForm() async {
    final draft = await showAddressFormSheet(
      context,
      title: 'Domicilio del cliente',
      submitLabel: 'Guardar domicilio',
      initial: _customerAddressDraft ?? AddressDraft.empty(),
    );

    if (draft == null || !draft.hasRequiredFields) return;
    setState(() => _customerAddressDraft = draft);
  }

  Future<void> _openSellerAddressForm() async {
    final draft = await showAddressFormSheet(
      context,
      title: 'Domicilio del negocio',
      submitLabel: 'Guardar domicilio',
      initial: _sellerBusinessAddressDraft ?? AddressDraft.empty(),
    );

    if (draft == null || !draft.hasRequiredFields) return;
    setState(() => _sellerBusinessAddressDraft = draft);
  }

  String _formatAddressForRegister(AddressDraft draft) {
    final primary = '${draft.street.trim()} ${draft.extNumber.trim()}'.trim();
    final secondaryParts = <String>[
      if (draft.intNumber.trim().isNotEmpty) 'Int ${draft.intNumber.trim()}',
      draft.neighborhood.trim(),
      draft.city.trim(),
      draft.state.trim(),
      if (draft.postalCode.trim().isNotEmpty) 'CP ${draft.postalCode.trim()}',
    ].where((value) => value.isNotEmpty).join(', ');

    final contact = <String>[
      draft.fullName.trim(),
      draft.phone.trim(),
    ].where((value) => value.isNotEmpty).join(' / ');

    final parts = <String>[
      if (primary.isNotEmpty) primary,
      if (secondaryParts.isNotEmpty) secondaryParts,
      if (contact.isNotEmpty) 'Contacto: $contact',
    ];

    return parts.join(' | ');
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los terminos para continuar.')),
      );
      return;
    }

    if (_selectedRole == RegisterRole.rider) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El registro publico para repartidores no esta disponible aun.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (!_isSeller && (_customerAddressDraft == null || !_customerAddressDraft!.hasRequiredFields)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Captura tu domicilio de entrega completo.')),
      );
      return;
    }

    if (_isSeller &&
        (_sellerBusinessAddressDraft == null ||
            !_sellerBusinessAddressDraft!.hasRequiredFields)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Captura el domicilio del negocio completo.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final role = _isSeller ? 'seller' : 'customer';

      final payload = await _apiClient.register(
        role: role,
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        customerAddress: !_isSeller && _customerAddressDraft != null
            ? _formatAddressForRegister(_customerAddressDraft!)
            : null,
        customerAddressDraft: !_isSeller ? _customerAddressDraft : null,
        storeName: _isSeller ? _storeNameCtrl.text.trim() : null,
        contactPhone: _isSeller ? _contactPhoneCtrl.text.trim() : null,
        businessAddress: _isSeller && _sellerBusinessAddressDraft != null
            ? _formatAddressForRegister(_sellerBusinessAddressDraft!)
            : null,
        businessAddressDraft: _isSeller ? _sellerBusinessAddressDraft : null,
        description: _isSeller ? _descriptionCtrl.text.trim() : null,
      );

      if (!mounted) return;

      final message = payload['message']?.toString() ??
          (_isSeller
              ? 'Registro de vendedor enviado con exito.'
              : 'Cuenta creada con exito.');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      widget.onBackToLogin();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error inesperado.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = isMobile
        ? const EdgeInsets.fromLTRB(18, 18, 18, 24)
        : const EdgeInsets.fromLTRB(48, 42, 48, 36);

    return Container(
      color: const Color(0xFFF5F1EA),
      child: SingleChildScrollView(
        padding: padding,
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: isMobile ? 18 : 34),
                _buildNameRow(),
                _buildUsernameField(),
                SizedBox(height: isMobile ? 14 : 18),
                _buildEmailField(),
                SizedBox(height: isMobile ? 14 : 18),
                _buildPhoneField(),
                SizedBox(height: isMobile ? 14 : 18),
                _buildPasswordField(),
                const SizedBox(height: 8),
                PasswordStrengthBar(strength: _passwordStrength),
                const SizedBox(height: 4),
                Text(
                  _passwordHint,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA7A29A),
                    fontSize: isMobile ? 10 : 13,
                  ),
                ),
                SizedBox(height: isMobile ? 14 : 26),
                _buildRoleSection(),
                SizedBox(height: isMobile ? 14 : 26),
                if (_isSeller) _buildSellerSection(),
                if (!_isSeller) _buildCustomerSection(),
                SizedBox(height: isMobile ? 18 : 24),
                AbsorbPointer(
                  absorbing: _isSubmitting,
                  child: Opacity(
                    opacity: _isSubmitting ? 0.7 : 1,
                    child: RegisterSubmitButton(
                      compact: isMobile,
                      onPressed: _submit,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: widget.onBackToLogin,
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA7A29A),
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(text: 'Ya tienes una cuenta? '),
                          TextSpan(
                            text: 'Inicia sesion',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF172A18),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crear Cuenta',
          style: GoogleFonts.dmSerifDisplay(
            color: const Color(0xFF151515),
            fontSize: isMobile ? 24 : 54,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Completa tus datos para comenzar',
          style: GoogleFonts.inter(
            color: const Color(0xFFA7A29A),
            fontSize: isMobile ? 12 : 17,
          ),
        ),
      ],
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Expanded(
          child: RegisterInput(
            compact: isMobile,
            label: 'NOMBRE',
            hint: 'Maria',
            icon: Icons.person_outline_rounded,
            controller: _firstNameCtrl,
            validator: _requiredValidator,
          ),
        ),
        SizedBox(width: isMobile ? 10 : 18),
        Expanded(
          child: RegisterInput(
            compact: isMobile,
            label: 'APELLIDO',
            hint: 'Garcia',
            icon: Icons.person_outline_rounded,
            controller: _lastNameCtrl,
            validator: _requiredValidator,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return RegisterInput(
      compact: isMobile,
      label: 'USUARIO',
      hint: 'MariaGar',
      icon: Icons.alternate_email_rounded,
      controller: _usernameCtrl,
      validator: _requiredValidator,
    );
  }

  Widget _buildEmailField() {
    return RegisterInput(
      compact: isMobile,
      label: 'CORREO ELECTRONICO',
      hint: 'your@example.com',
      icon: Icons.email_outlined,
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      validator: _emailValidator,
    );
  }

  Widget _buildPhoneField() {
    return RegisterInput(
      compact: isMobile,
      label: 'TELEFONO',
      hint: '+52 55 0000 0000',
      icon: Icons.phone_android_outlined,
      controller: _phoneCtrl,
      keyboardType: TextInputType.phone,
      validator: _requiredValidator,
    );
  }

  Widget _buildPasswordField() {
    return RegisterInput(
      compact: isMobile,
      label: 'CONTRASENA',
      hint: 'Min. 8 caracteres',
      icon: Icons.lock_outline_rounded,
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      onChanged: (_) => setState(() {}),
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        icon: Icon(
          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: const Color(0xFFA7B197),
          size: isMobile ? 18 : 22,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (v.length < 8) return 'Minimo 8 caracteres';
        return null;
      },
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOY UN...',
          style: GoogleFonts.inter(
            color: const Color(0xFF111111),
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: RegisterRoleCard(
                compact: isMobile,
                title: 'Comprador',
                emoji: '\u{1F6D2}',
                selected: _selectedRole == RegisterRole.buyer,
                onTap: () => _onRoleSelected(RegisterRole.buyer),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RegisterRoleCard(
                compact: isMobile,
                title: 'Productor',
                emoji: '\u{1F33E}',
                selected: _selectedRole == RegisterRole.producer,
                onTap: () => _onRoleSelected(RegisterRole.producer),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMACION DE ENTREGA',
          style: GoogleFonts.inter(
            color: const Color(0xFF111111),
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Registra tu direccion principal para recibir tus pedidos.',
          style: GoogleFonts.inter(
            color: const Color(0xFFA7A29A),
            fontSize: isMobile ? 11 : 13,
          ),
        ),
        const SizedBox(height: 12),
        _buildAddressCaptureSection(
          enabled: true,
          draft: _customerAddressDraft,
          emptyTitle: 'No hay direccion capturada.',
          emptySubtitle: 'Agrega tu domicilio completo para recibir pedidos.',
          onAdd: _openCustomerAddressForm,
          onEdit: _openCustomerAddressForm,
        ),
      ],
    );
  }

  Widget _buildSellerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMACION DEL VENDEDOR',
          style: GoogleFonts.inter(
            color: const Color(0xFF111111),
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Completa estos campos para registrarte como vendedor.',
          style: GoogleFonts.inter(
            color: const Color(0xFFA7A29A),
            fontSize: isMobile ? 11 : 13,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            RegisterInput(
              compact: isMobile,
              label: 'NOMBRE DE LA TIENDA',
              hint: 'Mi Tienda',
              icon: Icons.storefront_outlined,
              controller: _storeNameCtrl,
              validator: (value) {
                if (!_isSeller) return null;
                if (value == null || value.trim().isEmpty) {
                  return 'Requerido para vendedor';
                }
                return null;
              },
            ),
            SizedBox(height: isMobile ? 14 : 18),
            RegisterInput(
              compact: isMobile,
              label: 'TELEFONO DE CONTACTO',
              hint: '+52 55 0000 0000',
              icon: Icons.phone_outlined,
              controller: _contactPhoneCtrl,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (!_isSeller) return null;
                if (value == null || value.trim().isEmpty) {
                  return 'Requerido para vendedor';
                }
                return null;
              },
            ),
            SizedBox(height: isMobile ? 14 : 18),
            _buildAddressCaptureSection(
              enabled: true,
              draft: _sellerBusinessAddressDraft,
              emptyTitle: 'No hay direccion del negocio.',
              emptySubtitle: 'Registra el domicilio comercial para activar tu tienda.',
              onAdd: _openSellerAddressForm,
              onEdit: _openSellerAddressForm,
            ),
            SizedBox(height: isMobile ? 14 : 18),
            RegisterInput(
              compact: isMobile,
              label: 'DESCRIPCION',
              hint: 'Frutas y verduras',
              icon: Icons.description_outlined,
              controller: _descriptionCtrl,
            ),
          ],
          ),
      ],
    );
  }

  Widget _buildAddressCaptureSection({
    required bool enabled,
    required AddressDraft? draft,
    required String emptyTitle,
    required String emptySubtitle,
    required VoidCallback onAdd,
    required VoidCallback onEdit,
  }) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF4A7A4D), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    draft == null ? 'Sin domicilio registrado' : 'Domicilio registrado',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: draft == null ? onAdd : onEdit,
                  icon: Icon(
                    draft == null
                        ? Icons.add_location_alt_outlined
                        : Icons.edit_location_alt_outlined,
                    size: 18,
                  ),
                  label: Text(draft == null ? 'Agregar' : 'Editar'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (draft == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5EF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2DBCF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emptyTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emptySubtitle,
                      style: const TextStyle(color: Color(0xFF6E6259)),
                    ),
                  ],
                ),
              ),
            if (draft != null) _buildAddressPreviewCard(draft),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressPreviewCard(AddressDraft draft) {
    final primary = '${draft.street.trim()} ${draft.extNumber.trim()}'.trim();
    final secondary = <String>[
      if (draft.intNumber.trim().isNotEmpty) 'Int ${draft.intNumber.trim()}',
      draft.neighborhood.trim(),
      draft.city.trim(),
      draft.state.trim(),
      if (draft.postalCode.trim().isNotEmpty) 'CP ${draft.postalCode.trim()}',
    ].where((value) => value.isNotEmpty).join(', ');
    final contact = <String>[
      draft.fullName.trim(),
      draft.phone.trim(),
    ].where((value) => value.isNotEmpty).join(' / ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFE3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E4F2F), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD9E6D2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              draft.normalizedAlias,
              style: const TextStyle(
                color: Color(0xFF1F1209),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            primary,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1209),
            ),
          ),
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              secondary,
              style: const TextStyle(color: Color(0xFF6E6259)),
            ),
          ],
          if (contact.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              contact,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6E6259),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Ingresa un correo valido';
    }
    return null;
  }
}
