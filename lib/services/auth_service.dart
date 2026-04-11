import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();
  SharedPreferences? _prefs;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ===============================
  // INIT
  // ===============================

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final token = _prefs?.getString(StorageKeys.userToken);

    if (token != null) {
      _apiClient.setTokens(token);
    }
  }

  // ===============================
  // ✅ SEND OTP
  // ===============================

  Future<ApiResponse<void>> sendEmailOtp(String email) async {
    try {
      _logger.i('Sending OTP to: $email');

      final response = await _apiClient.get<void>(
        ApiEndpoints.sendEmailOtp(Uri.encodeComponent(email)),
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Send OTP error', error: e);
      return ApiResponse.error(
        message: 'Failed to send OTP',
        error: e.toString(),
      );
    }
  }

  // ===============================
  // ✅ VERIFY OTP
  // ===============================

  Future<ApiResponse<void>> verifyEmail(
      String email, String otp) async {
    try {
      _logger.i('Verifying OTP for: $email');

      final response = await _apiClient.post<void>(
        ApiEndpoints.verifyEmailOtp,
        data: {
          "email": email,
          "otp": otp,
        },
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Verify OTP error', error: e);
      return ApiResponse.error(
        message: 'OTP verification failed',
        error: e.toString(),
      );
    }
  }

  // ===============================
  // ✅ REGISTER USER (EMAIL FLOW)
  // ===============================

  Future<ApiResponse<void>> registerUser({
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
      _logger.i('Registering user: $email');

      final response = await _apiClient.post<void>(
        ApiEndpoints.signup,
        data: {
          "name": name,
          "phoneNumber": phoneNumber,
          "dob": dob,
          "gender": gender,
          "profile": profile,
          "interestedIn": interestedIn,
          "email": email,
          "password": password,
          "location": {
            "coordinates": coordinates,
          },
        },
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Register error', error: e);
      return ApiResponse.error(
        message: 'Registration failed',
        error: e.toString(),
      );
    }
  }

  // ===============================
  // TOKEN STORAGE
  // ===============================

  Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    String userId,
    String email,
  ) async {
    final prefs = await _getPrefs();

    await prefs.setString(StorageKeys.userToken, accessToken);
    await prefs.setString(StorageKeys.refreshToken, refreshToken);
    await prefs.setString(StorageKeys.userId, userId);
    await prefs.setString(StorageKeys.userEmail, email);

    _apiClient.setTokens(accessToken);

    _logger.i('Tokens saved');
  }

  Future<void> _clearTokens() async {
    final prefs = await _getPrefs();

    await prefs.clear();
    _apiClient.clearTokens();

    _logger.i('Tokens cleared');
  }

  // ===============================
  // HELPERS
  // ===============================

  String? getAccessToken() =>
      _prefs?.getString(StorageKeys.userToken);

  bool isLoggedIn() =>
      _prefs?.getString(StorageKeys.userToken) != null;

  String? getCurrentUserId() =>
      _prefs?.getString(StorageKeys.userId);

  String? getCurrentUserEmail() =>
      _prefs?.getString(StorageKeys.userEmail);

  // ===============================
  // SIGN UP
  // ===============================

  Future<ApiResponse<AuthResponse>> signUp(SignUpRequest request) async {
    try {
      _logger.i('Signing up user: ${request.email}');

      final response = await _apiClient.post<AuthResponse>(
        ApiEndpoints.signup,
        data: request.toJson(),
        fromJsonT: (json) => AuthResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveTokens(
          response.data!.accessToken,
          response.data!.refreshToken,
          response.data!.userId,
          response.data!.userEmail,
        );
      }

      return response;
    } catch (e) {
      _logger.e('Sign up error', error: e);
      return ApiResponse.error(
        message: 'Sign up failed',
        error: e.toString(),
      );
    }
  }

  // ===============================
  // LOGIN
  // ===============================

  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      _logger.i('Logging in user: ${request.email}');

      final response = await _apiClient.post<AuthResponse>(
        ApiEndpoints.login,
        data: request.toJson(),
        fromJsonT: (json) => AuthResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveTokens(
          response.data!.accessToken,
          response.data!.refreshToken,
          response.data!.userId,
          response.data!.userEmail,
        );
      }

      return response;
    } catch (e) {
      _logger.e('Login error', error: e);
      return ApiResponse.error(
        message: 'Login failed',
        error: e.toString(),
      );
    }
  }

  // ===============================
  // LOGOUT
  // ===============================

  Future<ApiResponse<void>> logout() async {
    try {
      _logger.i('Logging out user');

      final response = await _apiClient.post<void>(
        ApiEndpoints.logout,
        fromJsonT: (_) {},
      );

      await _clearTokens();

      return response;
    } catch (e) {
      _logger.e('Logout error', error: e);
      await _clearTokens(); // Clear tokens even if API call fails
      return ApiResponse.error(
        message: 'Logout failed',
        error: e.toString(),
      );
    }
  }

  // ===============================
  // RESEND OTP
  // ===============================

  Future<ApiResponse<void>> resendOtp(String email) async {
    return sendEmailOtp(email); // Reuse the existing method
  }

  // ===============================
  // RESET PASSWORD
  // ===============================

  Future<ApiResponse<void>> resetPassword(String email) async {
    try {
      _logger.i('Resetting password for: $email');

      final response = await _apiClient.post<void>(
        '/users/forgot-password', // Assuming this endpoint exists
        data: {"email": email},
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Reset password error', error: e);
      return ApiResponse.error(
        message: 'Failed to reset password',
        error: e.toString(),
      );
    }
  }

  // ===============================
  // CHANGE PASSWORD
  // ===============================

  Future<ApiResponse<void>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      _logger.i('Changing password');

      final response = await _apiClient.post<void>(
        '/users/change-password', // Assuming this endpoint exists
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Change password error', error: e);
      return ApiResponse.error(
        message: 'Failed to change password',
        error: e.toString(),
      );
    }
  }
}