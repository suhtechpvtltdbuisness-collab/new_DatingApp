import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/controllers/chat_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Authentication Controller
/// Manages authentication state using GetX
class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  // Observable state variables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final errorMessage = ''.obs;
  final userId = ''.obs;
  final userEmail = ''.obs;
  final successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  /// Check if user is already logged in
  void _checkLoginStatus() {
    isLoggedIn.value = _authService.isLoggedIn();
    if (isLoggedIn.value) {
      userId.value = _authService.getCurrentUserId() ?? '';
      userEmail.value = _authService.getCurrentUserEmail() ?? '';
    }
  }

  /// Sign up
  Future<bool> signUp({
    required String name,
    required String phoneNumber,
    required String dob,
    required String gender,
    required String profile,
    required String interestedIn,
    required String email,
    required String password,
    required List<String> coordinates,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final request = SignUpRequest(
        name: name,
        phoneNumber: phoneNumber,
        dob: dob,
        gender: gender,
        profile: profile,
        interestedIn: interestedIn,
        email: email,
        password: password,
        location: Location(coordinates: coordinates),
      );

      final response = await _authService.signUp(request);

      if (response.success) {
        _logger.i('Sign up successful');
        isLoggedIn.value = true;
        userId.value = response.data?.userId ?? '';
        userEmail.value = response.data?.userEmail ?? '';
        successMessage.value = 'Sign up successful! Please complete your profile.';

        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Sign up failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      _logger.e('Sign up error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await _authService.login(request);

      if (response.success) {
        _logger.i('Login successful');
        isLoggedIn.value = true;
        userId.value = response.data?.userId ?? '';
        userEmail.value = response.data?.userEmail ?? '';
        successMessage.value = 'Welcome back!';

        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Login failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      _logger.e('Login error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<bool> logout() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Always clear local state first
      await _authService.logout();

      isLoggedIn.value = false;
      userId.value = '';
      userEmail.value = '';
      successMessage.value = 'Logged out successfully';

      // Clear chat state so stale data isn't shown on next login
      try {
        Get.find<ChatController>().clearCurrentConversation();
      } catch (_) {
        // ChatController may not be initialised yet — ignore
      }

      return true;
    } catch (e) {
      // Even on unexpected error, clear local state
      isLoggedIn.value = false;
      userId.value = '';
      userEmail.value = '';
      errorMessage.value = '';
      _logger.e('Logout error', error: e);
      return true; // Local logout always succeeds
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify email
  Future<bool> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.verifyEmail(email, otp);

      if (response.success) {
        _logger.i('Email verified');
        successMessage.value = 'Email verified successfully';
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Email verification failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      _logger.e('Email verification error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp({required String email}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.resendOtp(email);

      if (response.success) {
        _logger.i('OTP resent');
        successMessage.value = 'OTP resent to your email';
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Resend OTP failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      _logger.e('Resend OTP error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.resetPassword(email);

      if (response.success) {
        _logger.i('Password reset instruction sent');
        successMessage.value =
            'Password reset instructions sent to your email';
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Reset password failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      _logger.e('Reset password error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await _authService.changePassword(currentPassword, newPassword);

      if (response.success) {
        _logger.i('Password changed');
        successMessage.value = 'Password changed successfully';
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Change password failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      _logger.e('Change password error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}
