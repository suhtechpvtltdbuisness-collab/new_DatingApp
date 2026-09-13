import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/controllers/auth_controller.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/models/user_preferences_model.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';
import 'package:dating_app/screens/subscription/subscription_screen.dart';
import 'Edit_Profile_Screen.dart';
import 'Safety_Toolkit_Screen.dart';
import 'Blocked_Users_Screen.dart';
import 'Take_Break_Screen.dart';
import 'Dating_Tips_Screen.dart';
import 'Notifications_Screen.dart';
import 'Help_Support_Screen.dart';
import 'hide_my_profile_screen.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  final Function(int)? onTabTapped;

  const MyProfileScreen({super.key, this.onTabTapped});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool isBreakEnabled = false;
  bool _isUpdatingBreak = false;
  String? _breakLabel;
  bool _isUploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

  // Access the UserController (registered in app bindings)
  final UserController _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _loadBreakState();
  }

  Future<void> _loadBreakState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isBreakEnabled = prefs.getBool('on_break') ?? isBreakEnabled;
      _breakLabel = prefs.getString('break_label');
    });
  }

  Future<void> _addProfilePhoto() async {
    if (_isUploadingPhoto) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (image == null || !mounted) return;

      setState(() => _isUploadingPhoto = true);
      final success = await _userController.uploadProfilePhoto(image.path);
      if (!mounted) return;

      if (success) {
        await _userController.refreshProfile();
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

  Future<void> _setBreak(bool enabled, {TakeBreakChoice? choice}) async {
    if (_isUpdatingBreak) return;
    setState(() => _isUpdatingBreak = true);

    var ok = true;
    if (choice?.hideProfile != false) {
      ok = await _userController.updateMyProfile({'active': !enabled});
    }

    if (ok && choice != null && choice.disableNotifications) {
      final userId = _userController.currentUser.value?.id;
      if (userId != null && userId.isNotEmpty) {
        await _userController.getUserPreferences(userId);
        final current = _userController.userPreferences.value ??
            UserPreferencesModel.defaultPreferences(userId);
        await _userController.updateUserPreferences(
          current.copyWith(notificationsEnabled: !enabled),
        );
      }
    }

    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (ok) {
      await prefs.setBool('on_break', enabled);
      if (enabled && choice != null) {
        await prefs.setString('break_label', choice.untilLabel);
      } else {
        await prefs.remove('break_label');
      }
    }
    if (!mounted) return;
    setState(() {
      _isUpdatingBreak = false;
      isBreakEnabled = ok && enabled;
      _breakLabel = ok && enabled ? choice?.untilLabel : null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !ok
              ? (_userController.errorMessage.value.isNotEmpty
                  ? _userController.errorMessage.value
                  : 'Could not update break')
              : enabled
                  ? 'Break started. Your profile is hidden ${_breakLabel ?? 'until you turn it off'}.'
                  : 'Break ended. Your profile is visible again.',
        ),
        backgroundColor: ok ? AppTheme.primaryColor : Colors.red,
      ),
    );
  }

  Future<void> _onBreakChanged(bool value) async {
    if (_isUpdatingBreak) return;
    if (!value) {
      await _setBreak(false);
      return;
    }

    final choice = await Navigator.push<TakeBreakChoice>(
      context,
      MaterialPageRoute(builder: (_) => const TakeBreakScreen()),
    );
    if (!mounted) return;
    if (choice == null) {
      setState(() => isBreakEnabled = false);
      return;
    }
    await _setBreak(true, choice: choice);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔥 YOUR IMAGE
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/logout.png", // ✅ your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Log out?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "You'll be signed out of your account on this device. You can log back in anytime.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 20),

                /// Cancel Button
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Logout Button
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final auth = Get.find<AuthController>();
                      await auth.logout();
                      AppRoutes.toLogin();
                    },
                    child: const Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/Deactivate.png", // ✅ your image
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Deactivate your account?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Your account will be temporarily disabled. Your profile and data will be hidden, but you can restore everything by logging back in.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 20),

                /// Cancel
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Deactivate
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final success = await _userController.updateMyProfile({
                        'active': false,
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Account deactivated'
                                : (_userController.errorMessage.value.isNotEmpty
                                    ? _userController.errorMessage.value
                                    : 'Failed to deactivate account'),
                          ),
                        ),
                      );
                      if (success) {
                        final auth = Get.find<AuthController>();
                        await auth.logout();
                        AppRoutes.toLogin();
                      }
                    },
                    child: const Text(
                      "Deactivate",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "You can reactivate your account anytime.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/Delete.png", // ✅ your image
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Delete your account permanently?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "This action cannot be undone. All your data, including your profile, activity, and saved information, will be permanently deleted.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 20),

                /// Cancel
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Delete
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final success = await _userController.deleteAccount();
                      if (!mounted) return;
                      if (success) {
                        final auth = Get.find<AuthController>();
                        await auth.logout();
                        AppRoutes.toLogin();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _userController.errorMessage.value.isNotEmpty
                                  ? _userController.errorMessage.value
                                  : 'Failed to delete account',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Note: This action is irreversible.",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _photoTip(UserModel? user) {
    final count = user?.photoUrls.length ?? 0;
    if (count == 0) {
      return 'Add at least 3 clear photos. Profiles with more photos get more matches.';
    }
    if (count < 3) {
      return 'You have $count photo${count == 1 ? '' : 's'}. Add ${3 - count} more to boost your vibe score.';
    }
    if ((user?.bio ?? '').trim().isEmpty) {
      return 'Great photo set. Add a short bio so people know what you are about.';
    }
    return 'Keep your first photo recent and well-lit. Leading with your best shot improves replies.';
  }

  List<Widget> _photoInsightBars(UserModel? user) {
    final photos = user?.photoUrls ?? const <String>[];
    final slots = <Widget>[];

    for (var i = 0; i < photos.length.clamp(0, 4); i++) {
      slots.add(
        _photoSlot(
          label: 'Pic ${i + 1}',
          imageUrl: photos[i],
          active: i == 0,
          onTap: _openEditProfile,
        ),
      );
    }

    final emptySlots = (3 - slots.length).clamp(0, 3);
    for (var i = 0; i < emptySlots; i++) {
      slots.add(
        _photoSlot(
          label: 'Add',
          imageUrl: null,
          active: false,
          onTap: _isUploadingPhoto ? null : _addProfilePhoto,
        ),
      );
    }

    return slots;
  }

  Widget _photoSlot({
    required String label,
    required String? imageUrl,
    required bool active,
    required VoidCallback? onTap,
  }) {
    final hasImage = imageUrl != null && imageUrl.startsWith('http');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 56,
            height: hasImage ? 88 : 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6F91).withOpacity(hasImage ? 1 : 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? const Color(0xFFFF3D77) : const Color(0xFFFF6F91),
                width: active ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                    ),
                  )
                : _isUploadingPhoto
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF6F91),
                        ),
                      )
                    : const Icon(Icons.add, color: Color(0xFFFF6F91), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active || label == 'Add'
                  ? const Color(0xFFFF6F91)
                  : Colors.grey,
              fontWeight: active || label == 'Add'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: _userController.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
              children: [
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (_userController.isLoading.value &&
                      _userController.currentUser.value == null) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    );
                  }

                  final user = _userController.currentUser.value;
                  final imageUrl =
                      user != null && user.photoUrls.isNotEmpty
                          ? user.photoUrls.first
                          : '';
                  final name = user == null
                      ? 'Complete your profile'
                      : '${user.firstName.isEmpty ? 'Member' : user.firstName}, ${user.age}';
                  final location = user?.locationLabel ?? '';

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: _isUploadingPhoto ? null : _addProfilePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF6F91),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: imageUrl.startsWith('http')
                                ? NetworkImage(imageUrl) as ImageProvider
                                : const AssetImage('assets/images/profile.png'),
                            child: imageUrl.startsWith('http')
                                ? null
                                : const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.white70,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6F91),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${user?.vibeScore ?? 0}% VIBE SCORE",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        location.isNotEmpty ? location : 'Location not set',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if ((user?.bio ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            user!.bio!,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                      if (user != null && user.interests.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: user.interests.take(5).map((interest) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF3D77),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: _openEditProfile,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      child: Center(
                                        child: Text(
                                          "Edit Profile",
                                          style: TextStyle(
                                            color: Color(0xFFFF6F91),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => _openPreview(user),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF3D77),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      child: Center(
                                        child: Text(
                                          "Preview",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Photo Insights",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: _photoInsightBars(user),
                            ),
                            const SizedBox(height: 25),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4F8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFF6F91)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    color: Color(0xFFFF6F91),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "PRO TIP",
                                          style: TextStyle(
                                            color: Color(0xFFFF6F91),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(_photoTip(user)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "My Wallet & Plans",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionScreen(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Color(0xFFFF3D77),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Chat Pass & Plans",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "View available upgrades",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionScreen(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF3D77), Color(0xFFB96EFF)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Monthly Pro",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "Go beyond limits",
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Tap to view plans",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      /// ================= SAFETY & WELLBEING =================
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Safety & Wellbeing",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildTile(
                        Icons.shield_outlined,
                        "Safety Toolkit",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SafetyToolkitScreen(),
                            ),
                          );
                        },
                      ),
                      _buildTile(
                        Icons.visibility_off_outlined,
                        "Hide My Profile",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HideMyProfileScreen(),
                            ),
                          );
                        },
                      ),

                      _buildTile(
                        Icons.block_outlined,
                        "Block List",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BlockedUsersScreen(),
                            ),
                          );
                        },
                      ),

                      Obx(() {
                        final onBreak =
                            _userController.currentUser.value?.active == false ||
                                isBreakEnabled;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.free_breakfast_outlined,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Take a Break',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      if (onBreak)
                                        Text(
                                          _breakLabel == null
                                              ? 'Profile hidden until you resume'
                                              : 'Hidden $_breakLabel',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_isUpdatingBreak)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFFF3D77),
                                    ),
                                  )
                                else
                                  Switch(
                                    value: onBreak,
                                    activeColor: const Color(0xFFFF3D77),
                                    onChanged: _onBreakChanged,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),

                      _buildTile(
                        Icons.lightbulb_outline,
                        "Dating Tips",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DatingTipsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      /// ================= ACCOUNT SETTINGS =================
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Account Settings",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildTile(
                        Icons.notifications_none,
                        "Notifications",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildTile(
                        Icons.help_outline,
                        "Help & Support",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),

                      /// Logout
                      /// Logout
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: InkWell(
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: const [
                                Icon(Icons.logout, color: AppTheme.primaryColor),
                                SizedBox(width: 12),
                                Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      _buildTile(
                        Icons.person_off_outlined,
                        "Deactivate Account",
                        onTap: () {
                          _showDeactivateDialog(context);
                        },
                      ),

                      _buildTile(
                        Icons.delete_outline,
                        "Delete account",
                        onTap: () {
                          _showDeleteDialog(context);
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16)),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
