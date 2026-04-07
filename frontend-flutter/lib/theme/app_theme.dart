import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Corporate, Minimal, Trust-first
  static const Color primaryBlue = Color(0xFF003366); // Dark blue
  static const Color accentGrey = Color(0xFF555555); // Grey
  static const Color lightGrey = Color(0xFFF5F5F5); // Background
  static const Color white = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFFC107);
  static const Color infoBlue = Color(0xFF2196F3);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Border & divider colors
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color dividerGrey = Color(0xFFEEEEEE);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightGrey,
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          labelSmall: TextStyle(
            fontSize: 12,
            color: textHint,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        elevation: 2,
      ),
      cardTheme: CardTheme(
        color: white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textHint),
      ),
      dividerTheme: const DividerThemeData(
        color: lightGrey,
        thickness: 1,
      ),
    );
  }
}
