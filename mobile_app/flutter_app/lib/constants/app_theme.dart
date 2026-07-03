import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFFB692F6);
  static const Color primaryPeach = Color(0xFFF0A89E);
  static const Color gradientTop = Color(0xFFB5A6FF);
  static const Color gradientMid = Color(0xFFE8A4C8);
  static const Color gradientBottom = Color(0xFFFFB49E);
  static const Color darkText = Color(0xFF4A3F35);
  static const Color quoteText = Color(0xFF5E4B8B);
  static const Color lightBg = Color(0xFFFFF0EB);
  static const Color navBarBg = Color(0xFFFFF0EB);

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
  );

  // Spacing scale
  static const double spaceXs = 8;
  static const double spaceSm = 12;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // Border radius
  static const double radiusCard = 24;
  static const double radiusPill = 28;
  static const double radiusQuoteCard = 40;
  static const double radiusNavBar = 32;

  // Layout
  static const double pageTitleSize = 26;
  static const double sectionTitleSize = 16;
  static const double cardTitleSize = 22;
  static const double bodySize = 14;
  static const double labelSize = 12;
  static const double buttonHeight = 52;
  static const double navBarHeight = 64;
  static const double cameraButtonSize = 72;
  static const double cameraButtonFloat = 28;

  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [gradientTop, gradientMid, gradientBottom],
      stops: [0.0, 0.45, 1.0],
    ),
  );

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.transparent,
    primaryColor: primaryPurple,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: pageTitleSize,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: cardTitleSize,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.25,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: sectionTitleSize,
        color: Colors.white.withValues(alpha: 0.95),
        height: 1.4,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.1,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: bodySize,
        color: Colors.white.withValues(alpha: 0.8),
        fontWeight: FontWeight.w300,
        height: 1.45,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: sectionTitleSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  );
}
