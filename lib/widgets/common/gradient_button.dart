import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';

/// A pill-shaped, gradient-filled call-to-action button with a soft glow.
/// This is the primary button style used across onboarding, auth and
/// action sheets to give the app a bold, modern feel.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient,
    this.icon,
    this.height = 56,
    this.fullWidth = true,
    this.isLoading = false,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Widget? icon;
  final double height;
  final bool fullWidth;
  final bool isLoading;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final grad = gradient ?? AppTheme.buttonGradient;
    final disabled = onPressed == null || isLoading;

    return Opacity(
      opacity: disabled && isLoading == false ? 0.6 : 1,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: grad,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            boxShadow: AppTheme.softShadow(),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              onTap: isLoading ? null : onPressed,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[icon!, const SizedBox(width: 10)],
                          Text(
                            label,
                            style: textStyle ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A secondary, outlined pill button that sits well on gradient backgrounds.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 56,
    this.fullWidth = true,
    this.borderColor = Colors.white,
    this.textColor = Colors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool fullWidth;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor.withOpacity(0.7), width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
