import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================
/// SUH Tech Vellora — Design System
/// "Bold Gradient / Glassmorphism"
/// A single source of truth for color, gradient, typography and
/// glass-surface tokens used across the entire app.
/// ============================================================
class AppTheme {
  // ---------------------------------------------------------
  // Brand palette
  // ---------------------------------------------------------
  static const Color primaryColor = Color(0xFFFF3D77); // Hot rose
  static const Color primaryDarkColor = Color(0xFFD81159); // Deep rose (pressed / gradient stop)
  static const Color accentColor = Color(0xFF8B5CF6); // Vivid violet
  static const Color accentDeepColor = Color(0xFF6D28D9); // Deep violet
  static const Color warmAccentColor = Color(0xFFFF8A5C); // Warm coral/orange highlight
  static const Color goldColor = Color(0xFFFFC94D); // Premium/verified badge gold

  static const Color backgroundColor = Color(0xFFFFF6FA);
  static const Color darkBackgroundColor = Color(0xFF130A21);
  static const Color surfaceColor = Colors.white;
  static const Color darkSurfaceColor = Color(0xFF231433);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF1B1130);
  static const Color textSecondaryColor = Color(0xFF6B6178);
  static const Color textTertiaryColor = Color(0xFF9C93A8);
  static const Color textLightColor = Color(0xFFFFFFFF);

  // Status Colors
  static const Color successColor = Color(0xFF33D69F);
  static const Color errorColor = Color(0xFFFF4470);
  static const Color warningColor = Color(0xFFFFC94D);
  static const Color infoColor = Color(0xFF4DA3FF);

  // Swipe Colors
  static const Color acceptColor = Color(0xFF33D69F); // Green for accept/like
  static const Color rejectColor = Color(0xFFFF4470); // Rose-red for reject
  static const Color superLikeColor = Color(0xFF4DC4FF); // Sky blue for super like

  // Neutral Colors
  static const Color dividerColor = Color(0xFFEFE6F5);
  static const Color darkDividerColor = Color(0xFF3A2A50);
  static const Color disabledColor = Color(0xFFC9C2D6);
  static const Color inputFillColor = Color(0xFFFAF3FB);
  static const Color inputBorderColor = Color(0xFFEEDFF3);
  static const Color inputFocusBorderColor = Color(0xFFFF3D77);

  // ---------------------------------------------------------
  // Glass-surface tokens (glassmorphism)
  // ---------------------------------------------------------
  static Color glassFillLight = Colors.white.withOpacity(0.55);
  static Color glassFillLightSubtle = Colors.white.withOpacity(0.35);
  static Color glassFillDark = Colors.white.withOpacity(0.08);
  static Color glassBorderLight = Colors.white.withOpacity(0.55);
  static Color glassBorderDark = Colors.white.withOpacity(0.14);
  static Color glassShadow = const Color(0xFF7C1349).withOpacity(0.18);

  /// Frosted-glass container decoration. Pair with a `BackdropFilter`
  /// (see `GlassCard` widget) for the true blur effect.
  static BoxDecoration glassDecoration({
    double radius = 24,
    bool dark = false,
    double borderWidth = 1.2,
  }) {
    return BoxDecoration(
      color: dark ? glassFillDark : glassFillLight,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: dark ? glassBorderDark : glassBorderLight,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: glassShadow,
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------

  /// The signature brand gradient — rose → magenta → violet.
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFF3D77), Color(0xFFCC3AA6), Color(0xFF8B5CF6)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft pastel wash used behind content screens.
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFE3ED), Color(0xFFF6E4FB), Color(0xFFEAE3FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Deep, moody wash used behind dark-mode / immersive screens.
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF1A0E2E), Color(0xFF2B1245), Color(0xFF130A21)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient buttonGradient = const LinearGradient(
    colors: [Color(0xFFFF3D77), Color(0xFFFF6F91)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient rejectGradient = const LinearGradient(
    colors: [rejectColor, Color(0xFFFF8AA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient acceptGradient = const LinearGradient(
    colors: [acceptColor, Color(0xFF6FF0C3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient superLikeGradient = const LinearGradient(
    colors: [superLikeColor, Color(0xFF7FD8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient goldGradient = const LinearGradient(
    colors: [Color(0xFFFFC94D), Color(0xFFFF8A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ---------------------------------------------------------
  // Shape / spacing tokens
  // ---------------------------------------------------------
  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusPill = 999;

  static List<BoxShadow> softShadow({Color? color}) => [
        BoxShadow(
          color: (color ?? primaryColor).withOpacity(0.18),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  static OutlineInputBorder _inputBorder(
    Color color, {
    double width = 1.2,
    double radius = 18,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static InputDecoration borderlessInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? counterText,
    EdgeInsetsGeometry contentPadding = EdgeInsets.zero,
    bool isDense = false,
    // Set true for fixed-height pill fields: it drops the decorator's
    // reserved vertical space, which otherwise pushes the text below centre.
    bool isCollapsed = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: textTertiaryColor),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: counterText,
      isDense: isDense,
      isCollapsed: isCollapsed,
      filled: false,
      fillColor: Colors.transparent,
      contentPadding: contentPadding,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );
  }

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    splashFactory: InkRipple.splashFactory,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      tertiary: warmAccentColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimaryColor),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiaryColor,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: _inputBorder(inputBorderColor),
      enabledBorder: _inputBorder(inputBorderColor),
      focusedBorder: _inputBorder(inputFocusBorderColor),
      errorBorder: _inputBorder(errorColor),
      focusedErrorBorder: _inputBorder(errorColor),
      disabledBorder: _inputBorder(dividerColor.withOpacity(0.6)),
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: textTertiaryColor),
      labelStyle: GoogleFonts.poppins(fontSize: 14, color: textSecondaryColor),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
    ),
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 16,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textTertiaryColor,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      tertiary: warmAccentColor,
      surface: darkSurfaceColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textLightColor),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textLightColor,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        .copyWith(
          displayLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textLightColor,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textLightColor,
          ),
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: _inputBorder(darkDividerColor),
      enabledBorder: _inputBorder(darkDividerColor),
      focusedBorder: _inputBorder(inputFocusBorderColor),
      errorBorder: _inputBorder(errorColor),
      focusedErrorBorder: _inputBorder(errorColor),
      disabledBorder: _inputBorder(darkDividerColor.withOpacity(0.6)),
    ),
    cardTheme: CardThemeData(
      color: darkSurfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textTertiaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

/// Re-usable blur helper so screens don't need to import `dart:ui` directly.
class AppBlur {
  static Widget backdrop({
    required Widget child,
    double sigma = 18,
    BorderRadius? borderRadius,
  }) {
    final content = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
    if (borderRadius == null) return content;
    return ClipRRect(borderRadius: borderRadius, child: content);
  }
}
