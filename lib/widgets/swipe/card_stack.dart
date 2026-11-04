import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/utils/swipe_theme.dart';
import 'package:dating_app/widgets/swipe/profile_card.dart';
import 'package:dating_app/widgets/swipe/swipe_stamp.dart';

/// Lets buttons outside the stack trigger the same animations as a drag.
class CardStackController {
  _CardStackState? _state;

  /// Flies the top card off in [action]'s direction, then fires `onSwipe`.
  Future<void> swipe(SwipeAction action) async => _state?._flyOff(action);

  /// Flies the card that [lastAction] removed back in. [restore] puts the
  /// profile back in the deck and returns false if that failed.
  Future<void> rewind({
    required SwipeAction lastAction,
    required bool Function() restore,
  }) async => _state?._rewind(lastAction, restore);
}

/// Top card + next card peeking behind it, with drag / fling / spring-back.
class CardStack extends StatefulWidget {
  const CardStack({
    super.key,
    required this.profiles,
    required this.onSwipe,
    required this.onExpand,
    this.controller,
    this.enabled = true,
    this.distanceLabel,
    this.autoAdvance = false,
  });

  /// Top card first.
  final List<UserModel> profiles;
  final CardStackController? controller;

  /// False blocks dragging and programmatic swipes (e.g. swipe in flight).
  final bool enabled;

  /// Called once the card has left the screen.
  final Future<void> Function(UserModel profile, SwipeAction action) onSwipe;
  final void Function(UserModel profile) onExpand;
  final String? Function(UserModel profile)? distanceLabel;
  final bool autoAdvance;

  @override
  State<CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<CardStack>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<Offset> _offset = ValueNotifier(Offset.zero);
  late final AnimationController _anim;

  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  Size _size = Size.zero;
  bool _busy = false;
  bool _rewinding = false;
  SwipeAction? _lastIntent;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController.unbounded(vsync: this)..addListener(_onTick);
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(CardStack old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._state = null;
      widget.controller?._state = this;
    }
    final oldTop = old.profiles.isEmpty ? null : old.profiles.first.id;
    final newTop = widget.profiles.isEmpty ? null : widget.profiles.first.id;
    // A new card is on top: it starts centred and the stack is ready again
    // (the previous swipe may still be sending in the background).
    if (oldTop != newTop && !_rewinding) {
      _anim.stop();
      _offset.value = Offset.zero;
      _busy = false;
      _lastIntent = null;
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _anim.dispose();
    _offset.dispose();
    super.dispose();
  }

  void _onTick() {
    _offset.value = Offset.lerp(_from, _to, _anim.value) ?? _to;
  }

  // --- intent ------------------------------------------------------------

  double get _thresholdX => _size.width * SwipeTheme.swipeFraction;
  double get _thresholdY => _size.height * SwipeTheme.superLikeFraction;

  /// What releasing now would do; null = spring back.
  SwipeAction? _intent(Offset o, [Offset v = Offset.zero]) {
    final horizontal = o.dx.abs() >= o.dy.abs();
    if (horizontal) {
      final fast =
          v.dx.abs() > SwipeTheme.flingVelocity &&
          v.dx.sign == o.dx.sign &&
          o.dx.abs() > 24;
      if (o.dx.abs() >= _thresholdX || fast) {
        return o.dx > 0 ? SwipeAction.like : SwipeAction.dislike;
      }
    } else if (o.dy < 0) {
      final fast = v.dy < -SwipeTheme.flingVelocity && o.dy < -24;
      if (-o.dy >= _thresholdY || fast) return SwipeAction.superLike;
    }
    return null;
  }

  bool get _canDrag => widget.enabled && !_busy && widget.profiles.isNotEmpty;

  // --- gestures ----------------------------------------------------------

  void _onPanStart(DragStartDetails d) {
    if (!_canDrag) return;
    _anim.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_canDrag) return;
    _offset.value += d.delta;
    final intent = _intent(_offset.value);
    if (intent != null && intent != _lastIntent) HapticFeedback.lightImpact();
    _lastIntent = intent;
  }

  void _onPanEnd(DragEndDetails d) {
    if (!_canDrag) return;
    final intent = _intent(_offset.value, d.velocity.pixelsPerSecond);
    _lastIntent = null;
    if (intent != null) {
      _flyOff(intent);
    } else {
      _springBack();
    }
  }

  // --- animations --------------------------------------------------------

  Future<void> _springBack() async {
    _from = _offset.value;
    _to = Offset.zero;
    _anim.value = 0;
    await _anim.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 320, damping: 20),
        0,
        1,
        0,
      ),
    );
    _offset.value = Offset.zero;
  }

  Future<void> _tweenTo(Offset to, Curve curve) async {
    _from = _offset.value;
    _to = to;
    _anim.value = 0;
    await _anim.animateTo(1, duration: SwipeTheme.flyOff, curve: curve);
    _offset.value = to;
  }

  Offset _offscreen(SwipeAction a, {double dy = 0}) => switch (a) {
    SwipeAction.like => Offset(_size.width * 1.6, dy),
    SwipeAction.dislike => Offset(-_size.width * 1.6, dy),
    SwipeAction.superLike => Offset(0, -_size.height * 1.4),
  };

  Future<void> _flyOff(SwipeAction action) async {
    if (!_canDrag) return;
    final profile = widget.profiles.first;
    _busy = true;
    _lastIntent = null;
    HapticFeedback.lightImpact();
    final dy = action == SwipeAction.superLike ? 0.0 : _offset.value.dy * 0.4;
    await _tweenTo(_offscreen(action, dy: dy), Curves.easeInOutCubic);
    if (!mounted) return;

    await widget.onSwipe(profile, action);
    if (!mounted) return;

    // The deck normally advanced already (didUpdateWidget reset us). If it
    // did not, bring the card back rather than leaving it off-screen.
    if (_busy && widget.profiles.isNotEmpty && widget.profiles.first.id == profile.id) {
      _offset.value = Offset.zero;
      _busy = false;
    }
  }

  Future<void> _rewind(SwipeAction last, bool Function() restore) async {
    if (_busy || _rewinding || !mounted) return;
    _busy = true;
    _rewinding = true;
    _anim.stop();
    // Start off-screen on the side the card left from, before it is restored,
    // so its first frame is not a pop-in at the centre.
    _offset.value = _offscreen(last);
    final ok = restore();
    if (!ok) {
      _offset.value = Offset.zero;
      _busy = false;
      _rewinding = false;
      return;
    }
    HapticFeedback.lightImpact();
    await _tweenTo(Offset.zero, Curves.easeOutCubic);
    _rewinding = false;
    _busy = false;
  }

  // --- build -------------------------------------------------------------

  /// 0..1 how far the top card is dragged toward a decision.
  double _progress(Offset o) {
    if (_size.isEmpty) return 0;
    final h = (o.dx.abs() / _thresholdX);
    final v = o.dy < 0 ? (-o.dy / _thresholdY) : 0.0;
    return math.max(h, v).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        _size = c.biggest;
        final profiles = widget.profiles;
        if (profiles.isEmpty) return const SizedBox.shrink();
        final top = profiles.first;
        final next = profiles.length > 1 ? profiles[1] : null;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (next != null)
              Positioned.fill(
                key: ValueKey('back-${next.id}'),
                child: ValueListenableBuilder<Offset>(
                  valueListenable: _offset,
                  child: IgnorePointer(
                    child: ProfileCard(
                      key: ValueKey('card-${next.id}'),
                      profile: next,
                      distanceLabel: widget.distanceLabel?.call(next),
                    ),
                  ),
                  builder: (_, o, child) {
                    final p = Curves.easeOut.transform(_progress(o));
                    return Opacity(
                      opacity:
                          SwipeTheme.backOpacity +
                          (1 - SwipeTheme.backOpacity) * p,
                      child: Transform.translate(
                        offset: Offset(0, SwipeTheme.backOffsetY * (1 - p)),
                        child: Transform.scale(
                          scale:
                              SwipeTheme.backScale +
                              (1 - SwipeTheme.backScale) * p,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            Positioned.fill(
              key: ValueKey('top-${top.id}'),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: ValueListenableBuilder<Offset>(
                  valueListenable: _offset,
                  child: ProfileCard(
                    key: ValueKey('card-${top.id}'),
                    profile: top,
                    distanceLabel: widget.distanceLabel?.call(top),
                    onExpand: () => widget.onExpand(top),
                    autoAdvance: widget.autoAdvance,
                  ),
                  builder: (_, o, child) {
                    final rot =
                        (o.dx / (_size.width * 0.5)).clamp(-1.0, 1.0) *
                        SwipeTheme.maxRotation;
                    final horizontal = o.dx.abs() >= o.dy.abs();
                    double like = 0, nope = 0, sup = 0;
                    if (!_rewinding && _size.width > 0) {
                      if (horizontal) {
                        final t = (o.dx.abs() / _thresholdX).clamp(0.0, 1.0);
                        o.dx > 0 ? like = t : nope = t;
                      } else if (o.dy < 0) {
                        sup = (-o.dy / _thresholdY).clamp(0.0, 1.0);
                      }
                    }
                    return Transform.translate(
                      offset: o,
                      child: Transform.rotate(
                        angle: rot,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            child!,
                            IgnorePointer(
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 72,
                                    left: 24,
                                    child: SwipeStamp(
                                      label: 'LIKE',
                                      colors: const [
                                        SwipeTheme.likeGreen,
                                        SwipeTheme.pink,
                                      ],
                                      angleDegrees: -15,
                                      opacity: like,
                                    ),
                                  ),
                                  Positioned(
                                    top: 72,
                                    right: 24,
                                    child: SwipeStamp(
                                      label: 'NOPE',
                                      colors: const [
                                        SwipeTheme.nopeRed,
                                        Color(0xFFFF7A59),
                                      ],
                                      angleDegrees: 15,
                                      opacity: nope,
                                    ),
                                  ),
                                  Center(
                                    child: SwipeStamp(
                                      label: 'SUPER LIKE',
                                      colors: const [
                                        SwipeTheme.superBlue,
                                        Color(0xFF6C7BFF),
                                      ],
                                      angleDegrees: 0,
                                      opacity: sup,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
