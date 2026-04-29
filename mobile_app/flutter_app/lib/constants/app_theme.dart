import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF8A65); // Blush Orange
  static const Color secondary = Color(0xFFFFC1A1); // Pastel Peach
  static const Color accent = Color(0xFFFFE5D9); // Soft Coral/Beige
  static const Color darkText = Color(0xFF4A3F35); // Soft earthy dark tone
  static const Color lightBg = Color(0xFFFFF9F6); // Creamy background

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: lightBg,
    primaryColor: primary,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: darkText,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: darkText.withValues(alpha: 0.8),
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: darkText.withValues(alpha: 0.6),
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    ),
  );
}