import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dating_app/widgets/photo_source_picker.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';
import 'package:dating_app/utils/profile_theme.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/profile/profile_widgets.dart';
import 'Edit_Profile_Screen.dart';
import 'settings_screen.dart';

class MyProfileScreen extends StatefulWidget {
  final Function(int)? onTabTapped;

  const MyProfileScreen({super.key, this.onTabTapped});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isUploadingPhoto = false;
  bool _isVerifyingSelfie = false;
  final ImagePicker _picker = ImagePicker();

  // Access the UserController (registered in app bindings)
  final UserController _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    // After logout the controller is reset; load the new session's profile.
    if (_userController.currentUser.value == null &&
        !_userController.isLoading.value) {
      _userController.refreshProfile();
    }
  }

  Future<void> _addProfilePhoto() async {
    if (_isUploadingPhoto) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Take a Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
    );
    if (source == null || !mounted) return;

    try {
      final image = await pickProfilePhoto(context, _picker, source);
      if (image == null || !mounted) return;

      setState(() => _isUploadingPhoto = true);
      final success = await _userController.uploadProfilePhoto(image.path);
      if (!mounted) return;

      if (success) {
        await _userController.refreshProfile();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _userController.errorMessage.value.isNotEmpty
                  ? _userController.errorMessage.value
                  : 'Failed to upload photo',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _verifyWithSelfie() async {
    if (_isVerifyingSelfie) return;

    final user = _userController.currentUser.value;
    if (user == null || user.photoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload a profile photo first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final image = await pickProfilePhoto(
        context,
        _picker,
        ImageSource.camera,
      );
      if (image == null || !mounted) return;

      setState(() => _isVerifyingSelfie = true);
      final verified = await _userController.verifySelfie(image.path);
      await _userController.refreshProfile();
      if (!mounted) return;

      final message =
          verified
              ? (_userController.successMessage.value.isNotEmpty
                  ? _userController.successMessage.value
                  : 'Selfie verified')
              : (_userController.errorMessage.value.isNotEmpty
                  ? _userController.errorMessage.value
                  : 'Selfie did not match your profile photos');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: verified ? AppTheme.primaryColor : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selfie verification error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isVerifyingSelfie = false);
    }
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    if (updated == true) {
      await _userController.refreshProfile();
    }
  }

  void _openPreview(UserModel? user) {
    if (user == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailsScreen(profile: user),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  /// Hint under the vibe-strength bar, based on what's still missing.
  String _vibeHint(UserModel user) {
    final photos = user.photoUrls.length;
    if (photos == 0) return 'Add your first photo. Let them see you. ✨';
    if (photos < 3) {
      final left = 3 - photos;
      return left == 1
          ? 'One more photo. A little more spark. ✨'
          : '$left more photos. A little more spark. ✨';
    }
    if ((user.bio ?? '').trim().isEmpty) {
      return 'Add a short bio so people know your vibe. ✨';
    }
    if (!user.isVerified) return 'Verify with a selfie to build trust. ✨';
    if (user.locationLabel.isEmpty) {
      return 'Add your location to meet people nearby. ✨';
    }
    return 'Looking great. Your profile is ready to shine. ✨';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileTheme.bgBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: ProfileTheme.background),
        child: SafeArea(
          child: RefreshIndicator(
            color: ProfileTheme.purple,
            onRefresh: _userController.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                ProfileTheme.pagePadding,
                10,
                ProfileTheme.pagePadding,
                ProfileTheme.bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: ProfileTheme.gap),
                  Obx(() {
                    final user = _userController.currentUser.value;
                    if (user == null) {
                      return _userController.isLoading.value
                          ? const ProfileSkeleton()
                          : _emptyProfile();
                    }
                    return _body(user);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Profile', style: ProfileTheme.title),
              const SizedBox(height: 2),
              Text(
                'A little more you. A little more connection.',
                style: ProfileTheme.subtitle,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: ProfileTheme.circleButton,
          height: ProfileTheme.circleButton,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: ProfileTheme.cardShadow,
          ),
          child: IconButton(
            tooltip: 'Settings',
            padding: EdgeInsets.zero,
            onPressed: _openSettings,
            icon: const Icon(
              Icons.settings_outlined,
              color: ProfileTheme.navy,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  /// Shown when the profile failed to load (not loading, no user).
  Widget _emptyProfile() {
    return ProfileCard(
      child: Column(
        children: [
          Text(
            "We couldn't load your profile.",
            style: ProfileTheme.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlineButton(
            label: 'Try again',
            height: 40,
            onTap: _userController.refreshProfile,
          ),
        ],
      ),
    );
  }

  Widget _body(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileHeader(user),
        if (user.interests.isNotEmpty) ...[
          const SizedBox(height: ProfileTheme.gap),
          SizedBox(
            height: ProfileTheme.chipHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: user.interests.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => InterestChip(label: user.interests[i]),
            ),
          ),
        ],
        const SizedBox(height: ProfileTheme.gap + 4),
        VibeStrengthCard(score: user.vibeScore, hint: _vibeHint(user)),
        const SizedBox(height: ProfileTheme.gapLg),
        _photosSection(user),
        const SizedBox(height: ProfileTheme.gapLg),
        Row(
          children: [
            Expanded(
              child: GradientButton(
                label: 'Edit Profile',
                icon: Icons.edit_outlined,
                onTap: _openEditProfile,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlineButton(
                label: 'Preview',
                icon: Icons.visibility_outlined,
                onTap: () => _openPreview(user),
              ),
            ),
          ],
        ),
        const SizedBox(height: ProfileTheme.gapLg),
        _aboutCard(user),
        const SizedBox(height: ProfileTheme.gap),
        _privacyShortcut(),
      ],
    );
  }

  Widget _profileHeader(UserModel user) {
    final imageUrl = user.photoUrls.isNotEmpty ? user.photoUrls.first : '';
    final hasImage = imageUrl.startsWith('http');
    final name = '${user.firstName.isEmpty ? 'Member' : user.firstName}, ${user.age}';
    final location = user.locationLabel;
    final verificationText =
        user.selfieVerificationStatus == 'failed'
            ? 'Try selfie again'
            : 'Verify with selfie';

    const ring = ProfileTheme.avatarSize;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _isUploadingPhoto ? null : _addProfilePhoto,
          child: SizedBox(
            width: ring + 6,
            height: ring + 6,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: ring + 6,
                  height: ring + 6,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [ProfileTheme.pink, ProfileTheme.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: ProfileTheme.tileFill,
                      backgroundImage:
                          hasImage
                              ? NetworkImage(imageUrl) as ImageProvider
                              : null,
                      child:
                          _isUploadingPhoto
                              ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ProfileTheme.purple,
                              )
                              : hasImage
                              ? null
                              : const Icon(
                                Icons.add_a_photo_outlined,
                                color: ProfileTheme.purple,
                              ),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: ProfileTheme.onlineGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ProfileTheme.navy,
                      ),
                    ),
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_outlined,
                      size: 20,
                      color: ProfileTheme.purple,
                    ),
                  ],
                ],
              ),
              if (user.publicUserId.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('User id -${user.publicUserId}', style: ProfileTheme.small),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: ProfileTheme.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location.isNotEmpty ? location : 'Location not set',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: ProfileTheme.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (user.isVerified)
                Text(
                  'Verified profile',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ProfileTheme.verifiedGreen,
                  ),
                )
              else
                SizedBox(
                  width: 170,
                  child: OutlineButton(
                    label:
                        _isVerifyingSelfie
                            ? 'Checking selfie...'
                            : verificationText,
                    icon: Icons.camera_alt_outlined,
                    height: 36,
                    color: ProfileTheme.pink,
                    loading: _isVerifyingSelfie,
                    onTap: _isVerifyingSelfie ? null : _verifyWithSelfie,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photosSection(UserModel user) {
    final photos =
        user.photoUrls.where((u) => u.startsWith('http')).take(3).toList();
    final tiles = <Widget>[];
    for (var i = 0; i < photos.length; i++) {
      tiles.add(
        PhotoTile(url: photos[i], isMain: i == 0, onTap: _openEditProfile),
      );
    }
    if (tiles.length < 3) {
      tiles.add(
        AddPhotoTile(
          loading: _isUploadingPhoto,
          onTap: _isUploadingPhoto ? null : _addProfilePhoto,
        ),
      );
    }
    while (tiles.length < 3) {
      tiles.add(const SizedBox.shrink());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Photos & Stories', style: ProfileTheme.section),
            ),
            GestureDetector(
              onTap: _openEditProfile,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('Manage', style: ProfileTheme.link),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: tiles[i]),
            ],
          ],
        ),
      ],
    );
  }

  Widget _aboutCard(UserModel user) {
    final bio = (user.bio ?? '').trim();
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'A little about me',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ProfileTheme.navy,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openEditProfile,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Edit',
                  style: ProfileTheme.link.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bio.isEmpty ? 'Add a line about yourself' : bio,
            style:
                bio.isEmpty
                    ? ProfileTheme.body.copyWith(fontStyle: FontStyle.italic)
                    : ProfileTheme.body,
          ),
        ],
      ),
    );
  }

  Widget _privacyShortcut() {
    return Material(
      color: ProfileTheme.lavenderCard,
      borderRadius: BorderRadius.circular(ProfileTheme.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusCard),
        onTap: _openSettings,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: ProfileTheme.purple,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your space. Your pace.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ProfileTheme.navy,
                      ),
                    ),
                    Text(
                      'Manage privacy & discovery settings',
                      style: ProfileTheme.small,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ProfileTheme.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
