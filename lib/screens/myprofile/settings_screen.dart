import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/controllers/auth_controller.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/models/user_preferences_model.dart';
import 'package:dating_app/screens/subscription/subscription_screen.dart';
import 'package:dating_app/utils/profile_theme.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/profile/settings_widgets.dart';
import 'Blocked_Users_Screen.dart';
import 'Dating_Tips_Screen.dart';
import 'Help_Support_Screen.dart';
import 'Notifications_Screen.dart';
import 'Take_Break_Screen.dart';
import 'hide_my_profile_screen.dart';
import 'safety_centre_screen.dart';

/// Settings screen opened from the My Profile gear icon / privacy shortcut.
/// Holds wallet, safety and account settings that used to live on the
/// profile screen. All handlers are unchanged from the old profile screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isBreakEnabled = false;
  bool _isUpdatingBreak = false;
  String? _breakLabel;
  bool _isUpdatingIncognito = false;

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
        final current =
            _userController.userPreferences.value ??
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

  Future<void> _onIncognitoChanged(bool value) async {
    if (_isUpdatingIncognito) return;
    setState(() => _isUpdatingIncognito = true);
    final ok = await _userController.updateMyProfile({'isIncognito': value});
    if (!mounted) return;
    setState(() => _isUpdatingIncognito = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !ok
              ? (_userController.errorMessage.value.isNotEmpty
                  ? _userController.errorMessage.value
                  : 'Could not update Incognito Mode')
              : value
              ? 'Incognito Mode is on. Only your matches can see your profile.'
              : 'Incognito Mode is off. Your profile follows the default visibility.',
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

  bool _isClosingAccount = false;

  /// Runs after the confirmation dialog is closed, so it uses this State's
  /// context — the dialog's own context is already disposed by then.
  Future<void> _deactivateAccount() async {
    if (_isClosingAccount) return;
    setState(() => _isClosingAccount = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final success = await _userController.deactivateAccount();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _isClosingAccount = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _userController.errorMessage.value.isNotEmpty
                ? _userController.errorMessage.value
                : 'Failed to deactivate account',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account deactivated. Log in again to restore it.'),
      ),
    );
    await Get.find<AuthController>().logout();
    AppRoutes.toLogin();
  }

  Future<void> _deleteAccount() async {
    if (_isClosingAccount) return;
    setState(() => _isClosingAccount = true);
    final success = await _userController.deleteAccount();
    if (!mounted) return;
    setState(() => _isClosingAccount = false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _userController.errorMessage.value.isNotEmpty
                ? _userController.errorMessage.value
                : 'Failed to delete account',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await Get.find<AuthController>().logout();
    AppRoutes.toLogin();
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
                    onPressed: () {
                      Navigator.pop(context);
                      _deactivateAccount();
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
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteAccount();
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

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ProfileTheme.pagePadding,
                  10,
                  ProfileTheme.pagePadding,
                  ProfileTheme.gap,
                ),
                child: Row(
                  children: [
                    Container(
                      width: ProfileTheme.circleButton,
                      height: ProfileTheme.circleButton,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: ProfileTheme.cardShadow,
                      ),
                      child: IconButton(
                        tooltip: 'Back',
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: ProfileTheme.navy,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: ProfileTheme.navy,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    ProfileTheme.pagePadding,
                    0,
                    ProfileTheme.pagePadding,
                    ProfileTheme.bottomInset,
                  ),
                  children: [
                    _walletSection(),
                    const SizedBox(height: ProfileTheme.gap),
                    _safetySection(),
                    const SizedBox(height: ProfileTheme.gap),
                    _accountSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletSection() {
    return SettingsSection(
      title: 'My Wallet & Plans',
      children: [
        SettingsRow(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Chat Pass & Plans',
          subtitle: 'View available upgrades',
          onTap: () => _push(const SubscriptionScreen()),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: PromoCard(
            title: 'Monthly Pro',
            subtitle: 'Go beyond limits',
            cta: 'Tap to view plans',
            onTap: () => _push(const SubscriptionScreen()),
          ),
        ),
      ],
    );
  }

  Widget _safetySection() {
    return SettingsSection(
      title: 'Safety & Wellbeing',
      children: [
        SettingsRow(
          icon: Icons.shield_outlined,
          label: 'Safety Centre',
          onTap: () => _push(const SafetyCentreScreen()),
        ),
        SettingsRow(
          icon: Icons.visibility_off_outlined,
          label: 'Hide My Profile',
          onTap: () => _push(const HideMyProfileScreen()),
        ),
        SettingsRow(
          icon: Icons.block_outlined,
          label: 'Block List',
          onTap: () => _push(const BlockedUsersScreen()),
        ),
        Obx(() {
          final onBreak =
              _userController.currentUser.value?.active == false ||
              isBreakEnabled;
          return SettingsRow(
            icon: Icons.free_breakfast_outlined,
            label: 'Take a Break',
            subtitle:
                onBreak
                    ? (_breakLabel == null
                        ? 'Profile hidden until you resume'
                        : 'Hidden $_breakLabel')
                    : null,
            showChevron: false,
            trailing: GradientToggle(
              value: onBreak,
              loading: _isUpdatingBreak,
              onChanged: _onBreakChanged,
            ),
          );
        }),
        SettingsRow(
          icon: Icons.lightbulb_outline_rounded,
          label: 'Dating Tips',
          onTap: () => _push(const DatingTipsScreen()),
        ),
      ],
    );
  }

  Widget _accountSection() {
    return SettingsSection(
      title: 'Account Settings',
      children: [
        SettingsRow(
          icon: Icons.notifications_none_rounded,
          label: 'Notifications',
          onTap: () => _push(const NotificationsScreen()),
        ),
        Obx(() {
          final incognito =
              _userController.currentUser.value?.isIncognito ?? false;
          return SettingsRow(
            icon: Icons.visibility_off_outlined,
            label: 'Incognito Mode',
            subtitle:
                incognito
                    ? 'Visible only to your matches'
                    : "Hide from people you haven't matched with",
            showChevron: false,
            trailing: GradientToggle(
              value: incognito,
              loading: _isUpdatingIncognito,
              onChanged: _onIncognitoChanged,
            ),
          );
        }),
        SettingsRow(
          icon: Icons.help_outline_rounded,
          label: 'Help & Support',
          onTap: () => _push(const HelpSupportScreen()),
        ),
        SettingsRow(
          icon: Icons.logout_rounded,
          label: 'Logout',
          color: ProfileTheme.pink,
          showChevron: false,
          onTap: () => _showLogoutDialog(context),
        ),
        SettingsRow(
          icon: Icons.person_off_outlined,
          label: 'Deactivate Account',
          onTap: _isClosingAccount ? null : () => _showDeactivateDialog(context),
        ),
        SettingsRow(
          icon: Icons.delete_outline_rounded,
          label: 'Delete account',
          color: ProfileTheme.danger,
          onTap: () => _showDeleteDialog(context),
        ),
      ],
    );
  }
}
