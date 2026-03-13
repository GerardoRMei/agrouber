import 'package:flutter/material.dart';

class WebLoginPage extends StatelessWidget {
  const WebLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 900;
            final double cardWidth = isDesktop ? 1100 : 420;

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
                      ? const _DesktopLoginLayout()
                      : const _MobileLoginLayout(),
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
  const _DesktopLoginLayout();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: const [
          Expanded(
            flex: 5,
            child: _HeroSection(),
          ),
          Expanded(
            flex: 6,
            child: _FormSection(),
          ),
        ],
      ),
    );
  }
}

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _HeroSection(isMobile: true),
        _FormSection(isMobile: true),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isMobile;

  const _HeroSection({this.isMobile = false});

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
          bottomRight: isMobile ? Radius.zero : Radius.zero,
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
                    'LOGO',
                    style: TextStyle(
                      color: Color(0xFFE5DED2),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF6F685E)),
                ),
                child: const Text(
                  'APP NAME',
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
          ]
        ],
      ),
    );
  }
}

class _FormSection extends StatefulWidget {
  final bool isMobile;

  const _FormSection({this.isMobile = false});

  @override
  _FormSectionState createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
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
          const _LoginTextField(
            hintText: 'your@example.com',
            prefixIcon: Icons.mail_outline,
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
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline,
            suffixIcon: _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            obscureText: !_isPasswordVisible,
            onSuffixPressed: _togglePasswordVisibility,
          ),

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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF284826),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Sign In →',
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
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final VoidCallback? onSuffixPressed;

  const _LoginTextField({
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onSuffixPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
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