import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the redesigned My Profile + Settings screens.
/// Colors, radii, spacing, gradients and text styles live here only.
class ProfileTheme {
  ProfileTheme._();

  // Colors
  static const Color pink = Color(0xFFE8559A);
  static const Color purple = Color(0xFF7C4DDB);
  static const Color navy = Color(0xFF1E1B3A);
  static const Color grey = Color(0xFF7A7690);
  static const Color bgTop = Color(0xFFF3E8FF);
  static const Color bgBottom = Color(0xFFFBF8FF);
  static const Color card = Colors.white;
  static const Color track = Color(0xFFEDE6FA);
  static const Color toggleOff = Color(0xFFD9D4E7);
  static const Color divider = Color(0xFFEEE9F7);
  static const Color chipBorder = Color(0xFFE3D8F7);
  static const Color lavenderCard = Color(0xFFEFE7FB);
  static const Color tileFill = Color(0xFFF3ECFD);
  static const Color tileBorder = Color(0xFFCDBDF0);
  static const Color rowIcon = Color(0xFF8B83A8);
  static const Color danger = Color(0xFFE5484D);
  static const Color verifiedGreen = Color(0xFF2E9E6B);
  static const Color onlineGreen = Color(0xFF2E9E6B);

  // Radii
  static const double radiusCard = 24;
  static const double radiusTile = 20;
  static const double radiusPromo = 20;
  static const double radiusPill = 999;

  // Spacing
  static const double pagePadding = 20;
  static const double gap = 16;
  static const double gapSm = 8;
  static const double gapLg = 24;
  static const double bottomInset = 32;

  // Sizes
  static const double avatarSize = 100;
  static const double circleButton = 44;
  static const double chipHeight = 34;
  static const double buttonHeight = 56;
  static const double rowHeight = 58;

  // Gradients
  static const LinearGradient brand = LinearGradient(
    colors: [pink, purple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient background = LinearGradient(
    colors: [bgTop, bgBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: purple.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get brandShadow => [
    BoxShadow(
      color: pink.withOpacity(0.30),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  // Text styles
  static TextStyle title = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: navy,
    height: 1.15,
  );
  static TextStyle subtitle = GoogleFonts.poppins(fontSize: 12, color: grey);
  static TextStyle section = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: navy,
  );
  static TextStyle settingsSection = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: navy,
  );
  static TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    color: grey,
    height: 1.5,
  );
  static TextStyle small = GoogleFonts.poppins(fontSize: 12, color: grey);
  static TextStyle link = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: purple,
  );
  static TextStyle rowLabel = GoogleFonts.poppins(
    fontSize: 15,
    color: navy,
    fontWeight: FontWeight.w500,
  );
}
