import 'package:flutter/material.dart';
import '../pages/seller_home_page.dart';
import '../data/api_client.dart';
import '../models/auth_session.dart';
import '../pages/buyer_home_page.dart';
import '../pages/register_page.dart';
import '../pages/rider_page.dart';
import 'login_textFields.dart';

class FormSection extends StatefulWidget {
  const FormSection({
    super.key,
    this.isMobile = false,
    required this.onLoginSuccess,
  });

  final bool isMobile;
  final ValueChanged<AuthSession> onLoginSuccess;

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
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

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
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
      _redirectByRole(session);
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

  void _redirectByRole(AuthSession session) {
    late final Widget page;

    switch (session.role) {
      case 'delivery':
        page = RiderPage(session: session);
        break;
      case 'seller':
        page = SellerHomePage(session: session);
        break;
      case 'customer':
      default:
        page = BuyerHomePage(session: session);
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => page,
      ),
    );
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
          LoginTextField(
            hintText: 'your@example.com',
            prefixIcon: Icons.mail_outline,
            controller: _emailController,
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
          LoginTextField(
            hintText: '********',
            prefixIcon: Icons.lock_outline,
            suffixIcon: _isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            obscureText: !_isPasswordVisible,
            controller: _passwordController,
            onSuffixPressed: _togglePasswordVisibility,
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
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RegisterPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2A1B10),
                padding: EdgeInsets.zero,
              ),
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
          ),
        ],
      ),
    );
  }
}