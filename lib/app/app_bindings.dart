import 'package:dating_app/controllers/auth_controller.dart';
import 'package:dating_app/controllers/chat_controller.dart';
import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/controllers/registration_controller.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/chat_service.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:get/get.dart';

/// App Bindings
/// Initialize all dependencies and controllers
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize services first
    _initializeServices();

    // Then initialize controllers
    _initializeControllers();
  }

  /// Initialize all services
  void _initializeServices() {
    // Auth Service
    Get.put<AuthService>(AuthService(), permanent: true);

    // User Service
    Get.put<UserService>(UserService(), permanent: true);

    // Swipe Service
    Get.put<SwipeService>(SwipeService(), permanent: true);

    // Chat Service
    Get.put<ChatService>(ChatService(), permanent: true);
  }

  /// Initialize all controllers
  void _initializeControllers() {
    // Auth Controller
    Get.put<AuthController>(AuthController(), permanent: true);

    // Registration Controller
    Get.put<RegistrationController>(RegistrationController(), permanent: true);

    // User Controller - lazy load
    Get.lazyPut<UserController>(() => UserController());

    // Swipe Controller - lazy load
    Get.lazyPut<SwipeController>(() => SwipeController());

    // Chat Controller - lazy load
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
