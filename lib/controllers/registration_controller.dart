import 'package:get/get.dart';
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
  Future<ApiResponse<void>> registerUser() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Generate unique phone number
      final uniquePhone = '+91${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}';

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
        // Clear data after successful registration
        clearData();
      } else {
        errorMessage.value = response.error ?? response.message;
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
  }

  // Clear error message
  void clearError() => errorMessage.value = '';
}