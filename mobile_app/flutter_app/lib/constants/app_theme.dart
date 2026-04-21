import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF8A65);
  static const Color secondary = Color(0xFFFFC1A1);
  static const Color accent = Color(0xFFFFE0D2);
  static const Color darkText = Color(0xFF3A2E2A);
  static const Color lightBg = Color(0xFFFFF7F3);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: lightBg,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: darkText,
      ),
    ),
  );
}