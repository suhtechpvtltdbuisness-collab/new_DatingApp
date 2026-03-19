import 'package:flutter/material.dart';
import 'package:dating_app/app/app_bindings.dart';
import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:get/get.dart';
import 'package:dating_app/services/auth_service.dart';

Future<void> main() async {
  // Initialize services
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AuthService (ensure SharedPreferences ready)
  await AuthService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // Routes
      initialRoute: AppRoutes.onboarding,
      getPages: AppRoutes.pages,
      
      // Bindings
      initialBinding: AppBindings(),
      
      // Navigation settings
      enableLog: false,
    );
  }
}
