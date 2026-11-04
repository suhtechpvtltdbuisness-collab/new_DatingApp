import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LIKE / NOPE / SUPER LIKE stamp. [opacity] follows the drag distance.
class SwipeStamp extends StatelessWidget {
  const SwipeStamp({
    super.key,
    required this.label,
    required this.colors,
    required this.angleDegrees,
    required this.opacity,
  });

  final String label;
  final List<Color> colors;
  final double angleDegrees;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();
    final gradient = LinearGradient(colors: colors);
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.rotate(
        angle: angleDegrees * math.pi / 180,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.28),
              borderRadius: BorderRadius.circular(11),
            ),
            child: ShaderMask(
              shaderCallback: (rect) => gradient.createShader(rect),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
