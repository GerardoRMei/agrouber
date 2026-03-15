import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final VoidCallback? onSuffixPressed;
  final TextEditingController? controller;

  const LoginTextField({super.key, 
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onSuffixPressed,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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