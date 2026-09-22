import 'package:flutter/material.dart';
import 'package:dating_app/app/app_bindings.dart';
import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dating_app/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    await dotenv.load(fileName: '.env.example');
  }

  final authService = AuthService();
  await authService.initialize();

  // A stored session must survive a restart, otherwise a logged-in user is
  // sent back through onboarding every time the app is reopened.
  final startRoute =
      authService.isLoggedIn() ? AppRoutes.home : AppRoutes.onboarding;

  runApp(MyApp(initialRoute: startRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // Routes
      initialRoute: initialRoute,
      getPages: AppRoutes.pages,
      
      // Bindings
      initialBinding: AppBindings(),
      
      // Navigation settings
      enableLog: false,
    );
  }
}
