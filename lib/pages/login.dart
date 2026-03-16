import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../models/auth_session.dart';

class WebLoginPage extends StatelessWidget {
  const WebLoginPage({
    super.key,
    required this.onLoginSuccess,
  });

  final ValueChanged<AuthSession> onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final cardWidth = isDesktop ? 1100.0 : 420.0;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: cardWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F4EE),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: isDesktop
                      ? _DesktopLoginLayout(onLoginSuccess: onLoginSuccess)
                      : _MobileLoginLayout(onLoginSuccess: onLoginSuccess),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DesktopLoginLayout extends StatelessWidget {
  const _DesktopLoginLayout({required this.onLoginSuccess});

  final ValueChanged<AuthSession> onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: _HeroSection(),
          ),
          Expanded(
            flex: 6,
            child: _FormSection(onLoginSuccess: onLoginSuccess),
          ),
        ],
      ),
    );
  }
}

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout({required this.onLoginSuccess});

  final ValueChanged<AuthSession> onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _HeroSection(isMobile: true),
        _FormSection(
          isMobile: true,
          onLoginSuccess: onLoginSuccess,
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({this.isMobile = false});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF24140B),
            Color(0xFF274326),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(28),
          bottomLeft: isMobile ? Radius.zero : const Radius.circular(28),
          topRight: const Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6F685E)),
                ),
                child: const Center(
                  child: Text(
                    'AG',
                    style: TextStyle(
                      color: Color(0xFFE5DED2),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF6F685E)),
                ),
                child: const Text(
                  'AGROUBER',
                  style: TextStyle(
                    color: Color(0xFFE5DED2),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 26 : 42),
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: isMobile ? 34 : 48,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE2A23C),
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              'Sign in to manage orders, review purchases, and connect directly with agricultural producers.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                height: 1.6,
                color: const Color(0xFFD4CEC3),
              ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
             
            ),
          ],
        ],
      ),
    );
  }
}

class _FormSection extends StatefulWidget {
  const _FormSection({
    this.isMobile = false,
    required this.onLoginSuccess,
  });

  final bool isMobile;
  final ValueChanged<AuthSession> onLoginSuccess;

  @override
  State<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Escribe tu correo y tu contrasena.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final session = await _apiClient.login(
        identifier: email,
        password: password,
      );

      if (!mounted) {
        return;
      }

      widget.onLoginSuccess(session);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'No fue posible conectar con el backend.';
      });
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
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EE),
        borderRadius: BorderRadius.only(
          topRight: widget.isMobile ? Radius.zero : const Radius.circular(28),
          bottomRight: const Radius.circular(28),
          bottomLeft: widget.isMobile ? const Radius.circular(28) : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log In',
            style: TextStyle(
              fontSize: widget.isMobile ? 30 : 40,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2A1B10),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your credentials to continue',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8F877C),
            ),
          ),
          SizedBox(height: widget.isMobile ? 24 : 32),
          const Text(
            'EMAIL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Color(0xFF2A1B10),
            ),
          ),
          const SizedBox(height: 10),
          _LoginTextField(
            controller: _emailController,
            hintText: 'your@example.com',
            prefixIcon: Icons.mail_outline,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          const Text(
            'PASSWORD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Color(0xFF2A1B10),
            ),
          ),
          const SizedBox(height: 10),
          _LoginTextField(
            controller: _passwordController,
            hintText: '********',
            prefixIcon: Icons.lock_outline,
            suffixIcon: _isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            obscureText: !_isPasswordVisible,
            onSuffixPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            onSubmitted: (_) => _submit(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: Color(0xFF6D675E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF284826),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Sign In ->',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Color(0xFF8F877C),
                  fontSize: 14,
                ),
                children: [
                  TextSpan(text: "Don't have an account? "),
                  TextSpan(
                    text: 'Create one',
                    style: TextStyle(
                      color: Color(0xFF2A1B10),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onSuffixPressed,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final VoidCallback? onSuffixPressed;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1EBE3),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFFA39B90),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFFCAA36B),
        ),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(
                  suffixIcon,
                  color: const Color(0xFFAAA398),
                ),
                onPressed: onSuffixPressed,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
      ),
    );
  }
}
