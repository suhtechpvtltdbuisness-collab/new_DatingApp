import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/controllers/auth_controller.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Runs after tokens are saved. A deactivated account (`active: false`)
/// must not silently continue as active: the user either restores it or
/// is signed straight back out.
Future<void> finishLogin(BuildContext context) async {
  final profile = await UserService().getMyProfile();
  if (!context.mounted) return;

  if (profile.success && profile.data != null && !profile.data!.active) {
    final reactivate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your account is deactivated'),
        content: const Text(
          'Your profile is hidden from other people. Reactivate your account to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Log out'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reactivate'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;

    if (reactivate != true) {
      await Get.find<AuthController>().logout();
      return;
    }

    final restored = await UserService().updateMyProfile({'active': true});
    if (!context.mounted) return;
    if (!restored.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored.message.isNotEmpty
                ? restored.message
                : 'Could not reactivate your account. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      await Get.find<AuthController>().logout();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome back! Your account is active again.')),
    );
  }

  AppRoutes.toHome();
}
