import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/login.dart';
import 'register_form.dart';

class RegisterFormSection extends StatefulWidget {
  final bool isMobile;

  const RegisterFormSection({super.key, this.isMobile = false});

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

  bool _obscurePassword = true;
  bool _acceptedTerms = true;
  RegisterRole _selectedRole = RegisterRole.buyer;

  bool get isMobile => widget.isMobile;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
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

  String get _passwordHint {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return 'Weak password — use more characters';
      case 2:
        return 'Medium strength — add numbers to strengthen';
      case 3:
        return 'Medium strength — add symbols to strengthen';
      case 4:
        return 'Strong password';
      default:
        return '';
    }
  }

  void _submit() {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the terms to continue.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register submitted')),
      );
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
                SizedBox(height: isMobile ? 18 : 24),
                RegisterSubmitButton(
                  compact: isMobile,
                  onPressed: _submit,
                ),
                SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        
                      },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA7A29A),
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign in',
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
          'Create Account',
          style: GoogleFonts.dmSerifDisplay(
            color: const Color(0xFF151515),
            fontSize: isMobile ? 24 : 54,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fill in your details to get started',
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
            label: 'FIRST NAME',
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
            label: 'LAST NAME',
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
      label: 'EMAIL',
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
      label: 'PHONE',
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
      label: 'PASSWORD',
      hint: 'Min. 8 characters',
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
        if (v == null || v.isEmpty) return 'Required';
        if (v.length < 8) return 'Minimum 8 characters';
        return null;
      },
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I AM A...',
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
                title: 'Buyer',
                emoji: '🛒',
                selected: _selectedRole == RegisterRole.buyer,
                onTap: () => setState(() {
                  _selectedRole = RegisterRole.buyer;
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RegisterRoleCard(
                compact: isMobile,
                title: 'Producer',
                emoji: '🌾',
                selected: _selectedRole == RegisterRole.producer,
                onTap: () => setState(() {
                  _selectedRole = RegisterRole.producer;
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RegisterRoleCard(
                compact: isMobile,
                title: 'Rider',
                emoji: '🛵',
                selected: _selectedRole == RegisterRole.rider,
                onTap: () => setState(() {
                  _selectedRole = RegisterRole.rider;
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }
} 