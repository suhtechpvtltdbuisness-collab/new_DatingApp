import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    final refreshToken = _prefs?.getString(StorageKeys.refreshToken);

    if (token != null) {
      _apiClient.setTokens(token, refreshToken: refreshToken);
    }

    // Wire the refresh flow: when a request gets a 401, ApiClient calls
    // back here with the stored refresh token; we hit the refresh
    // endpoint directly (bypassing the normal interceptor chain to avoid
    // recursively triggering another 401 handler) and persist the result.
    _apiClient.onRefreshToken = _performTokenRefresh;
    _apiClient.onSessionExpired = () {
      _logger.w('Session expired — local auth state cleared.');
      _clearTokens();
    };
  }

  Future<String?> _performTokenRefresh(String refreshToken) async {
    if (refreshToken.isEmpty) return null;

    // Use a bare Dio instance (no auth interceptors) for the refresh call
    // itself — routing it through ApiClient's own interceptor chain would
    // risk a second 401 on this very request recursively re-triggering the
    // refresh flow.
    final rawDio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
    ));

    try {
      final response = await rawDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final body = response.data;
      final payload = body is Map<String, dynamic> && body.containsKey('data')
          ? body['data']
          : body;

      if (payload is Map<String, dynamic>) {
        final authResponse = AuthResponse.fromJson(payload);
        await _saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken.isNotEmpty ? authResponse.refreshToken : refreshToken,
          authResponse.userId,
          authResponse.userEmail,
        );
        return authResponse.accessToken;
      }
    } catch (e) {
      _logger.e('Token refresh request failed', error: e);
    }

    return null;
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
  // PHONE OTP — GET /users/otp/:phoneNumber
  // ===============================

  /// Asks the backend to generate and deliver an SMS code. The response
  /// body is deliberately discarded: the code must only reach the user by
  /// SMS and is never surfaced in the app.
  Future<ApiResponse<void>> sendPhoneOtp(String e164Phone) async {
    try {
      _logger.i('Requesting phone OTP');
      return await _apiClient.get<void>(
        '/users/otp/${Uri.encodeComponent(e164Phone)}',
        fromJsonT: (_) {},
      );
    } catch (e) {
      _logger.e('Send phone OTP error', error: e);
      return ApiResponse.error(message: 'Failed to send code', error: e.toString());
    }
  }

  /// POST /users/otp/validate { number, otp } — signup verification.
  Future<ApiResponse<void>> verifyPhoneOtp(String e164Phone, String otp) async {
    try {
      return await _apiClient.post<void>(
        '/users/otp/validate',
        data: {'number': e164Phone, 'otp': otp},
        fromJsonT: (_) {},
      );
    } catch (e) {
      _logger.e('Verify phone OTP error', error: e);
      return ApiResponse.error(message: 'Verification failed', error: e.toString());
    }
  }

  /// POST /users/login { phoneNumber, otp } — signs in and stores tokens.
  Future<ApiResponse<AuthResponse>> loginWithPhone(String e164Phone, String otp) async {
    try {
      final response = await _apiClient.post<AuthResponse>(
        ApiEndpoints.login,
        data: {'phoneNumber': e164Phone, 'otp': otp},
        fromJsonT: (json) => AuthResponse.fromJson(json),
      );
      if (response.success &&
          response.data != null &&
          response.data!.accessToken.isNotEmpty) {
        await _saveTokens(
          response.data!.accessToken,
          response.data!.refreshToken,
          response.data!.userId,
          response.data!.userEmail,
        );
      } else if (response.success) {
        return ApiResponse.error(message: 'Login failed. Please try again.', error: 'No token');
      }
      return response;
    } catch (e) {
      _logger.e('Phone login error', error: e);
      return ApiResponse.error(message: 'Login failed', error: e.toString());
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

  Future<ApiResponse<AuthResponse>> registerUser({
    required String name,
    required String phoneNumber,
    required String dob,
    required String gender,
    required String profile,
    required String interestedIn,
    String? email,
    String? password,
    String? googleSignupToken,
    required List<String> coordinates,
  }) async {
    try {
      _logger.i('Registering user: $email');

      final data = {
        "name": name,
        "phoneNumber": phoneNumber,
        "dob": dob,
        "gender": gender,
        "profile": profile,
        "interestedIn": interestedIn,
        "location": {
          "coordinates": coordinates,
        },
      };

      if (email != null && email.isNotEmpty) {
        data["email"] = email;
      }
      if (password != null && password.isNotEmpty) {
        data["password"] = password;
      }
      if (googleSignupToken != null && googleSignupToken.isNotEmpty) {
        data["googleSignupToken"] = googleSignupToken;
      }

      final response = await _apiClient.post<AuthResponse>(
        ApiEndpoints.signup,
        data: data,
        fromJsonT: (json) => AuthResponse.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );

      if (response.success &&
          response.data != null &&
          response.data!.accessToken.isNotEmpty) {
        await _saveTokens(
          response.data!.accessToken,
          response.data!.refreshToken,
          response.data!.userId,
          response.data!.userEmail.isNotEmpty
              ? response.data!.userEmail
              : (email ?? ''),
        );
      } else if (response.success &&
          email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        // Backend may create the user without returning tokens — sign in next.
        return login(LoginRequest(email: email, password: password));
      }

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

    _apiClient.setTokens(accessToken, refreshToken: refreshToken);

    _logger.i('Tokens saved');
  }

  Future<void> _clearTokens() async {
    final prefs = await _getPrefs();
    await prefs.remove(StorageKeys.userToken);
    await prefs.remove(StorageKeys.refreshToken);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userEmail);
    _apiClient.clearTokens();
    _logger.i('Tokens cleared');
  }

  // ===============================
  // HELPERS
  // ===============================

  String? getAccessToken() =>
      _prefs?.getString(StorageKeys.userToken);

  /// An empty string counts as no session — a blank token would otherwise
  /// route a signed-out user straight into the app.
  bool isLoggedIn() =>
      (_prefs?.getString(StorageKeys.userToken) ?? '').isNotEmpty;

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
  // GOOGLE SIGN-IN
  // ===============================

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: AppConstants.googleServerClientId.isEmpty
        ? null
        : AppConstants.googleServerClientId,
  );

  /// Returns null when the user cancels the Google account picker.
  Future<ApiResponse<GoogleAuthResult>?> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final idToken = (await account.authentication).idToken;
      if (idToken == null) {
        return ApiResponse.error(
          message: 'Google sign-in failed. Please try again.',
          error: 'No idToken',
        );
      }

      final response = await _apiClient.post<GoogleAuthResult>(
        ApiEndpoints.googleLogin,
        data: {'idToken': idToken},
        fromJsonT: (json) => GoogleAuthResult.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );

      final auth = response.data?.auth;
      if (response.success && auth != null) {
        await _saveTokens(
          auth.accessToken,
          auth.refreshToken,
          auth.userId,
          auth.userEmail,
        );
      }
      return response;
    } catch (e) {
      _logger.e('Google login error', error: e);
      return ApiResponse.error(
        message: 'Google sign-in failed',
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

      final prefs = await _getPrefs();
      final refreshToken = prefs.getString(StorageKeys.refreshToken);

      // Always clear local state first, regardless of API success
      await _clearTokens();

      // Best-effort revocation — the token is already gone locally, so pass
      // the refresh token explicitly rather than relying on the auth header.
      try {
        await _apiClient.post<void>(
          ApiEndpoints.logout,
          data: {'refreshToken': refreshToken},
          fromJsonT: (_) {},
        );
      } catch (_) {
        // Swallow errors — local logout is what matters
      }

      return ApiResponse<void>.success(
        message: 'Logged out successfully',
        data: null,
      );
    } catch (e) {
      _logger.e('Logout error', error: e);
      // Still clear tokens even on unexpected error
      await _clearTokens();
      return ApiResponse<void>.success(
        message: 'Logged out',
        data: null,
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