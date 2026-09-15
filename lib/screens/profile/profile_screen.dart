import 'package:dating_app/controllers/chat_controller.dart';
import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/glass_card.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat/chat_screen.dart';
import '../chat/report_user_screen.dart';

/// Full profile detail view.
///
/// Pass a loaded [profile], or just a [userId] to fetch it from
/// GET /profiles/:id. Only public profile fields are rendered — email,
/// phone number, date of birth and exact coordinates are never shown.
class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key, this.profile, this.userId});

  final UserModel? profile;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    return ProfileDetailsContent(profile: profile, userId: userId);
  }
}

class ProfileDetailsContent extends StatefulWidget {
  const ProfileDetailsContent({super.key, this.profile, this.userId});

  final UserModel? profile;
  final String? userId;

  @override
  State<ProfileDetailsContent> createState() => _ProfileDetailsContentState();
}

class _ProfileDetailsContentState extends State<ProfileDetailsContent> {
  UserModel? _profile;
  bool _loading = false;
  String? _error;
  bool _startingChat = false;
  bool _liking = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    if (_profile == null) _load();
  }

  Future<void> _load() async {
    final id = widget.userId ?? '';
    if (id.isEmpty) {
      setState(() => _error = 'This profile is not available.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await SwipeService().getProfileDetail(id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (response.success && response.data != null) {
        _profile = response.data;
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'Could not load this profile.';
      }
    });
  }

  bool get _isOwnProfile {
    final myId = AuthService().getCurrentUserId() ?? '';
    return myId.isNotEmpty && _profile?.id == myId;
  }

  void _toast(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _sayHello(UserModel profile, String displayName) async {
    if (_startingChat) return;
    setState(() => _startingChat = true);
    final chatController = Get.find<ChatController>();
    final conv = await chatController.createChat(recipientId: profile.id);
    if (!mounted) return;
    setState(() => _startingChat = false);
    if (conv == null) {
      _toast(
        chatController.errorMessage.value.isNotEmpty
            ? chatController.errorMessage.value
            : 'Could not start a chat. Please try again.',
        error: true,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: conv.id,
          name: displayName,
          image: profile.profileImage.isNotEmpty
              ? profile.profileImage
              : 'assets/images/profile.png',
        ),
      ),
    );
  }

  Future<void> _like(UserModel profile) async {
    if (_liking) return;
    setState(() => _liking = true);
    final response = await SwipeService().swipeRight(profile.id);
    if (!mounted) return;
    setState(() => _liking = false);
    if (!response.success) {
      _toast(response.message.isNotEmpty ? response.message : 'Could not like profile',
          error: true);
      return;
    }
    if (Get.isRegistered<SwipeController>()) {
      Get.find<SwipeController>().removeProfile(profile.id);
    }
    _toast((response.data?.isMatch ?? false) ? "It's a match!" : 'Liked');
  }

  Future<void> _showSafetyActions(UserModel profile, String displayName) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: AppTheme.primaryColor),
              title: const Text('Report profile'),
              onTap: () => Navigator.pop(sheetContext, 'report'),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block profile'),
              onTap: () => Navigator.pop(sheetContext, 'block'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    var shouldBlock = action == 'block';
    if (action == 'report') {
      final blockAfterReport = await Navigator.push<bool?>(
        context,
        MaterialPageRoute(
          builder: (_) => ReportUserScreen(
            userName: displayName,
            reportedUserId: profile.id,
          ),
        ),
      );
      shouldBlock = blockAfterReport == true;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Block $displayName?'),
          content: const Text(
            "They won't be able to see your profile or message you. You can unblock them from Block List.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Block', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      shouldBlock = confirmed == true;
    }
    if (!shouldBlock || !mounted) return;

    final userController = Get.find<UserController>();
    final ok = await userController.blockUser(profile.id);
    if (!mounted) return;
    if (!ok) {
      _toast(
        userController.errorMessage.value.isNotEmpty
            ? userController.errorMessage.value
            : 'Could not block this profile',
        error: true,
      );
      return;
    }
    if (Get.isRegistered<SwipeController>()) {
      Get.find<SwipeController>().removeProfile(profile.id);
    }
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>()
          .conversations
          .removeWhere((c) => c.otherUserId == profile.id);
    }
    _toast('$displayName has been blocked');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              if (_profile != null)
                _buildProfile(context, _profile!)
              else
                Center(
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _error ?? 'This profile is not available.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppTheme.textSecondaryColor),
                              ),
                              if ((widget.userId ?? '').isNotEmpty)
                                TextButton(onPressed: _load, child: const Text('Retry')),
                            ],
                          ),
                        ),
                ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, UserModel profile) {
    final name = profile.fullName.trim();
    final displayName = name.isEmpty ? 'Member' : name;
    final age = profile.age;
    final bio = profile.bio?.trim() ?? '';
    final images = profile.photoUrls;
    final isOwn = _isOwnProfile;
    final details = _details(profile);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOwn) ...[
            GlassCard(
              child: Row(
                children: const [
                  Icon(Icons.visibility_outlined, color: AppTheme.primaryColor, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is how your profile looks to others.',
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  age > 0 ? '$displayName, $age' : displayName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              if (profile.isVerified)
                const Icon(Icons.verified_rounded, color: AppTheme.superLikeColor, size: 22),
            ],
          ),
          if (profile.locationLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textTertiaryColor),
                const SizedBox(width: 4),
                Text(profile.locationLabel, style: const TextStyle(color: AppTheme.textSecondaryColor)),
              ],
            ),
          ],

          // Say Hello / Like are interactions with someone else — never
          // offered on the viewer's own profile.
          if (!isOwn) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: 'Say Hello 👋',
                    height: 52,
                    isLoading: _startingChat,
                    onPressed: () => _sayHello(profile, displayName),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GhostButton(
                    label: _liking ? 'Liking…' : 'Like ❤️',
                    height: 52,
                    borderColor: AppTheme.primaryColor,
                    textColor: AppTheme.primaryColor,
                    onPressed: _liking ? null : () => _like(profile),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 26),
          _sectionTitle(Icons.info_outline_rounded, 'My Story'),
          const SizedBox(height: 10),
          GlassCard(
            child: Text(
              bio.isNotEmpty ? bio : (isOwn ? 'Add a bio from Edit Profile.' : 'No bio yet.'),
              style: const TextStyle(color: AppTheme.textSecondaryColor, height: 1.5),
            ),
          ),

          if (details.isNotEmpty) ...[
            const SizedBox(height: 26),
            _sectionTitle(Icons.person_outline_rounded, 'About'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: details.map((d) => _chip(d.value, icon: d.icon)).toList(),
            ),
          ],

          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle(Icons.photo_library_outlined, 'Life Highlights'),
              if (images.isNotEmpty)
                GestureDetector(
                  onTap: () => _openGallery(context, images, 0, displayName),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Text(
                      'View all (${images.length})',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          if (images.isEmpty)
            GlassCard(
              child: Text(
                isOwn ? 'Add photos from your profile to show your highlights.' : 'No photos yet.',
                style: const TextStyle(color: AppTheme.textSecondaryColor),
              ),
            )
          else
            Row(
              children: [
                Expanded(child: _image(context, images, 0, 310, displayName)),
                if (images.length > 1) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        _image(context, images, 1, images.length > 2 ? 150 : 310, displayName),
                        if (images.length > 2) ...[
                          const SizedBox(height: 10),
                          _image(context, images, 2, 150, displayName),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),

          const SizedBox(height: 26),
          _sectionTitle(Icons.bolt_rounded, 'The Vibe'),
          const SizedBox(height: 12),
          if (profile.interests.isEmpty)
            const Text('No interests added yet.', style: TextStyle(color: AppTheme.textSecondaryColor))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: profile.interests.map((i) => _chip(i)).toList(),
            ),

          if (profile.qualities.isNotEmpty) ...[
            const SizedBox(height: 26),
            _sectionTitle(Icons.favorite_border_rounded, 'Qualities I value'),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: profile.qualities.map((q) => _chip(q)).toList()),
          ],

          if (profile.languages.isNotEmpty) ...[
            const SizedBox(height: 26),
            _sectionTitle(Icons.translate_rounded, 'Languages'),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: profile.languages.map((l) => _chip(l)).toList()),
          ],

          if (profile.openingMoves.isNotEmpty) ...[
            const SizedBox(height: 26),
            _sectionTitle(Icons.lightbulb_outline_rounded, 'Opening Moves'),
            const SizedBox(height: 12),
            ...profile.openingMoves.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(child: Text(m, style: const TextStyle(color: AppTheme.textPrimaryColor))),
              ),
            ),
          ],

          // Reporting or blocking yourself makes no sense.
          if (!isOwn) ...[
            const SizedBox(height: 26),
            Center(
              child: TextButton.icon(
                onPressed: () => _showSafetyActions(profile, displayName),
                icon: const Icon(Icons.flag_outlined, color: AppTheme.textTertiaryColor, size: 18),
                label: const Text('Report or Block Profile', style: TextStyle(color: AppTheme.textTertiaryColor)),
              ),
            ),
          ],
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  /// Public "about" facts. Contact details, DOB and coordinates are
  /// intentionally excluded.
  List<({IconData icon, String value})> _details(UserModel p) {
    final out = <({IconData icon, String value})>[];
    void add(IconData icon, String? value, [String prefix = '']) {
      final v = value?.trim() ?? '';
      if (v.isNotEmpty) out.add((icon: icon, value: '$prefix$v'));
    }

    add(Icons.badge_outlined, p.pronouns);
    add(Icons.work_outline, p.work);
    add(Icons.school_outlined, p.education);
    add(Icons.workspace_premium_outlined, p.educationLevel);
    add(Icons.height, p.height);
    add(Icons.home_outlined, p.hometown, 'From ');
    add(Icons.search, p.lookingFor, 'Looking for ');
    add(Icons.fitness_center, p.exercise);
    add(Icons.auto_awesome_outlined, p.starSign);
    add(Icons.local_bar_outlined, p.drinking);
    add(Icons.smoke_free, p.smoking);
    add(Icons.child_care_outlined, p.kids);
    add(Icons.family_restroom, p.haveKids);
    add(Icons.church_outlined, p.religion);
    add(Icons.how_to_vote_outlined, p.politics);
    return out;
  }

  void _openGallery(BuildContext context, List<String> images, int index, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePhotoGalleryScreen(images: images, initialIndex: index, title: name),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppTheme.textPrimaryColor)),
      ],
    );
  }

  Widget _image(BuildContext context, List<String> images, int index, double height, String name) {
    return GestureDetector(
      onTap: () => _openGallery(context, images, index, name),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: _photo(images[index], height: height),
      ),
    );
  }

  Widget _chip(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 6),
          ],
          Text(text, style: const TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

Widget _photo(String path, {double? height, BoxFit fit = BoxFit.cover}) {
  final provider = path.startsWith('http') ? NetworkImage(path) : AssetImage(path) as ImageProvider;
  return Image(
    image: provider,
    height: height,
    width: double.infinity,
    fit: fit,
    errorBuilder: (_, __, ___) => Container(
      height: height,
      color: Colors.white.withOpacity(0.5),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: AppTheme.textTertiaryColor),
    ),
  );
}

/// Full-screen swipeable view of every photo on a profile ("View all").
class ProfilePhotoGalleryScreen extends StatefulWidget {
  const ProfilePhotoGalleryScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.title = '',
  });

  final List<String> images;
  final int initialIndex;
  final String title;

  @override
  State<ProfilePhotoGalleryScreen> createState() => _ProfilePhotoGalleryScreenState();
}

class _ProfilePhotoGalleryScreenState extends State<ProfilePhotoGalleryScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.images.isEmpty ? 0 : widget.initialIndex.clamp(0, widget.images.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.images.isEmpty ? widget.title : '${widget.title}  ${_index + 1}/${widget.images.length}',
        ),
      ),
      body: widget.images.isEmpty
          ? const Center(child: Text('No photos yet', style: TextStyle(color: Colors.white70)))
          : PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => InteractiveViewer(
                child: Center(child: _photo(widget.images[i], fit: BoxFit.contain)),
              ),
            ),
    );
  }
}
