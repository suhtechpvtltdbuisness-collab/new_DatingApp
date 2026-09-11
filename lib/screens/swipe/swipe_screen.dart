import 'dart:math' as math;

import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with SingleTickerProviderStateMixin {
  final SwipeController swipeController = Get.find<SwipeController>();

  late final AnimationController _swipeAnimationController;

  Offset _dragOffset = Offset.zero;
  Animation<Offset>? _offsetAnimation;
  bool _isAnimatingSwipe = false;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    if (swipeController.profiles.isEmpty && !swipeController.isLoading.value) {
      swipeController.loadProfiles(refresh: true);
    }
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handlePanEnd(BoxConstraints constraints, UserModel profile) async {
    final threshold = constraints.maxWidth * AppConstants.swipeThreshold;
    final shouldCommit = _dragOffset.dx.abs() >= threshold &&
        _dragOffset.dx.abs() > _dragOffset.dy.abs();

    if (!shouldCommit) {
      await _runCardAnimation(
        target: Offset.zero,
        markAsSwipe: false,
      );
      return;
    }

    final direction =
        _dragOffset.dx >= 0 ? SwipeAction.like : SwipeAction.dislike;
    await _commitSwipe(constraints, profile, direction);
  }

  Future<void> _commitSwipe(
    BoxConstraints constraints,
    UserModel profile,
    SwipeAction direction,
  ) async {
    final exitX = direction == SwipeAction.like
        ? constraints.maxWidth * 1.35
        : -constraints.maxWidth * 1.35;
    final exitOffset = Offset(exitX, _dragOffset.dy * 0.3);

    await _runCardAnimation(
      target: exitOffset,
      markAsSwipe: true,
    );

    final result = await swipeController.submitSwipe(
      profile: profile,
      action: direction,
    );

    if (!mounted) {
      return;
    }

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message.isEmpty ? 'Swipe failed. Please try again.' : result.message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              swipeController.clearMessages();
            },
          ),
        ),
      );
    } else if (direction == SwipeAction.like && result.isMatch) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchScreen(
            userName: profile.fullName,
            image1: 'assets/images/profile.png',
            image2: profile.profileImage.isNotEmpty
                ? profile.profileImage
                : 'assets/images/profile.png',
          ),
        ),
      );
    }

    _swipeAnimationController.reset();
    if (mounted) {
      setState(() {
        _dragOffset = Offset.zero;
        _offsetAnimation = null;
        _isAnimatingSwipe = false;
      });
    }
  }

  Future<void> _animateCardTo(Offset target) async {
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _swipeAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _swipeAnimationController
      ..reset()
      ..addListener(_animationListener);

    await _swipeAnimationController.forward();
    _swipeAnimationController.removeListener(_animationListener);
    _dragOffset = target;
  }

  Future<void> _runCardAnimation({
    required Offset target,
    required bool markAsSwipe,
  }) async {
    if (mounted) {
      setState(() {
        _isAnimatingSwipe = true;
      });
    }

    await _animateCardTo(target);

    if (mounted && !markAsSwipe) {
      setState(() {
        _isAnimatingSwipe = false;
      });
    }
  }

  void _animationListener() {
    final animatedOffset = _offsetAnimation?.value;
    if (animatedOffset == null || !mounted) {
      return;
    }

    setState(() {
      _dragOffset = animatedOffset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profiles = swipeController.profiles.toList(growable: false);

      if (swipeController.isLoading.value && profiles.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (profiles.isEmpty) {
        return _EmptyDeckState(
          message: swipeController.errorMessage.value.isEmpty
              ? 'No more profiles to show'
              : swipeController.errorMessage.value,
          onRetry: () => swipeController.loadProfiles(refresh: true),
        );
      }

      final topProfile = profiles.first;
      final canAct = !_isAnimatingSwipe && swipeController.canSwipe(topProfile.id);

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final swipeThreshold =
                constraints.maxWidth * AppConstants.swipeThreshold;
            final dragProgress =
                (_dragOffset.dx.abs() / swipeThreshold).clamp(0.0, 1.0);

            return Column(
              children: [
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(
                      math.min(profiles.length, 3),
                      (index) {
                        final profile = profiles[index];
                        final isTopCard = index == 0;

                        return _DeckLayer(
                          profile: profile,
                          depth: index,
                          dragProgress: dragProgress,
                          dragOffset: isTopCard ? _dragOffset : Offset.zero,
                          isTopCard: isTopCard,
                          onTapInfo: isTopCard
                              ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileDetailsScreen(profile: profile),
                                    ),
                                  )
                              : null,
                          onPanUpdate: isTopCard && canAct
                              ? (details) {
                                  setState(() {
                                    _dragOffset += details.delta;
                                  });
                                }
                              : null,
                          onPanEnd: isTopCard && canAct
                              ? (_) => _handlePanEnd(constraints, topProfile)
                              : null,
                        );
                      },
                    ).reversed.toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  swipeController.isLoadingMore.value
                      ? 'Loading more profiles...'
                      : swipeController.errorMessage.value,
                  style: TextStyle(
                    color: swipeController.errorMessage.value.isEmpty
                        ? Colors.transparent
                        : AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.close_rounded,
                      color: AppTheme.rejectColor,
                      size: 54,
                      iconSize: 26,
                      onTap: canAct ? () => _commitSwipe(constraints, topProfile, SwipeAction.dislike) : null,
                    ),
                    _ActionButton(
                      icon: Icons.star_rounded,
                      color: AppTheme.superLikeColor,
                      size: 46,
                      iconSize: 22,
                      onTap: canAct
                          ? () => _commitSwipe(constraints, topProfile, SwipeAction.like)
                          : null,
                    ),
                    _ActionButton(
                      icon: Icons.favorite_rounded,
                      color: AppTheme.primaryColor,
                      size: 62,
                      iconSize: 28,
                      gradient: AppTheme.heroGradient,
                      onTap: canAct ? () => _commitSwipe(constraints, topProfile, SwipeAction.like) : null,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    });
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 54,
    this.iconSize = 24,
    this.gradient,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: gradient == null ? Colors.white : null,
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: gradient == null ? color : Colors.white, size: iconSize),
        ),
      ),
    );
  }
}

class _DeckLayer extends StatelessWidget {
  const _DeckLayer({
    required this.profile,
    required this.depth,
    required this.dragProgress,
    required this.dragOffset,
    required this.isTopCard,
    this.onPanUpdate,
    this.onPanEnd,
    this.onTapInfo,
  });

  final UserModel profile;
  final int depth;
  final double dragProgress;
  final Offset dragOffset;
  final bool isTopCard;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final VoidCallback? onTapInfo;

  @override
  Widget build(BuildContext context) {
    final depthOffset = depth * 14.0;
    final baseScale = 1 - (depth * 0.04);
    final animatedScale = isTopCard
        ? 1.0
        : (baseScale + (dragProgress * 0.03)).clamp(0.88, 1.0);

    Widget card = Transform.translate(
      offset: isTopCard ? dragOffset : Offset(0, depthOffset - (dragProgress * 10)),
      child: Transform.rotate(
        angle: isTopCard ? dragOffset.dx / 900 : 0,
        child: Transform.scale(
          scale: animatedScale,
          alignment: Alignment.topCenter,
          child: _SwipeProfileCard(
            profile: profile,
            onTapInfo: onTapInfo,
            likeOpacity: isTopCard && dragOffset.dx > 0
                ? (dragOffset.dx.abs() / 120).clamp(0.0, 1.0)
                : 0,
            nopeOpacity: isTopCard && dragOffset.dx < 0
                ? (dragOffset.dx.abs() / 120).clamp(0.0, 1.0)
                : 0,
          ),
        ),
      ),
    );

    if (!isTopCard) {
      return Positioned.fill(
        top: depthOffset,
        child: card,
      );
    }

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: card,
      ),
    );
  }
}

class _SwipeProfileCard extends StatelessWidget {
  const _SwipeProfileCard({
    required this.profile,
    required this.likeOpacity,
    required this.nopeOpacity,
    this.onTapInfo,
  });

  final UserModel profile;
  final double likeOpacity;
  final double nopeOpacity;
  final VoidCallback? onTapInfo;

  @override
  Widget build(BuildContext context) {
    final image = profile.profileImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image.isNotEmpty)
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Image.asset('assets/images/profile.png', fit: BoxFit.cover),
            )
          else
            Image.asset('assets/images/profile.png', fit: BoxFit.cover),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.16),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 28,
            left: 24,
            child: Opacity(
              opacity: likeOpacity,
              child: _SwipeBadge(
                label: 'LIKE',
                color: AppTheme.acceptColor,
              ),
            ),
          ),
          Positioned(
            top: 28,
            right: 24,
            child: Opacity(
              opacity: nopeOpacity,
              child: _SwipeBadge(
                label: 'NOPE',
                color: AppTheme.rejectColor,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            '${profile.fullName}, ${profile.age}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (profile.isVerified)
                            const Padding(
                              padding: EdgeInsets.only(left: 8, bottom: 4),
                              child: Icon(Icons.verified_rounded, color: AppTheme.superLikeColor, size: 20),
                            ),
                        ],
                      ),
                    ),
                    if (onTapInfo != null)
                      GestureDetector(
                        onTap: onTapInfo,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
                if ((profile.city ?? '').isNotEmpty || (profile.country ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      [profile.city, profile.country]
                          .whereType<String>()
                          .where((value) => value.isNotEmpty)
                          .join(', '),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if ((profile.bio ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      profile.bio!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeBadge extends StatelessWidget {
  const _SwipeBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: label == 'LIKE' ? -0.15 : 0.15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 3),
          color: Colors.black.withValues(alpha: 0.18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _EmptyDeckState extends StatelessWidget {
  const _EmptyDeckState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(gradient: AppTheme.heroGradient, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchScreen extends StatelessWidget {
  const MatchScreen({
    super.key,
    required this.userName,
    required this.image1,
    required this.image2,
  });

  final String userName;
  final String image1;
  final String image2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "IT'S A MATCH!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -0.25,
                    child: Container(
                      width: 180,
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 4),
                        image: DecorationImage(
                          image: _imageProvider(image1),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(80, -40),
                    child: Transform.rotate(
                      angle: 0.25,
                      child: Container(
                        width: 180,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 4),
                          image: DecorationImage(
                            image: _imageProvider(image2),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      child: const Icon(Icons.favorite, color: AppTheme.primaryColor, size: 26),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                "You and $userName liked\neach other!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Start a conversation now with each other',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Say hello',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Keep swiping',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _imageProvider(String imagePath) {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    }
    return AssetImage(imagePath);
  }
}
