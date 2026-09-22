import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/models/user_preferences_model.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:logger/logger.dart';

/// User Service
/// Handles user profile, preferences, and related operations
class BlockedUsersResult {
  const BlockedUsersResult({required this.ids, required this.users});

  final List<String> ids;
  final List<UserModel> users;
}

Map<String, dynamic> _unwrapUser(Map<String, dynamic> raw) {
  for (final key in ['user', 'data']) {
    final value = raw[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return raw;
}

class UserService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  // Singleton
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  // ---------------------------------------------------------------------------
  // GET /profile  →  get the logged-in user's own profile
  // ---------------------------------------------------------------------------
  Future<ApiResponse<UserModel>> getMyProfile() async {
    try {
      _logger.i('Fetching my profile (GET /profile)');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getMyProfile,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final user = UserModel.fromJson(_unwrapUser(response.data!));
        return ApiResponse.success(
          message: 'Profile fetched successfully',
          data: user,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch profile',
        );
      }
    } catch (e) {
      _logger.e('Get my profile error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch profile',
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PUT /profile  →  update the logged-in user's own profile
  // Accepts a Map so callers can send only the fields they want to change.
  // ---------------------------------------------------------------------------
  Future<ApiResponse<UserModel>> updateMyProfile(
    Map<String, dynamic> updateData,
  ) async {
    try {
      _logger.i('Updating my profile (PUT /profile)');

      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.updateMyProfile,
        data: updateData,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final user = UserModel.fromJson(_unwrapUser(response.data!));
        return ApiResponse.success(
          message: 'Profile updated successfully',
          data: user,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      _logger.e('Update my profile error', error: e);
      return ApiResponse.error(
        message: 'Failed to update profile',
        error: e.toString(),
      );
    }
  }

  // Get user profile
  Future<ApiResponse<UserModel>> getUserProfile(String userId) async {
    try {
      _logger.i('Fetching user profile: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getUserProfile,
        {'id': userId},
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final user = UserModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Profile fetched successfully',
          data: user,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch profile',
        );
      }
    } catch (e) {
      _logger.e('Get user profile error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch profile',
        error: e.toString(),
      );
    }
  }

  // Update user profile
  Future<ApiResponse<UserModel>> updateUserProfile(
    String userId,
    UserModel user,
  ) async {
    try {
      _logger.i('Updating user profile: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.updateUserProfile,
        {'id': userId},
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        endpoint,
        data: user.toJson(),
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final updatedUser = UserModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Profile updated successfully',
          data: updatedUser,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      _logger.e('Update user profile error', error: e);
      return ApiResponse.error(
        message: 'Failed to update profile',
        error: e.toString(),
      );
    }
  }

  // Upload profile photo
  Future<ApiResponse<List<String>>> uploadProfilePhoto(
    String userId,
    String filePath,
  ) async {
    try {
      _logger.i('Uploading profile photo for user: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.uploadProfilePhoto,
        {'id': userId},
      );

      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        endpoint,
        filePath: filePath,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final photoUrls = List<String>.from(response.data!['photoUrls'] ?? []);
        return ApiResponse.success(
          message: 'Photo uploaded successfully',
          data: photoUrls,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to upload photo',
        );
      }
    } catch (e) {
      _logger.e('Upload profile photo error', error: e);
      return ApiResponse.error(
        message: 'Failed to upload photo',
        error: e.toString(),
      );
    }
  }

  /// Upload a profile photo the caller already holds in memory. Used by the
  /// signup flow, where the picked image lives as bytes so the same code works
  /// on web as well as Android/iOS.
  Future<ApiResponse<List<String>>> uploadProfilePhotoBytes(
    String userId,
    List<int> bytes, {
    String filename = 'photo.jpg',
  }) async {
    try {
      _logger.i('Uploading profile photo bytes for user: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.uploadProfilePhoto,
        {'id': userId},
      );

      final response = await _apiClient.uploadBytes<Map<String, dynamic>>(
        endpoint,
        bytes: bytes,
        filename: filename,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final photoUrls = List<String>.from(response.data!['photoUrls'] ?? []);
        return ApiResponse.success(
          message: 'Photo uploaded successfully',
          data: photoUrls,
        );
      }

      return ApiResponse.error(
        message: response.message,
        error: response.error ?? 'Failed to upload photo',
      );
    } catch (e) {
      _logger.e('Upload profile photo bytes error', error: e);
      return ApiResponse.error(
        message: 'Failed to upload photo',
        error: e.toString(),
      );
    }
  }

  // Upload multiple profile photos
  Future<ApiResponse<List<String>>> uploadMultipleProfilePhotos(
    String userId,
    List<String> filePaths,
  ) async {
    try {
      _logger.i('Uploading ${filePaths.length} profile photos for user: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.uploadProfilePhoto,
        {'id': userId},
      );

      final response = await _apiClient.uploadMultipleFiles<Map<String, dynamic>>(
        endpoint,
        filePaths: filePaths,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final photoUrls = List<String>.from(response.data!['photoUrls'] ?? []);
        return ApiResponse.success(
          message: 'Photos uploaded successfully',
          data: photoUrls,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to upload photos',
        );
      }
    } catch (e) {
      _logger.e('Upload multiple profile photos error', error: e);
      return ApiResponse.error(
        message: 'Failed to upload photos',
        error: e.toString(),
      );
    }
  }

  // Delete profile photo
  Future<ApiResponse<void>> deleteProfilePhoto(
    String userId,
    String photoId,
  ) async {
    try {
      _logger.i('Deleting profile photo: $photoId');

      final response = await _apiClient.delete<void>(
        '/users/delete-photo',
        data: {
          'photoUrl': photoId,
          'photoId': photoId,
        },
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Delete profile photo error', error: e);
      return ApiResponse.error(
        message: 'Failed to delete photo',
        error: e.toString(),
      );
    }
  }

  // Get user preferences
  Future<ApiResponse<UserPreferencesModel>> getUserPreferences(String userId) async {
    try {
      _logger.i('Fetching user preferences: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getUserPreferences,
        {'id': userId},
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final preferences = UserPreferencesModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Preferences fetched successfully',
          data: preferences,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch preferences',
        );
      }
    } catch (e) {
      _logger.e('Get user preferences error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch preferences',
        error: e.toString(),
      );
    }
  }

  // Update user preferences
  Future<ApiResponse<UserPreferencesModel>> updateUserPreferences(
    String userId,
    UserPreferencesModel preferences,
  ) async {
    try {
      _logger.i('Updating user preferences: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.updateUserPreferences,
        {'id': userId},
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        endpoint,
        data: preferences.toJson(),
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final updatedPreferences = UserPreferencesModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Preferences updated successfully',
          data: updatedPreferences,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to update preferences',
        );
      }
    } catch (e) {
      _logger.e('Update user preferences error', error: e);
      return ApiResponse.error(
        message: 'Failed to update preferences',
        error: e.toString(),
      );
    }
  }

  // Block user
  Future<ApiResponse<void>> blockUser(String userId, String blockUserId) async {
    try {
      _logger.i('Blocking user: $blockUserId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.blockUser,
        {'id': userId},
      );

      final response = await _apiClient.post<void>(
        endpoint,
        data: {'blockedUserId': blockUserId},
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Block user error', error: e);
      return ApiResponse.error(
        message: 'Failed to block user',
        error: e.toString(),
      );
    }
  }

  // Unblock user
  Future<ApiResponse<void>> unblockUser(
    String userId,
    String blockedUserId,
  ) async {
    try {
      _logger.i('Unblocking user: $blockedUserId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.unblockUser,
        {'id': userId, 'blockedUserId': blockedUserId},
      );

      final response = await _apiClient.delete<void>(
        endpoint,
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Unblock user error', error: e);
      return ApiResponse.error(
        message: 'Failed to unblock user',
        error: e.toString(),
      );
    }
  }

  // GET /users/blocked  →  { blockedUsers: [ids], users: [profiles] }
  Future<ApiResponse<BlockedUsersResult>> getBlockedUsers() async {
    try {
      _logger.i('Fetching blocked users');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getBlockedUsers,
        fromJsonT: (json) => json is Map<String, dynamic>
            ? json
            : <String, dynamic>{},
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        final ids = (raw['blockedUsers'] as List? ?? const [])
            .map((id) => id.toString())
            .where((id) => id.isNotEmpty)
            .toList();
        final users = (raw['users'] as List? ?? const [])
            .whereType<Map>()
            .map((u) => UserModel.fromJson(Map<String, dynamic>.from(u)))
            .toList();
        return ApiResponse.success(
          message: 'Blocked users fetched successfully',
          data: BlockedUsersResult(ids: ids, users: users),
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch blocked users',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.e('Get blocked users error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch blocked users',
        error: e.toString(),
      );
    }
  }

  // Delete account
  Future<ApiResponse<void>> deleteAccount(String userId) async {
    try {
      _logger.i('Deleting account: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.deleteAccount,
        {'id': userId},
      );

      final response = await _apiClient.delete<void>(
        endpoint,
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Delete account error', error: e);
      return ApiResponse.error(
        message: 'Failed to delete account',
        error: e.toString(),
      );
    }
  }
}
