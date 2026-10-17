import 'package:dating_app/controllers/chat_controller.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/chat/chat_screen.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';
import 'package:dating_app/screens/swipe/swipe_screen.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/notification_service.dart';
import 'package:dating_app/services/super_like_ledger.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/glass_card.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../subscription/subscription_screen.dart';

class LikedYouScreen extends StatefulWidget {
  final Function(int)? onTabTapped;

  const LikedYouScreen({super.key, this.onTabTapped});

  @override
  State<LikedYouScreen> createState() => _LikedYouScreenState();
}

class _LikedYouScreenState extends State<LikedYouScreen> {
  final SwipeService _swipeService = SwipeService();
  int _selectedFilter = 0;
  bool _loading = true;
  String? _error;
  List<IncomingLike> _likes = [];
  List<MatchModel> _matches = [];
  int _allCount = 0;
  int _newCount = 0;
  int _nearbyCount = 0;
  int _matchedCount = 0;
  String? _busyUserId;

  static const _likeFilters = ['all', 'new', 'nearby'];
  bool get _showingMatches => _selectedFilter == 3;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (_showingMatches) {
      final response = await _swipeService.getMatches(page: 1, limit: 50);
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (response.success && response.data != null) {
          _matches = response.data!;
          _matchedCount = _matches.length;
        } else {
          _error =
              response.message.isNotEmpty
                  ? response.message
                  : 'Could not load matches';
        }
      });
      return;
    }

    final response = await _swipeService.getIncomingLikes(
      filter: _likeFilters[_selectedFilter],
    );
    // Keep matched count fresh for the chip.
    final matchesResponse = await _swipeService.getMatches(page: 1, limit: 50);
    final superLikes = response.success && response.data != null
        ? await _resolveSuperLikes(response.data!.likes)
        : null;
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (response.success && response.data != null) {
        _likes = superLikes ?? response.data!.likes;
        _allCount = response.data!.allCount;
        _newCount = response.data!.newCount;
        _nearbyCount = response.data!.nearbyCount;
      } else {
        _error =
            response.message.isNotEmpty
                ? response.message
                : 'Could not load likes';
      }
      if (matchesResponse.success && matchesResponse.data != null) {
        _matchedCount = matchesResponse.data!.length;
      }
    });
  }

  /// Marks Super Likes the API didn't flag but this device recorded, and
  /// announces each new one once (snackbar + local notification).
  Future<List<IncomingLike>> _resolveSuperLikes(List<IncomingLike> likes) async {
    final auth = AuthService();
    final myId = auth.getCurrentUserId() ?? '';
    final me = Get.isRegistered<UserController>()
        ? Get.find<UserController>().currentUser.value
        : null;
    final myKeys = [myId, auth.getCurrentUserEmail(), me?.id, me?.email];
    final resolved = <IncomingLike>[];
    final fresh = <IncomingLike>[];
    for (final like in likes) {
      var isSuper = like.isSuperLike;
      if (!isSuper) {
        isSuper = await SuperLikeLedger.has(
          senderKeys: [like.user.id, like.user.email],
          targetKeys: myKeys,
        );
      }
      final item = isSuper == like.isSuperLike ? like : like.withSuperLike(isSuper);
      resolved.add(item);
      if (isSuper &&
          await SuperLikeLedger.markAnnounced(
            senderId: like.user.id,
            targetId: myKeys.firstWhere((k) => (k ?? '').isNotEmpty, orElse: () => '') ?? '',
          )) {
        fresh.add(item);
      }
    }

    if (fresh.isNotEmpty && mounted) {
      final name = fresh.first.user.firstName;
      final text = fresh.length == 1
          ? '⭐ $name super liked you!'
          : '⭐ $name and ${fresh.length - 1} more super liked you!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppTheme.superLikeColor, content: Text(text)),
      );
      for (final item in fresh) {
        NotificationService.instance.showSuperLikeNotification(
          fromUserId: item.user.id,
          fromName: item.user.firstName,
        );
      }
    }
    return resolved;
  }

  Future<void> _likeBack(IncomingLike like) async {
    if (_busyUserId != null) return;
    setState(() => _busyUserId = like.user.id);
    final response = await _swipeService.swipeRight(like.user.id);
    if (!mounted) return;
    setState(() => _busyUserId = null);
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _likes.removeWhere((item) => item.user.id == like.user.id));
    final matched = response.data?.isMatch ?? false;

    if (matched) {
      await _openMatchPopup(like.user, response.data?.match);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Liked back'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
    _load();
  }

  Future<void> _openMatchPopup(UserModel other, MatchModel? match) async {
    if (!Get.isRegistered<UserController>()) {
      Get.put(UserController());
    }
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }
    final userController = Get.find<UserController>();
    if (userController.currentUser.value == null) {
      await userController.getMyProfile();
    }
    if (!mounted) return;

    final myPhoto = userController.currentUser.value?.profileImage ?? '';
    final matchedUser = match?.matchedUser ?? other;
    final theirPhoto =
        matchedUser.profileImage.isNotEmpty
            ? matchedUser.profileImage
            : (matchedUser.photoUrls.isNotEmpty
                ? matchedUser.photoUrls.first
                : '');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MatchScreen(
              matchedUserId:
                  matchedUser.id.isNotEmpty ? matchedUser.id : other.id,
              userName:
                  matchedUser.fullName.trim().isNotEmpty
                      ? matchedUser.fullName
                      : other.fullName,
              myImage: myPhoto,
              theirImage: theirPhoto,
            ),
      ),
    );
  }

  Future<void> _sayHelloToMatch(MatchModel match) async {
    final user = match.matchedUser;
    final recipientId =
        user?.id.isNotEmpty == true ? user!.id : match.targetUserId;
    if (recipientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open chat for this match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_busyUserId != null) return;
    setState(() => _busyUserId = recipientId);

    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }
    final chatController = Get.find<ChatController>();
    final conv = await chatController.createChat(
      recipientId: recipientId,
      initialMessage: 'Hello 👋',
    );

    if (!mounted) return;
    setState(() => _busyUserId = null);

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

    final name =
        user != null && user.fullName.trim().isNotEmpty
            ? user.fullName
            : 'Match';
    final image =
        user != null && user.profileImage.isNotEmpty
            ? user.profileImage
            : 'assets/images/profile.png';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(chatId: conv.id, name: name, image: image),
      ),
    );
  }

  Future<void> _pass(IncomingLike like) async {
    if (_busyUserId != null) return;
    setState(() => _busyUserId = like.user.id);
    final response = await _swipeService.swipeLeft(like.user.id);
    if (!mounted) return;
    setState(() => _busyUserId = null);
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _likes.removeWhere((item) => item.user.id == like.user.id));
    _load();
  }

  void _openProfile(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileDetailsScreen(profile: user)),
    );
  }

  String _label(IncomingLike like) {
    final name =
        like.user.firstName.trim().isEmpty ? 'Member' : like.user.firstName;
    return '$name, ${like.user.age}';
  }

  String _matchLabel(MatchModel match) {
    final user = match.matchedUser;
    if (user == null) return 'Match';
    final name =
        user.firstName.trim().isEmpty ? 'Member' : user.firstName.trim();
    return '$name, ${user.age}';
  }

  String _tag(IncomingLike like) {
    if (like.isSuperLike) return '⭐ SUPER LIKED YOU';
    if (like.isNew) return 'NEW';
    if (like.distanceKm != null) {
      return '${like.distanceKm!.toStringAsFixed(0)} km';
    }
    return '${like.matchScore}% MATCH';
  }

  @override
  Widget build(BuildContext context) {
    final spotlight = [..._likes]..sort((a, b) {
      if (a.isSuperLike != b.isSuperLike) return a.isSuperLike ? -1 : 1;
      return b.matchScore.compareTo(a.matchScore);
    });
    final featured = spotlight.take(6).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Liked You',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Check out people who liked your profile!',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ),
              const SizedBox(height: 20),
              if (!_showingMatches) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Must-see profiles',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child:
                      _loading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                          )
                          : featured.isEmpty
                          ? const Center(
                            child: Text(
                              'No likes yet',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          )
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: featured.length,
                            itemBuilder: (context, index) {
                              final like = featured[index];
                              return _buildProfileCard(like);
                            },
                          ),
                ),
                const SizedBox(height: 20),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(
                        'All $_allCount',
                        _selectedFilter == 0,
                        () => _onFilterSelected(0),
                      ),
                      _buildChip(
                        'New $_newCount',
                        _selectedFilter == 1,
                        () => _onFilterSelected(1),
                      ),
                      _buildChip(
                        'Nearby $_nearbyCount',
                        _selectedFilter == 2,
                        () => _onFilterSelected(2),
                      ),
                      _buildChip(
                        'Matched $_matchedCount',
                        _selectedFilter == 3,
                        () => _onFilterSelected(3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              else if (_showingMatches) ...[
                if (_matches.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Text(
                      'No matches yet. Like people back to see them here.',
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                  )
                else
                  ..._matches.map(_buildMatchRow),
              ] else ...[
                if (_likes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Text(
                      'Nobody in this list yet. Keep swiping and likes will show up here.',
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                  ),
                ...([..._likes]..sort(
                  (a, b) =>
                      a.isSuperLike == b.isSuperLike
                          ? 0
                          : (a.isSuperLike ? -1 : 1),
                )).map(_buildRow),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        _allCount == 0
                            ? 'No one has liked you yet.'
                            : '$_allCount ${_allCount == 1 ? 'person has' : 'people have'} liked you.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upgrade to Premium to see extra insights and match faster.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                      const SizedBox(height: 16),
                      GradientButton(
                        label: 'Upgrade to Premium',
                        gradient: AppTheme.goldGradient,
                        height: 50,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onFilterSelected(int index) {
    if (_selectedFilter == index) return;
    setState(() => _selectedFilter = index);
    _load();
  }

  Widget _buildMatchRow(MatchModel match) {
    final user = match.matchedUser;
    final busyId = user?.id.isNotEmpty == true ? user!.id : match.targetUserId;
    final busy = _busyUserId == busyId;
    final image =
        user != null && user.profileImage.isNotEmpty ? user.profileImage : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: user != null ? () => _openProfile(user) : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    image.startsWith('http')
                        ? NetworkImage(image)
                        : const AssetImage('assets/images/profile.png')
                            as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _matchLabel(match),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Text(
                      'Matched',
                      style: TextStyle(
                        color: AppTheme.warmAccentColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton.icon(
                  onPressed: () => _sayHelloToMatch(match),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Say hello'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IncomingLike like) {
    final busy = _busyUserId == like.user.id;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openProfile(like.user),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
            border:
                like.isSuperLike
                    ? Border.all(color: AppTheme.superLikeColor, width: 1.6)
                    : null,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        like.user.photoUrls.isNotEmpty
                            ? NetworkImage(like.user.photoUrls.first)
                            : const AssetImage('assets/images/profile.png')
                                as ImageProvider,
                  ),
                  if (like.isSuperLike)
                    const Positioned(
                      right: -4,
                      bottom: -4,
                      child: _SuperLikeBadge(),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(like),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _tag(like),
                      style: TextStyle(
                        color:
                            like.isSuperLike
                                ? AppTheme.superLikeColor
                                : AppTheme.warmAccentColor,
                        fontWeight:
                            like.isSuperLike
                                ? FontWeight.w800
                                : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                IconButton(
                  onPressed: () => _pass(like),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
                IconButton(
                  onPressed: () => _likeBack(like),
                  icon: const Icon(Icons.favorite, color: Color(0xFFFF3D77)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(IncomingLike like) {
    final image =
        like.user.photoUrls.isNotEmpty ? like.user.photoUrls.first : '';
    return GestureDetector(
      onTap: () => _openProfile(like.user),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.softShadow(),
          color: Colors.grey.shade300,
          image: DecorationImage(
            image:
                image.startsWith('http')
                    ? NetworkImage(image)
                    : const AssetImage('assets/images/profile.png')
                        as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
        foregroundDecoration:
            like.isSuperLike
                ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: AppTheme.superLikeColor,
                    width: 2.5,
                  ),
                )
                : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (like.isSuperLike)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: _SuperLikeBadge(),
                ),
              Text(
                _label(like),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _tag(like),
                style: TextStyle(
                  color:
                      like.isSuperLike
                          ? AppTheme.superLikeColor
                          : AppTheme.warmAccentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.heroGradient : null,
          color: active ? null : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SuperLikeBadge extends StatelessWidget {
  const _SuperLikeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: AppTheme.superLikeGradient,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: const Icon(Icons.star_rounded, color: Colors.white, size: 14),
    );
  }
}
