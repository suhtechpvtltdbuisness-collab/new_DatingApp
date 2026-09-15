import 'package:get/get.dart';
import 'package:dating_app/controllers/auth_controller.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/models/api_models.dart';

class RegistrationController extends GetxController {
  final AuthService _authService = AuthService();

  // Observable registration data
  final email = ''.obs;
  final password = ''.obs;
  final name = ''.obs;
  final dob = ''.obs;
  final gender = ''.obs;
  final interestedIn = ''.obs;
  final profile = ''.obs;
  final location = <String>[].obs;

  /// OTP-verified phone number (E.164) from the phone signup flow.
  final phoneNumber = ''.obs;
  void setPhoneNumber(String value) => phoneNumber.value = value;

  // Loading state
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Set email (from signup)
  void setEmail(String value) => email.value = value;

  // Set password
  void setPassword(String value) => password.value = value;

  // Set name
  void setName(String value) => name.value = value;

  // Set DOB (format: YYYY-MM-DD)
  void setDob(String value) => dob.value = value;

  // Set gender
  void setGender(String value) => gender.value = value;

  // Set interested in
  void setInterestedIn(String value) => interestedIn.value = value;

  // Set profile text
  void setProfile(String value) => profile.value = value;

  // Set location coordinates
  void setLocation(List<String> coordinates) => location.value = coordinates;

  // Register user with all collected data
  Future<ApiResponse<AuthResponse>> registerUser() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // The backend requires a unique E.164 phoneNumber. Use the verified
      // number from phone signup; email signups get a placeholder built from
      // the last 10 millisecond digits (the old first-10-digits version
      // repeated for every signup within the same second → 409 conflicts).
      final ms = DateTime.now().millisecondsSinceEpoch.toString();
      final uniquePhone = phoneNumber.value.isNotEmpty
          ? phoneNumber.value
          : '+91${ms.substring(ms.length - 10)}';

      final response = await _authService.registerUser(
        name: name.value,
        phoneNumber: uniquePhone,
        dob: dob.value,
        gender: gender.value,
        profile: profile.value,
        interestedIn: interestedIn.value,
        email: email.value.isNotEmpty ? email.value : null,
        password: password.value.isNotEmpty ? password.value : null,
        coordinates: location,
      );

      if (response.success) {
        if (Get.isRegistered<AuthController>()) {
          final auth = Get.find<AuthController>();
          auth.isLoggedIn.value = true;
          auth.userId.value =
              response.data?.userId ?? _authService.getCurrentUserId() ?? '';
          auth.userEmail.value = response.data?.userEmail.isNotEmpty == true
              ? response.data!.userEmail
              : email.value;
        }
        clearData();
      } else {
        errorMessage.value = response.message;
      }

      return response;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      return ApiResponse.error(
        message: 'An unexpected error occurred',
        error: 'Network error',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear all registration data
  void clearData() {
    email.value = '';
    password.value = '';
    name.value = '';
    dob.value = '';
    gender.value = '';
    interestedIn.value = '';
    profile.value = '';
    location.clear();
    phoneNumber.value = '';
  }

  // Clear error message
  void clearError() => errorMessage.value = '';
}