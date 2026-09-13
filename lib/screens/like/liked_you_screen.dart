import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/glass_card.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'package:flutter/material.dart';
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
  int _allCount = 0;
  int _newCount = 0;
  int _nearbyCount = 0;
  String? _busyUserId;

  static const _filters = ['all', 'new', 'nearby'];

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
    final response = await _swipeService.getIncomingLikes(
      filter: _filters[_selectedFilter],
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (response.success && response.data != null) {
        _likes = response.data!.likes;
        _allCount = response.data!.allCount;
        _newCount = response.data!.newCount;
        _nearbyCount = response.data!.nearbyCount;
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'Could not load likes';
      }
    });
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(matched ? "It's a match!" : 'Liked back'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    _load();
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
    final name = like.user.firstName.trim().isEmpty ? 'Member' : like.user.firstName;
    return '$name, ${like.user.age}';
  }

  String _tag(IncomingLike like) {
    if (like.isNew) return 'NEW';
    if (like.distanceKm != null) return '${like.distanceKm!.toStringAsFixed(0)} km';
    return '${like.matchScore}% MATCH';
  }

  @override
  Widget build(BuildContext context) {
    final spotlight = [..._likes]..sort((a, b) => b.matchScore.compareTo(a.matchScore));
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
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : featured.isEmpty
                        ? const Center(
                            child: Text(
                              'No likes yet',
                              style: TextStyle(color: AppTheme.textSecondaryColor),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildChip('All $_allCount', _selectedFilter == 0, () => _onFilterSelected(0)),
                    _buildChip('New $_newCount', _selectedFilter == 1, () => _onFilterSelected(1)),
                    _buildChip('Nearby $_nearbyCount', _selectedFilter == 2, () => _onFilterSelected(2)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              if (!_loading && _likes.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Text(
                    'Nobody in this list yet. Keep swiping and likes will show up here.',
                    style: TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                ),
              ..._likes.map(_buildRow),
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
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: like.user.photoUrls.isNotEmpty
                    ? NetworkImage(like.user.photoUrls.first)
                    : const AssetImage('assets/images/profile.png') as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_label(like), style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      _tag(like),
                      style: const TextStyle(color: AppTheme.warmAccentColor, fontSize: 12),
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
    final image = like.user.photoUrls.isNotEmpty ? like.user.photoUrls.first : '';
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
            image: image.startsWith('http')
                ? NetworkImage(image)
                : const AssetImage('assets/images/profile.png') as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
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
              Text(
                _label(like),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                _tag(like),
                style: const TextStyle(
                  color: AppTheme.warmAccentColor,
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
