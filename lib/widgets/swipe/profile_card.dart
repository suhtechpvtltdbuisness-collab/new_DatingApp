import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/utils/swipe_theme.dart';
import 'package:dating_app/widgets/swipe/glass.dart';
import 'package:dating_app/widgets/swipe/photo_carousel.dart';
import 'package:dating_app/widgets/swipe/story_progress_bar.dart';

/// The swipe card: photo, story bars, pills, name, chips, expand button.
/// Tap right/left half = next/previous photo; long press peeks at the photo.
/// Give it a `ValueKey(profile.id)` so the photo index resets per profile.
class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    this.distanceLabel,
    this.onExpand,
    this.autoAdvance = false,
  });

  final UserModel profile;
  final String? distanceLabel;
  final VoidCallback? onExpand;
  final bool autoAdvance;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with TickerProviderStateMixin {
  int _index = 0;
  bool _peeking = false;
  double _bounceDir = 0;

  late final AnimationController _bounce;
  late final AnimationController _auto;

  late List<String> _urls = _cleanUrls(widget.profile);

  static List<String> _cleanUrls(UserModel p) =>
      p.photoUrls.where((u) => u.trim().isNotEmpty).toList();

  int get _count => math.max(_urls.length, 1);

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(vsync: this, duration: SwipeTheme.bounce);
    _auto = AnimationController(vsync: this, duration: SwipeTheme.autoAdvance)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next(auto: true);
      });
    if (widget.autoAdvance && _count > 1) _auto.forward();
  }

  @override
  void didUpdateWidget(ProfileCard old) {
    super.didUpdateWidget(old);
    // More photos can arrive after the card is on screen.
    if (old.profile.photoUrls != widget.profile.photoUrls) {
      _urls = _cleanUrls(widget.profile);
      if (_index >= _count) _index = _count - 1;
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    _auto.dispose();
    super.dispose();
  }

  void _next({bool auto = false}) {
    if (_index >= _count - 1) {
      if (!auto) _nudge(1);
      return;
    }
    setState(() => _index++);
    if (widget.autoAdvance) _auto.forward(from: 0);
  }

  void _previous() {
    if (_index <= 0) {
      _nudge(-1);
      return;
    }
    setState(() => _index--);
    if (widget.autoAdvance) _auto.forward(from: 0);
  }

  void _nudge(double dir) {
    _bounceDir = dir;
    _bounce.forward(from: 0);
  }

  void _onTapUp(TapUpDetails d, double width) {
    if (_count <= 1) return;
    d.localPosition.dx >= width / 2 ? _next() : _previous();
  }

  String? get _subtitle {
    final p = widget.profile;
    final parts =
        [
          p.work,
          p.city,
          p.height,
        ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final name = p.firstName.trim().isNotEmpty ? p.firstName.trim() : p.fullName;
    final nameLine = p.age > 0 ? '$name, ${p.age}' : name;
    final subtitle = _subtitle;
    final interests =
        p.interests.where((i) => i.trim().isNotEmpty).take(3).toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SwipeTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: SwipeTheme.purple.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SwipeTheme.cardRadius),
        child: LayoutBuilder(
          builder: (context, c) {
            return AnimatedBuilder(
              animation: _bounce,
              builder:
                  (_, child) => Transform.translate(
                    offset: Offset(
                      _bounceDir *
                          SwipeTheme.edgeBounce *
                          math.sin(math.pi * _bounce.value),
                      0,
                    ),
                    child: child,
                  ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PhotoCarousel(urls: _urls, index: _index),
                  // Bottom scrim, ~40% of the card height.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: c.maxHeight * 0.4,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.65),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tap zones + peek. Interactive overlay pieces sit above.
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (d) => _onTapUp(d, c.maxWidth),
                      onLongPressStart: (_) => setState(() => _peeking = true),
                      onLongPressEnd: (_) => setState(() => _peeking = false),
                      onLongPressCancel: () => setState(() => _peeking = false),
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: _peeking ? 0 : 1,
                      duration: SwipeTheme.photoFade,
                      child: Stack(
                        children: [
                          _topOverlay(p),
                          _bottomOverlay(nameLine, subtitle, interests, p),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topOverlay(UserModel p) {
    final distance = widget.distanceLabel;
    return Positioned(
      top: SwipeTheme.progressInset,
      left: SwipeTheme.progressInset,
      right: SwipeTheme.progressInset,
      child: IgnorePointer(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _auto,
              builder:
                  (_, __) => StoryProgressBar(
                    count: _count,
                    index: _index,
                    currentProgress: widget.autoAdvance ? _auto.value : 1,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (p.isOnline)
                  const GlassPill(
                    label: 'Active now',
                    dotColor: SwipeTheme.activeDot,
                  )
                else
                  const SizedBox.shrink(),
                if (distance != null)
                  GlassPill(label: distance, icon: Icons.location_on_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomOverlay(
    String nameLine,
    String? subtitle,
    List<String> interests,
    UserModel p,
  ) {
    return Positioned(
      left: SwipeTheme.overlayPadding,
      right: SwipeTheme.overlayPadding,
      bottom: SwipeTheme.overlayPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: IgnorePointer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              nameLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SwipeTheme.name,
                            ),
                          ),
                          if (p.isVerified) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwipeTheme.subtitle,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (widget.onExpand != null) ...[
                const SizedBox(width: 12),
                GlassCircleButton(
                  icon: Icons.north_east_rounded,
                  onTap: widget.onExpand,
                ),
              ],
            ],
          ),
          if (interests.isNotEmpty) ...[
            const SizedBox(height: 14),
            // Absorb taps so the chips area never changes photo.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: SizedBox(
                height: SwipeTheme.chipHeight,
                child: ClipRect(
                  child: Row(
                    children: [
                      for (var i = 0; i < interests.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Flexible(child: GlassChip(label: interests[i])),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
