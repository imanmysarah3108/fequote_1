import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// QuoteMyMood design tokens.
///
/// This file is the single source of truth for colour, typography, spacing,
/// radii and elevation. Screens should read from here rather than hard-coding
/// values, so consistency is enforced centrally (SUS heuristic #2 –
/// "functions well integrated / consistent").
///
/// NOTE: This is a visual/token refactor only. Every previously public member
/// name is preserved so existing screens keep compiling and behaving
/// identically. New members are additive.
class AppTheme {
  // ---------------------------------------------------------------------------
  // Brand colours (unchanged – preserves existing identity)
  // ---------------------------------------------------------------------------
  static const Color primaryPurple = Color(0xFFB692F6);
  static const Color primaryPeach = Color(0xFFF0A89E);
  static const Color gradientTop = Color(0xFFB5A6FF);
  static const Color gradientMid = Color(0xFFE8A4C8);
  static const Color gradientBottom = Color(0xFFFFB49E);
  static const Color darkText = Color(0xFF4A3F35);
  static const Color quoteText = Color(0xFF5E4B8B);
  static const Color lightBg = Color(0xFFFFF0EB);
  static const Color navBarBg = Color(0xFFFFF0EB);

  // ---------------------------------------------------------------------------
  // NEW: text colours used ON light/glass surfaces (dark cards, sheets).
  // Chosen to pass WCAG AA on white / frosted-white cards.
  // ---------------------------------------------------------------------------
  /// Primary body text on light surfaces. AA on white (contrast ~9:1).
  static const Color textOnLight = Color(0xFF3D3330);
  /// Secondary/muted text on light surfaces. Still AA (~4.6:1 on white).
  static const Color textOnLightMuted = Color(0xFF6B5E57);

  /// Unselected bottom-nav item colour. Muted but still clearly legible against
  /// the light nav bar — raises discoverability of inactive tabs (feedback #2).
  static Color navInactive = quoteText.withValues(alpha: 0.68);

  // ---------------------------------------------------------------------------
  // NEW: semantic state colours (loading/empty use neutrals; these are for
  // success / error / warning / info messaging). Tuned for AA on white cards.
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF2E7D5B);
  static const Color error = Color(0xFFC0392B);
  static const Color warning = Color(0xFFB8860B);
  static const Color info = Color(0xFF2C6FB3);

  // ---------------------------------------------------------------------------
  // NEW: centralised emotion palette.
  // Used to render the detected emotion / NRC basis consistently wherever it
  // appears (SUS heuristic #6 – confidence in the FER result). This only
  // affects how the already-computed emotion is *displayed*; it does not touch
  // FER/CBF/NRC logic.
  // ---------------------------------------------------------------------------
  static const Map<String, Color> emotionColors = {
    'happy': Color(0xFFF2B705),
    'joy': Color(0xFFF2B705),
    'sad': Color(0xFF5B8DEF),
    'sadness': Color(0xFF5B8DEF),
    'angry': Color(0xFFE0553B),
    'anger': Color(0xFFE0553B),
    'fear': Color(0xFF8E6FD8),
    'surprise': Color(0xFFEB8FC0),
    'disgust': Color(0xFF5FA86A),
    'neutral': Color(0xFF9B8FA6),
    // Provider default before any scan – a calm teal so the initial bubble reads
    // as its own mood rather than falling back to the brand purple.
    'peaceful': Color(0xFF4FB0A5),
  };

  /// Safe lookup that always returns a valid colour for an emotion label.
  static Color emotionColor(String emotion) =>
      emotionColors[emotion.toLowerCase()] ?? primaryPurple;

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
  );

  // ---------------------------------------------------------------------------
  // Spacing scale (4 / 8 / 12 / 16 / 24 / 32) – existing names preserved,
  // one added (space4) so the smallest step is available.
  // ---------------------------------------------------------------------------
  static const double space4 = 4; // NEW
  static const double spaceXs = 8;
  static const double spaceSm = 12;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // ---------------------------------------------------------------------------
  // Border radius (unchanged)
  // ---------------------------------------------------------------------------
  static const double radiusCard = 24;
  static const double radiusPill = 28;
  static const double radiusQuoteCard = 40;
  static const double radiusNavBar = 32;

  // ---------------------------------------------------------------------------
  // Type scale (names preserved). Body sizes nudged up slightly for
  // readability; a caption size is added.
  // ---------------------------------------------------------------------------
  static const double pageTitleSize = 26;
  static const double sectionTitleSize = 16;
  static const double cardTitleSize = 22;
  static const double bodySize = 15; // was 14 – improves readability
  static const double captionSize = 13; // NEW
  static const double labelSize = 12;

  // ---------------------------------------------------------------------------
  // Component sizing (unchanged)
  // ---------------------------------------------------------------------------
  static const double buttonHeight = 52;
  static const double navBarHeight = 64;
  static const double cameraButtonSize = 72;
  static const double cameraButtonFloat = 28;
  /// NEW: minimum accessible tap target (WCAG 2.5.5 / Material).
  static const double minTapTarget = 48;

  // ---------------------------------------------------------------------------
  // NEW: legibility shadow for white text sitting on the light peach end of
  // the gradient. Subtle – improves perceived contrast without changing colour.
  // ---------------------------------------------------------------------------
  static const List<Shadow> onGradientTextShadow = [
    Shadow(
      color: Color(0x33000000),
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
  ];

  // ---------------------------------------------------------------------------
  // NEW: reusable elevation for cards, so shadows are consistent.
  // ---------------------------------------------------------------------------
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

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
    // Ripple/press feedback tuned to be visible on the gradient (SUS #5 –
    // responsive feedback on every interaction).
    splashColor: Colors.white.withValues(alpha: 0.18),
    highlightColor: Colors.white.withValues(alpha: 0.08),
    textTheme: TextTheme(
      // Display / page title
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: pageTitleSize,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
        height: 1.2,
        shadows: onGradientTextShadow,
      ),
      // Card / section title
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: cardTitleSize,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.25,
        shadows: onGradientTextShadow,
      ),
      // Lead paragraph — weight raised w300→w400 and opacity up for legibility
      bodyLarge: GoogleFonts.poppins(
        fontSize: sectionTitleSize,
        color: Colors.white,
        height: 1.45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        shadows: onGradientTextShadow,
      ),
      // Body — weight raised w300→w400, opacity 0.8→0.92 for AA-ish legibility
      bodyMedium: GoogleFonts.poppins(
        fontSize: bodySize,
        color: Colors.white.withValues(alpha: 0.92),
        fontWeight: FontWeight.w400,
        height: 1.5,
        shadows: onGradientTextShadow,
      ),
      // Caption — NEW, for helper text / timestamps
      bodySmall: GoogleFonts.poppins(
        fontSize: captionSize,
        color: Colors.white.withValues(alpha: 0.85),
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
        shadows: onGradientTextShadow,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: sectionTitleSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    // NEW: consistent SnackBar styling (used by "copied to clipboard" etc.)
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: darkText,
      contentTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: bodySize,
        fontWeight: FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusCard),
      ),
    ),
  );
}