import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dating_app/utils/profile_theme.dart';

/// Tokens for the People (swipe) screen: colors, radii, spacing, durations
/// and gesture thresholds in one place.
class SwipeTheme {
  SwipeTheme._();

  // Colors
  static const Color pink = ProfileTheme.pink;
  static const Color purple = ProfileTheme.purple;
  static const Color labelGrey = Color(0xFF6F6A85);
  static const Color passRed = Color(0xFFE5484D);
  static const Color superBlue = Color(0xFF3B9BF5);
  static const Color activeGreen = Color(0xFF1F8A5B);
  static const Color activeDot = Color(0xFF2EC27E);
  static const Color nopeRed = Color(0xFFE5484D);
  static const Color likeGreen = Color(0xFF2EC27E);

  static const LinearGradient brand = ProfileTheme.brand;
  static const LinearGradient background = ProfileTheme.background;

  // Radii / sizes
  static const double cardRadius = 28;
  static const double pagePadding = 16;
  static const double actionSize = 64;
  static const double likeSize = 76;
  static const double actionIcon = 28;
  static const double chipHeight = 30;
  static const double expandSize = 40;
  static const double overlayPadding = 20;
  static const double progressHeight = 3;
  static const double progressGap = 4;
  static const double progressInset = 12;
  static const double glassBlur = 12;

  // Stack
  static const double backScale = 0.95;
  static const double backOffsetY = 10;
  static const double backOpacity = 0.7;

  // Gesture thresholds
  static const double swipeFraction = 0.35; // of width
  static const double superLikeFraction = 0.22; // of card height
  static const double flingVelocity = 900; // px / second
  static const double maxRotation = 12 * math.pi / 180;
  static const double edgeBounce = 6;

  // Durations
  static const Duration photoFade = Duration(milliseconds: 150);
  static const Duration flyOff = Duration(milliseconds: 350);
  static const Duration springBack = Duration(milliseconds: 450);
  static const Duration press = Duration(milliseconds: 110);
  static const Duration bounce = Duration(milliseconds: 260);
  static const Duration autoAdvance = Duration(seconds: 5);

  // Text
  static TextStyle name = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
  static TextStyle subtitle = GoogleFonts.poppins(
    color: Colors.white.withOpacity(0.9),
    fontSize: 15,
  );
  static TextStyle pill = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ProfileTheme.navy,
  );
  static TextStyle chip = GoogleFonts.poppins(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static TextStyle actionLabel = GoogleFonts.poppins(
    fontSize: 12,
    color: labelGrey,
  );
}
