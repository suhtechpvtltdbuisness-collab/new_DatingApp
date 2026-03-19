import 'package:dating_app/models/api_models.dart';

import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication Service
/// Handles all authentication-related operations
class AuthService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();
  late SharedPreferences _prefs;

  // Singleton
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final accessToken = _prefs.getString(StorageKeys.userToken);

    if (accessToken != null) {
      _apiClient.setTokens(accessToken);
    }
  }

  // Sign up (demo flow)
  Future<ApiResponse<AuthResponse>> signUp(SignUpRequest request) async {
    // Demo implementation: accept any credentials and return a dummy token
    _logger.i('Demo sign up: ${request.email}');
    // create fake response
    final authResponse = AuthResponse(
      accessToken: 'demo_access_token',
      refreshToken: 'demo_refresh_token',
      userId: 'demo_user',
      expiresIn: 3600,
      userEmail: request.email,
    );
    // save tokens locally
    await _saveTokens(
      authResponse.accessToken,
      authResponse.refreshToken,
      authResponse.userId,
      authResponse.userEmail,
    );
    return ApiResponse.success(
      message: 'Sign up successful (demo)',
      data: authResponse,
    );
  }

  // Login (demo flow)
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    // Demo implementation: accept any credentials and return a dummy token
    _logger.i('Demo login: ${request.email}');
    final authResponse = AuthResponse(
      accessToken: 'demo_access_token',
      refreshToken: 'demo_refresh_token',
      userId: 'demo_user',
      expiresIn: 3600,
      userEmail: request.email,
    );
    await _saveTokens(
      authResponse.accessToken,
      authResponse.refreshToken,
      authResponse.userId,
      authResponse.userEmail,
    );
    return ApiResponse.success(
      message: 'Login successful (demo)',
      data: authResponse,
    );
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    try {
      _logger.i('Logout');

      final response = await _apiClient.post<void>(
        ApiEndpoints.logout,
        fromJsonT: (_) {},
      );

      // Clear local data
      await _clearTokens();

      return response;
    } catch (e) {
      _logger.e('Logout error', error: e);
      // Clear local data anyway
      await _clearTokens();
      return ApiResponse.error(
        message: 'Logout error',
        error: e.toString(),
      );
    }
  }

  // Refresh token
  Future<ApiResponse<AuthResponse>> refreshAccessToken() async {
    try {
      _logger.i('Refreshing access token');

      final refreshToken = _prefs.getString(StorageKeys.refreshToken);
      if (refreshToken == null) {
        return ApiResponse.error(
          message: 'Refresh token not found',
          error: 'No refresh token available',
        );
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);

        // Save new tokens
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken,
            authResponse.userId, authResponse.userEmail);

        return ApiResponse.success(
          message: 'Token refreshed',
          data: authResponse,
        );
      } else {
        // Token refresh failed, logout user
        await logout();
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Token refresh failed',
        );
      }
    } catch (e) {
      _logger.e('Token refresh error', error: e);
      return ApiResponse.error(
        message: 'Token refresh failed',
        error: e.toString(),
      );
    }
  }

  // Verify email
  Future<ApiResponse<void>> verifyEmail(String email, String otp) async {
    try {
      _logger.i('Verifying email: $email');

      final response = await _apiClient.post<void>(
        ApiEndpoints.verifyEmail,
        data: {'email': email, 'otp': otp},
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Email verification error', error: e);
      return ApiResponse.error(
        message: 'Email verification failed',
        error: e.toString(),
      );
    }
  }

  // Resend OTP
  Future<ApiResponse<void>> resendOtp(String email) async {
    try {
      _logger.i('Resending OTP to: $email');

      final response = await _apiClient.post<void>(
        ApiEndpoints.resendOtp,
        data: {'email': email},
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Resend OTP error', error: e);
      return ApiResponse.error(
        message: 'Resend OTP failed',
        error: e.toString(),
      );
    }
  }

  // Reset password
  Future<ApiResponse<void>> resetPassword(String email) async {
    try {
      _logger.i('Reset password for: $email');

      final response = await _apiClient.post<void>(
        ApiEndpoints.resetPassword,
        data: {'email': email},
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Reset password error', error: e);
      return ApiResponse.error(
        message: 'Reset password failed',
        error: e.toString(),
      );
    }
  }

  // Change password
  Future<ApiResponse<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      _logger.i('Changing password');

      final response = await _apiClient.post<void>(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Change password error', error: e);
      return ApiResponse.error(
        message: 'Password change failed',
        error: e.toString(),
      );
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(StorageKeys.userId);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(StorageKeys.userEmail);
  }

  // Get access token
  String? getAccessToken() {
    return _prefs.getString(StorageKeys.userToken);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getString(StorageKeys.userToken) != null;
  }

  // Save tokens
  Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    String userId,
    String email,
  ) async {
    await _prefs.setString(StorageKeys.userToken, accessToken);
    await _prefs.setString(StorageKeys.refreshToken, refreshToken);
    await _prefs.setString(StorageKeys.userId, userId);
    await _prefs.setString(StorageKeys.userEmail, email);

    _apiClient.setTokens(accessToken);

    _logger.i('Tokens saved for user: $userId');
  }

  // Clear tokens
  Future<void> _clearTokens() async {
    await _prefs.remove(StorageKeys.userToken);
    await _prefs.remove(StorageKeys.refreshToken);
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.userEmail);

    _apiClient.clearTokens();

    _logger.i('Tokens cleared');
  }
}
