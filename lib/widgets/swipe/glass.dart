import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dating_app/utils/swipe_theme.dart';

class _Glass extends StatelessWidget {
  const _Glass({
    required this.child,
    required this.fill,
    required this.height,
    this.border,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  final Widget child;
  final Color fill;
  final double? height;
  final Border? border;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: SwipeTheme.glassBlur,
          sigmaY: SwipeTheme.glassBlur,
        ),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            border: border,
            borderRadius: BorderRadius.circular(999),
          ),
          // widthFactor keeps the pill wrapping its content.
          child: Center(widthFactor: 1, child: child),
        ),
      ),
    );
  }
}

/// Frosted white pill used for "Active now" and the distance badge.
class GlassPill extends StatelessWidget {
  const GlassPill({super.key, required this.label, this.icon, this.dotColor});

  final String label;
  final IconData? icon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return _Glass(
      fill: Colors.white.withOpacity(0.8),
      height: 30,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF1E1B3A)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: SwipeTheme.pill.copyWith(
              color: dotColor != null
                  ? SwipeTheme.activeGreen
                  : const Color(0xFF1E1B3A),
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted translucent chip for interests on the dark photo overlay.
class GlassChip extends StatelessWidget {
  const GlassChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return _Glass(
      fill: Colors.white.withOpacity(0.2),
      height: SwipeTheme.chipHeight,
      border: Border.all(color: Colors.white.withOpacity(0.4)),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(label, maxLines: 1, style: SwipeTheme.chip),
    );
  }
}

/// Round frosted button (the expand arrow).
class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: SwipeTheme.glassBlur,
            sigmaY: SwipeTheme.glassBlur,
          ),
          child: Container(
            width: SwipeTheme.expandSize,
            height: SwipeTheme.expandSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
