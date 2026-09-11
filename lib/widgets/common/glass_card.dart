import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';

/// A frosted-glass surface: soft blur + translucent fill + hairline border.
/// Use this instead of a plain [Card] / [Container] for the app's signature
/// "glassmorphism" look on top of gradient backgrounds.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = AppTheme.radiusLg,
    this.dark = false,
    this.blurSigma = 18,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool dark;
  final double blurSigma;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      decoration: AppTheme.glassDecoration(radius: radius, dark: dark),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AppBlur.backdrop(
          sigma: blurSigma,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
