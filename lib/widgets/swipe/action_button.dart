import 'package:flutter/material.dart';
import 'package:dating_app/utils/swipe_theme.dart';

/// Round action button with a soft glow, a label underneath and a press
/// animation (scale 0.92, springing back). [onTap] null = disabled (40%).
class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.size = SwipeTheme.actionSize,
    this.gradient,
    this.bold = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double size;
  final Gradient? gradient;
  final bool bold;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.gradient != null;
    final enabled = widget.onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _set(true),
            onTapUp: (_) => _set(false),
            onTapCancel: () => _set(false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _down ? 0.92 : 1,
              duration: SwipeTheme.press,
              curve: Curves.easeOutBack,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: filled ? null : Colors.white,
                  gradient: widget.gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(filled ? 0.40 : 0.30),
                      blurRadius: filled ? 22 : 20,
                      offset: Offset(0, filled ? 10 : 6),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: SwipeTheme.actionIcon,
                  color: filled ? Colors.white : widget.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: SwipeTheme.actionLabel.copyWith(
              fontWeight: widget.bold ? FontWeight.w700 : FontWeight.w400,
              color: widget.bold ? SwipeTheme.purple : SwipeTheme.labelGrey,
            ),
          ),
        ],
      ),
    );
  }
}
