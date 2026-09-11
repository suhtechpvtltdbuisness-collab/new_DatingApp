import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';

/// Standard page shell for content/settings-style screens: soft gradient
/// backdrop, a consistent back-button + title header, and safe-area
/// padding. Keeps every secondary screen visually consistent with the
/// bold-gradient / glassmorphism design system without repeating
/// boilerplate in every file.
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.gradient,
    this.showBack = true,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
    this.bottom,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Gradient? gradient;
  final bool showBack;
  final EdgeInsetsGeometry padding;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: gradient ?? AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
                child: Row(
                  children: [
                    if (showBack)
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textPrimaryColor, size: 20),
                      )
                    else
                      const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
              Expanded(child: Padding(padding: padding, child: body)),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }
}
