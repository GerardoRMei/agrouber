import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RegisterRole { buyer, producer, rider }

class RegisterInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool compact;

  const RegisterInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 14.0 : 18.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF111111),
            fontSize: compact ? 11 : 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: compact ? 8 : 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            color: const Color(0xFF2C2B2B),
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFFB8B1A8),
              fontSize: compact ? 14 : 16,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFE5A72D),
              size: compact ? 18 : 22,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFEAE4DB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 18,
              vertical: compact ? 14 : 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(
                color: Color(0xFF375E39),
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterRoleCard extends StatelessWidget {
  final String title;
  final String emoji;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const RegisterRoleCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 14.0 : 18.0;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: compact ? 72 : 94,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8EEE7) : const Color(0xFFEAE4DB),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: selected ? const Color(0xFF375E39) : const Color(0xFFD8D1C8),
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: compact ? 18 : 24)),
            SizedBox(height: compact ? 6 : 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: selected
                    ? const Color(0xFF1B3D23)
                    : const Color(0xFF8F958D),
                fontSize: compact ? 11 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool compact;

  const RegisterSubmitButton({
    super.key,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: compact ? 54 : 66,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF234729),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compact ? 14 : 18),
          ),
        ),
        child: Text(
          'Crea tu cuenta →',
          style: GoogleFonts.inter(
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class PasswordStrengthBar extends StatelessWidget {
  final int strength;

  const PasswordStrengthBar({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final active = index < strength;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFE5A72D)
                  : const Color(0xFFD9D2C8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}