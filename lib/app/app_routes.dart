import 'package:dating_app/app/app_bindings.dart';
import 'package:dating_app/screens/auth/email_signin_screen.dart';
import 'package:dating_app/screens/auth/email_signup_screen.dart';
import 'package:dating_app/screens/auth/onboarding_screen.dart';
import 'package:dating_app/screens/home/home_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  // Route names
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String swipe = '/swipe';
  static const String matches = '/matches';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/:id';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String splash = '/splash';

  // GetPages - Define all routes
  static final pages = [
    // Onboarding routes
    GetPage(
      name: onboarding,
      page: () => ModernOnboardingScreen(),
      binding: AppBindings(),
    ),

    // Auth routes
    GetPage(
      name: login,
      page: () => const EmailSigninScreen(),
      binding: AppBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: signup,
      page: () => const EmailSignupScreen(),
      binding: AppBindings(),
      transition: Transition.rightToLeft,
    ),

    // Home/Main routes
    GetPage(name: home, page: () => HomeScreen(), binding: AppBindings()),
  ];

  // Helper methods for navigation
  static void toOnboarding() {
    Get.offNamedUntil(onboarding, (route) => false);
  }

  static void toLogin() {
    Get.offNamedUntil(login, (route) => false);
  }

  static void toSignup() {
    Get.toNamed(signup);
  }

  static void toHome() {
    Get.offNamedUntil(home, (route) => false);
  }

  static void toSwipe() {
    Get.toNamed(swipe);
  }

  static void toMatches() {
    Get.toNamed(matches);
  }

  static void toChat() {
    Get.toNamed(chat);
  }

  static void toChatDetail(String conversationId) {
    Get.toNamed(chatDetail, parameters: {'id': conversationId});
  }

  static void toProfile() {
    Get.toNamed(profile);
  }

  static void toProfileEdit() {
    Get.toNamed(profileEdit);
  }

  static void toSettings() {
    Get.toNamed(settings);
  }

  static void toNotifications() {
    Get.toNamed(notifications);
  }
}
