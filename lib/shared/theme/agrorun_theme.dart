import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgrorunPalette {
  static const Color forest = Color(0xFF2D5F40);
  static const Color forestDark = Color(0xFF214530);
  static const Color leaf = Color(0xFF6E9B61);
  static const Color orange = Color(0xFFF27C4A);
  static const Color cream = Color(0xFFF7F2E9);
  static const Color creamStrong = Color(0xFFF1E9DD);
  static const Color textPrimary = Color(0xFF1F3526);
  static const Color textMuted = Color(0xFF697366);
  static const Color success = Color(0xFF2F7D4B);
}

class AgrorunTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AgrorunPalette.forest,
      brightness: Brightness.light,
    ).copyWith(
      primary: AgrorunPalette.forest,
      secondary: AgrorunPalette.orange,
      surface: Colors.white,
      onSurface: AgrorunPalette.textPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AgrorunPalette.cream,
      textTheme: GoogleFonts.montserratTextTheme(),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AgrorunPalette.cream,
        foregroundColor: AgrorunPalette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        backgroundColor: Colors.white,
        selectedColor: AgrorunPalette.forest,
        labelStyle: const TextStyle(
          color: AgrorunPalette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AgrorunPalette.forest,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AgrorunPalette.forest,
          side: const BorderSide(color: AgrorunPalette.forest),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AgrorunPalette.textMuted),
        labelStyle: const TextStyle(color: AgrorunPalette.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AgrorunPalette.forest, width: 1.5),
        ),
      ),
    );
  }
}
