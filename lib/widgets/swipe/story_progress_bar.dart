import 'package:flutter/material.dart';
import 'package:dating_app/utils/swipe_theme.dart';

/// One thin segment per photo. Past and current segments are white, upcoming
/// ones are dimmed. [currentProgress] (0..1) fills the current segment when
/// auto-advance is on; otherwise it is simply full.
class StoryProgressBar extends StatelessWidget {
  const StoryProgressBar({
    super.key,
    required this.count,
    required this.index,
    this.currentProgress = 1,
  });

  final int count;
  final int index;
  final double currentProgress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: SwipeTheme.progressGap),
          Expanded(child: _Segment(fill: _fillFor(i))),
        ],
      ],
    );
  }

  double _fillFor(int i) {
    if (i < index) return 1;
    if (i == index) return currentProgress.clamp(0.0, 1.0);
    return 0;
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.fill});

  final double fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: SwipeTheme.progressHeight,
        color: Colors.white.withOpacity(0.35),
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: SwipeTheme.photoFade,
          widthFactor: fill,
          heightFactor: 1,
          child: Container(color: Colors.white),
        ),
      ),
    );
  }
}
