  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'register_form.dart';
  import '../data/api_client.dart';

  class RegisterFormSection extends StatefulWidget {
    final bool isMobile;
    final VoidCallback onBackToLogin;

    const RegisterFormSection({super.key, this.isMobile = false, required this.onBackToLogin});

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
    bool _isSubmitting = false;

    bool _obscurePassword = true;
    bool _acceptedTerms = true;
    RegisterRole _selectedRole = RegisterRole.buyer;
    bool get _isSeller => _selectedRole == RegisterRole.producer;
    bool get _isDelivery => _selectedRole == RegisterRole.rider;
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
      int score = 0;

      if (password.length >= 8) score++;
      if (RegExp(r'[A-Z]').hasMatch(password)) score++;
      if (RegExp(r'[0-9]').hasMatch(password)) score++;
      if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\[\]~`]').hasMatch(password)) {
        score++;
      }

      return score.clamp(0, 4);
    }

    void _onRoleSelected(RegisterRole role) {
    setState(() {
      _selectedRole = role;

      if (role != RegisterRole.producer) {
        _storeNameCtrl.clear();
        _contactPhoneCtrl.clear();
        _descriptionCtrl.clear();
      }
    });
  }

    String get _passwordHint {
      switch (_passwordStrength) {
        case 0:
        case 1:
          return 'Contraseña débil — usa más caracteres';
        case 2:
          return 'Fuerza media — añade números para fortalecer';
        case 3:
          return 'Fuerza media — añade símbolos para fortalecer';
        case 4:
          return 'Contraseña fuerte';
        default:
          return '';
      }
    }

    Future<void> _submit() async {
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes aceptar los términos para continuar.')),
        );
        return;
      }

      if (_selectedRole == RegisterRole.rider) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El registro público para repartidores no está disponible aún.'),
          ),
        );
        return;
      }

      if (!_formKey.currentState!.validate()) return;

      setState(() {
        _isSubmitting = true;
      });

      try {
        final role = _selectedRole == RegisterRole.producer ? 'seller' : 'customer';

        final payload = await _apiClient.register(
          role: role,
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          firstName: _firstNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          storeName: _isSeller ? _storeNameCtrl.text.trim() : null,
          contactPhone: _isSeller ? _contactPhoneCtrl.text.trim() : null,
          description: _isSeller ? _descriptionCtrl.text.trim() : null,
        );

        if (!mounted) return;

        final message = payload['message']?.toString() ??
    (_isSeller
        ? 'Registro de vendedor enviado con éxito.'
        : 'Cuenta creada con éxito.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      await Future.delayed(const Duration(microseconds: 900));

      if (!mounted) return;

      widget.onBackToLogin();

        // Aquí luego puedes navegar o iniciar sesión si aplica
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado.')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
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
                  _buildSellerSection(),
                  SizedBox(height: isMobile ? 18 : 24),
                  RegisterSubmitButton(
                    compact: isMobile,
                    onPressed: _submit,
                  ),
                  SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          widget.onBackToLogin();
                        },
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA7A29A),
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: '¿Ya tienes una cuenta? '),
                            TextSpan(
                              text: 'Inicia sesión',
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
              hint: 'María',
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
              hint: 'García',
              icon: Icons.person_outline_rounded,
              controller: _lastNameCtrl,
              validator: _requiredValidator,
            ),
          ),
        ],
      );
    }

    Widget _buildEmailField() {
      return RegisterInput(
        compact: isMobile,
        label: 'CORREO ELECTRÓNICO',
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
        label: 'TELÉFONO',
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
        label: 'CONTRASEÑA',
        hint: 'Mín. 8 caracteres',
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
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFFA7B197),
            size: isMobile ? 18 : 22,
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Requerido';
          if (v.length < 8) return 'Mínimo 8 caracteres';
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
                  emoji: '🛒',
                  selected: _selectedRole == RegisterRole.buyer,
                  onTap: () => _onRoleSelected(RegisterRole.buyer),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RegisterRoleCard(
                  compact: isMobile,
                  title: 'Productor',
                  emoji: '🌾',
                  selected: _selectedRole == RegisterRole.producer,
                  onTap: () => _onRoleSelected(RegisterRole.producer),
                ),
              ),
              /*
              const SizedBox(width: 8),
              Expanded(
                child: RegisterRoleCard(
                  compact: isMobile,
                  title: 'Repartidor',
                  emoji: '🛵',
                  selected: _selectedRole == RegisterRole.rider,
                  onTap: () => _onRoleSelected(RegisterRole.rider),
                ),
              ),*/
            ],
          ),
        ],
      );
    }

    String? _requiredValidator(String? value) {
      if (value == null || value.trim().isEmpty) return 'Requerido';
      return null;
    }

    String? _emailValidator(String? value) {
      if (value == null || value.trim().isEmpty) return 'Requerido';
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
        return 'Ingresa un correo válido';
      }
      return null;
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
    Widget _buildSellerSection() {
    final enabled = _isSeller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMACIÓN DEL VENDEDOR',
          style: GoogleFonts.inter(
            color: const Color(0xFF111111),
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          enabled
              ? 'Completa estos campos para registrarte como vendedor.'
              : 'Estos campos solo se habilitan al seleccionar Productor.',
          style: GoogleFonts.inter(
            color: const Color(0xFFA7A29A),
            fontSize: isMobile ? 11 : 13,
          ),
        ),
        const SizedBox(height: 12),

        AbsorbPointer(
          absorbing: !enabled,
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Column(
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
                  label: 'TELÉFONO DE CONTACTO',
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
                RegisterInput(
                  compact: isMobile,
                  label: 'DESCRIPCIÓN',
                  hint: 'Frutas y verduras',
                  icon: Icons.description_outlined,
                  controller: _descriptionCtrl,
                  validator: (value) {
                    if (!_isSeller) return null;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  }