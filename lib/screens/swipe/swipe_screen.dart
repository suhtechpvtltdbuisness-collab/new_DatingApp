import 'dart:math' as math;

import 'package:dating_app/controllers/chat_controller.dart';
import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/chat/chat_screen.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';
import 'package:dating_app/utils/swipe_theme.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/profile/profile_widgets.dart';
import 'package:dating_app/widgets/swipe/action_button.dart';
import 'package:dating_app/widgets/swipe/card_stack.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final SwipeController swipeController = Get.find<SwipeController>();
  final CardStackController _stack = CardStackController();
  bool _isRewinding = false;
  Worker? _photoWorker;

  @override
  void initState() {
    super.initState();
    // Make sure the top cards have all their photos for the story viewer.
    _photoWorker = ever<List<UserModel>>(swipeController.profiles, (list) {
      for (final p in list.take(2)) {
        swipeController.hydratePhotos(p);
      }
    });
    for (final p in swipeController.profiles.take(2)) {
      swipeController.hydratePhotos(p);
    }
    if (swipeController.profiles.isEmpty && !swipeController.isLoading.value) {
      swipeController.loadProfiles(refresh: true);
    }
  }

  @override
  void dispose() {
    _photoWorker?.dispose();
    super.dispose();
  }

  /// Runs after the card has flown off: sends the swipe, reports a failure
  /// and opens the match screen. Same logic as before the redesign.
  Future<void> _onSwipe(UserModel profile, SwipeAction direction) async {
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
          content: Text(
            result.message.isEmpty
                ? 'Swipe failed. Please try again.'
                : result.message,
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              swipeController.clearMessages();
            },
          ),
        ),
      );
    } else if (direction != SwipeAction.dislike &&
        (result.isMatch || direction == SwipeAction.superLike)) {
      if (!Get.isRegistered<UserController>()) {
        Get.put(UserController());
      }
      final userController = Get.find<UserController>();
      if (userController.currentUser.value == null) {
        await userController.getMyProfile();
      }
      if (!mounted) return;

      final myPhoto = userController.currentUser.value?.profileImage ?? '';
      final matchedFromApi = result.match?.matchedUser;
      final theirPhotos =
          matchedFromApi?.photoUrls.isNotEmpty == true
              ? matchedFromApi!.photoUrls
              : profile.photoUrls;
      final theirPhoto = theirPhotos.isNotEmpty ? theirPhotos.first : '';

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => MatchScreen(
                matchedUserId:
                    matchedFromApi?.id.isNotEmpty == true
                        ? matchedFromApi!.id
                        : profile.id,
                userName:
                    (matchedFromApi?.fullName.trim().isNotEmpty == true)
                        ? matchedFromApi!.fullName
                        : profile.fullName,
                myImage: myPhoto,
                theirImage: theirPhoto,
                isSuperLike: direction == SwipeAction.superLike,
                isMutual: result.isMatch,
              ),
        ),
      );
    }
  }

  /// Brings the last swiped person back and flies their card in from the side
  /// it left on. Unlimited: usable as many times in a row as there is history.
  Future<void> _handleRewind() async {
    if (_isRewinding) return;
    final entry = swipeController.lastSwipe;
    if (entry == null) return;

    bool restore() {
      final result = swipeController.rewindLastSwipe();
      if (!result.success && mounted && result.message.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message)));
      }
      return result.success;
    }

    // Empty deck: there is no card stack on screen to animate.
    if (swipeController.profiles.isEmpty) {
      restore();
      return;
    }

    setState(() => _isRewinding = true);
    await _stack.rewind(lastAction: entry.action, restore: restore);
    if (mounted) setState(() => _isRewinding = false);
  }

  void _openDetails(UserModel profile) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileDetailsScreen(profile: profile)),
    );
  }

  /// Distance between me and [p] from stored coordinates, or null when
  /// either side has no usable location.
  String? _distanceLabel(UserModel? me, UserModel p) {
    bool valid(double lat, double lng) =>
        !(lat == 0 && lng == 0) && lat.abs() <= 90 && lng.abs() <= 180;
    if (me == null ||
        !valid(me.latitude, me.longitude) ||
        !valid(p.latitude, p.longitude)) {
      return null;
    }
    const r = 6371.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(p.latitude - me.latitude);
    final dLng = rad(p.longitude - me.longitude);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(me.latitude)) *
            math.cos(rad(p.latitude)) *
            math.pow(math.sin(dLng / 2), 2);
    final km = 2 * r * math.asin(math.sqrt(a.toDouble()));
    return km < 1 ? '<1 km' : '${km.round()} km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: SwipeTheme.background),
      child: Obx(() {
        final profiles = swipeController.profiles.toList(growable: false);

        if (swipeController.isLoading.value && profiles.isEmpty) {
          return const _SwipeSkeleton();
        }

        if (profiles.isEmpty) {
          return _EmptyDeckState(
            message: swipeController.errorMessage.value,
            onRetry: () => swipeController.loadProfiles(refresh: true),
            passedCount: swipeController.dislikedProfiles.length,
            onShowPassed: swipeController.recyclePassedProfiles,
            onRewind:
                swipeController.canRewind && !_isRewinding
                    ? _handleRewind
                    : null,
            rewindLabel: swipeController.lastSwipe?.profile.fullName ?? '',
          );
        }

        final top = profiles.first;
        final canAct = !_isRewinding && swipeController.canSwipe(top.id);
        final canRewind = !_isRewinding && swipeController.canRewind;
        final me =
            Get.isRegistered<UserController>()
                ? Get.find<UserController>().currentUser.value
                : null;
        final status =
            swipeController.isLoadingMore.value
                ? 'Loading more profiles...'
                : swipeController.errorMessage.value;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            SwipeTheme.pagePadding,
            4,
            SwipeTheme.pagePadding,
            8,
          ),
          child: Column(
            children: [
              Expanded(
                child: CardStack(
                  controller: _stack,
                  profiles: profiles,
                  enabled: canAct,
                  onSwipe: _onSwipe,
                  onExpand: _openDetails,
                  distanceLabel: (p) => _distanceLabel(me, p),
                ),
              ),
              if (status.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          swipeController.errorMessage.value.isEmpty
                              ? SwipeTheme.labelGrey
                              : AppTheme.errorColor,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionButton(
                    icon: Icons.close_rounded,
                    label: 'Pass',
                    color: SwipeTheme.passRed,
                    onTap:
                        canAct ? () => _stack.swipe(SwipeAction.dislike) : null,
                  ),
                  ActionButton(
                    icon: Icons.replay_rounded,
                    label: 'Rewind',
                    color: SwipeTheme.pink,
                    onTap: canRewind ? _handleRewind : null,
                  ),
                  ActionButton(
                    icon: Icons.star_outline_rounded,
                    label: 'Super like',
                    color: SwipeTheme.superBlue,
                    onTap:
                        canAct
                            ? () => _stack.swipe(SwipeAction.superLike)
                            : null,
                  ),
                  ActionButton(
                    icon: Icons.favorite_border_rounded,
                    label: 'Like',
                    color: SwipeTheme.pink,
                    size: SwipeTheme.likeSize,
                    gradient: SwipeTheme.brand,
                    bold: true,
                    onTap:
                        canAct ? () => _stack.swipe(SwipeAction.like) : null,
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      }),
    );
  }
}

/// Shimmering placeholder shown while the first page of profiles loads.
class _SwipeSkeleton extends StatelessWidget {
  const _SwipeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SwipeTheme.pagePadding,
        4,
        SwipeTheme.pagePadding,
        12,
      ),
      child: Column(
        children: [
          const Expanded(
            child: SizedBox.expand(
              child: SkeletonBox(radius: SwipeTheme.cardRadius),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              SkeletonBox(
                width: SwipeTheme.actionSize,
                height: SwipeTheme.actionSize,
                circle: true,
              ),
              SkeletonBox(
                width: SwipeTheme.actionSize,
                height: SwipeTheme.actionSize,
                circle: true,
              ),
              SkeletonBox(
                width: SwipeTheme.actionSize,
                height: SwipeTheme.actionSize,
                circle: true,
              ),
              SkeletonBox(
                width: SwipeTheme.likeSize,
                height: SwipeTheme.likeSize,
                circle: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyDeckState extends StatelessWidget {
  const _EmptyDeckState({
    required this.message,
    required this.onRetry,
    this.passedCount = 0,
    this.onShowPassed,
    this.onRewind,
    this.rewindLabel = '',
  });

  /// Error from the last load, if any. Shown under the subtitle.
  final String message;
  final VoidCallback onRetry;

  /// People the user passed on; they can be brought back to decide again.
  final int passedCount;
  final VoidCallback? onShowPassed;

  /// Set when there is a swipe to take back — passing the last card in the
  /// deck lands here, and that is exactly when a rewind is wanted most.
  final VoidCallback? onRewind;
  final String rewindLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: SwipeTheme.brand,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SwipeTheme.pink.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "You're all caught up",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1B3A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check back soon for more people',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: SwipeTheme.labelGrey,
              ),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: GradientButton(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                onTap: onRetry,
              ),
            ),
            if (passedCount > 0 && onShowPassed != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: 260,
                child: OutlineButton(
                  label: 'See $passedCount passed again',
                  icon: Icons.history_rounded,
                  height: 46,
                  onTap: onShowPassed,
                ),
              ),
            ],
            if (onRewind != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onRewind,
                icon: const Icon(Icons.replay_rounded, size: 20),
                label: Text(
                  rewindLabel.isEmpty
                      ? 'Bring back last profile'
                      : 'Bring back $rewindLabel',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: SwipeTheme.labelGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MatchScreen extends StatefulWidget {
  const MatchScreen({
    super.key,
    required this.matchedUserId,
    required this.userName,
    required this.myImage,
    required this.theirImage,
    this.isSuperLike = false,
    this.isMutual = true,
  });

  final String matchedUserId;
  final String userName;
  final String myImage;
  final String theirImage;
  final bool isSuperLike;

  /// False when a super like was sent but the other person hasn't liked back.
  final bool isMutual;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  bool _openingChat = false;

  Future<void> _sayHello() async {
    if (_openingChat) return;
    setState(() => _openingChat = true);

    final chatController = Get.find<ChatController>();
    final conv = await chatController.createChat(
      recipientId: widget.matchedUserId,
      initialMessage: 'Hello 👋',
    );

    if (!mounted) return;
    setState(() => _openingChat = false);

    if (conv == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            chatController.errorMessage.value.isNotEmpty
                ? chatController.errorMessage.value
                : 'Could not start a chat. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatScreen(
              chatId: conv.id,
              name: widget.userName,
              image:
                  widget.theirImage.isNotEmpty
                      ? widget.theirImage
                      : 'assets/images/profile.png',
            ),
      ),
    );
  }

  Widget _photoCard(String imageUrl, {required double angle}) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 180,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child:
              imageUrl.startsWith('http')
                  ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder:
                        (_, _, _) => Image.asset(
                          'assets/images/profile.png',
                          fit: BoxFit.cover,
                        ),
                  )
                  : Image.asset(
                    imageUrl.isNotEmpty
                        ? imageUrl
                        : 'assets/images/profile.png',
                    fit: BoxFit.cover,
                  ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // MUTUAL SUPER LIKE
  // ---------------------------------------------------------------------

  /// A photo card with a small super-like star badge on its top corner.
  Widget _superLikePhotoCard(String imageUrl, {required double angle}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _photoCard(imageUrl, angle: angle),
        Positioned(
          top: -6,
          right: -6,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.superLikeColor, AppTheme.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.superLikeColor.withValues(alpha: 0.7),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// Big glowing star with an orbit ring, overlapping the bottom of the cards.
  Widget _glowingSuperStar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder:
          (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
      child: SizedBox(
        width: 230,
        height: 130,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Orbit ring
            Transform.rotate(
              angle: -0.14,
              child: Container(
                width: 230,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(115, 27),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Glowing star
            ShaderMask(
              shaderCallback:
                  (rect) => const LinearGradient(
                    colors: [AppTheme.superLikeColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(rect),
              child: Icon(
                Icons.star_rounded,
                size: 124,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: AppTheme.superLikeColor.withValues(alpha: 0.9),
                    blurRadius: 36,
                  ),
                ],
              ),
            ),
            const Icon(Icons.bolt_rounded, color: Colors.white, size: 52),
          ],
        ),
      ),
    );
  }

  Widget _buildMutualSuperLike(BuildContext context) {
    final firstName = widget.userName.trim().split(' ').first;
    final lineColor = Colors.white.withValues(alpha: 0.35);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder:
                (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),

                        /// Header: star + "MUTUAL SUPER LIKE"
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 30,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 14),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 48, height: 1, color: lineColor),
                            const SizedBox(width: 12),
                            Text(
                              widget.isMutual
                                  ? 'MUTUAL SUPER LIKE'
                                  : 'SUPER LIKE SENT',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3.5,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(width: 48, height: 1, color: lineColor),
                          ],
                        ),
                        const SizedBox(height: 36),

                        /// Photos
                        SizedBox(
                          height: 270,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Transform.translate(
                                offset: const Offset(-70, 10),
                                child: _superLikePhotoCard(
                                  widget.myImage,
                                  angle: -0.2,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(70, -10),
                                child: _superLikePhotoCard(
                                  widget.theirImage,
                                  angle: 0.2,
                                ),
                              ),
                              Positioned(
                                bottom: -50,
                                child: _glowingSuperStar(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 56),

                        /// Title
                        Text(
                          widget.isMutual ? 'You and $firstName' : 'You',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const Text(
                          'Super Liked',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFE3D4FF),
                            height: 1.2,
                          ),
                        ),
                        Text(
                          widget.isMutual ? 'each other!' : '$firstName!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.isMutual
                              ? "That's a special connection.\nStart chatting now!"
                              : "$firstName will be notified.\nFingers crossed!",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        /// Buttons
                        if (widget.isMutual)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryDarkColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: _openingChat ? null : _sayHello,
                                child:
                                    _openingChat
                                        ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Say hello',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        if (widget.isMutual) const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    widget.isMutual ? null : Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Keep swiping',
                                style: TextStyle(
                                  color:
                                      widget.isMutual
                                          ? Colors.white
                                          : AppTheme.primaryDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSuperLike) return _buildMutualSuperLike(context);

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
                  // You (self) — left
                  _photoCard(widget.myImage, angle: -0.25),
                  // Matched person — right, on top
                  Transform.translate(
                    offset: const Offset(80, -40),
                    child: _photoCard(widget.theirImage, angle: 0.25),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        widget.isSuperLike
                            ? Icons.star_rounded
                            : Icons.favorite,
                        color:
                            widget.isSuperLike
                                ? AppTheme.superLikeColor
                                : AppTheme.primaryColor,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                widget.isSuperLike
                    ? "You super liked ${widget.userName}\nand they liked you back!"
                    : "You and ${widget.userName} liked\neach other!",
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
                    onPressed: _openingChat ? null : _sayHello,
                    child:
                        _openingChat
                            ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text(
                              'Say hello',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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
}
