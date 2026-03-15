import 'package:flutter/material.dart';
import 'login_textFields.dart';
import '../data/mock_data.dart';
import '../pages/login.dart';
import '../pages/buyer_home_page.dart';

class FormSection extends StatefulWidget {
  final bool isMobile;

  const FormSection({this.isMobile = false});

  @override
  _FormSectionState createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
  bool _isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline,
            suffixIcon: _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            obscureText: !_isPasswordVisible,
            controller: _passwordController,
            onSuffixPressed: _togglePasswordVisibility,
          ),

          const SizedBox(height: 10),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                final email = _emailController.text.trim();
                final password = _passwordController.text;

                print('Email entered: $email');
                print('Password entered: $password');
                if (isUserValid(email, password)) {
                  //Change when backend is implemented, for now we are using the email to find the user
                  final user = mockUsers.firstWhere((u) => u.email == email);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyerHomePage(user: user),
                    ),
                  );
                } else{
                  print('Login failed: invalid credentials');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid email or password'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
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