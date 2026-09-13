import 'dart:async';
import 'package:dating_app/models/user_model.dart' as models;
import 'package:dating_app/models/user_preferences_model.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// User Controller
/// Manages user profile, preferences, and related operations
class UserController extends GetxController {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  // Observable state variables
  final isLoading = false.obs;
  final currentUser = Rx<models.UserModel?>(null);
  final userPreferences = Rx<UserPreferencesModel?>(null);
  final blockedUsers = <String>[].obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  /// Load user data from GET /profile
  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      final response = await _userService.getMyProfile();
      if (response.success && response.data != null) {
        currentUser.value = response.data;
        errorMessage.value = '';
        _logger.i('Loaded real profile from GET /profile');
      } else {
        errorMessage.value = response.message;
        _logger.w('GET /profile failed: ${response.error}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile';
      _logger.e('Load user data error', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() => _loadUserData();

  /// Get MY profile — GET /profile
  Future<bool> getMyProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _userService.getMyProfile();

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        _logger.i('My profile loaded from GET /profile');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('GET /profile failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile';
      _logger.e('Get my profile error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update MY profile — PUT /profile
  Future<bool> updateMyProfile(Map<String, dynamic> updateData) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final response = await _userService.updateMyProfile(updateData);

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        successMessage.value = 'Profile updated successfully';
        _logger.i('Profile updated via PUT /profile');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('PUT /profile failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update profile';
      _logger.e('Update my profile error', error: e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Get user profile (by ID)
  Future<bool> getUserProfile(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _userService.getUserProfile(userId);

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        _logger.i('User profile loaded');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Get profile failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile';
      _logger.e('Get profile error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(models.UserModel user) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _userService.updateUserProfile(userId, user);

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        successMessage.value = 'Profile updated successfully';
        _logger.i('Profile updated');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Update profile failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update profile';
      _logger.e('Update profile error', error: e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Upload profile photo
  Future<bool> uploadProfilePhoto(String filePath) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _userService.uploadProfilePhoto(userId, filePath);

      if (response.success && response.data != null) {
        await getMyProfile();
        if (currentUser.value != null) {
          currentUser.value = currentUser.value!.copyWith(
            photoUrls: response.data,
          );
        }
        successMessage.value = 'Photo uploaded successfully';
        _logger.i('Photo uploaded');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Upload photo failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to upload photo';
      _logger.e('Upload photo error', error: e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Upload multiple profile photos
  Future<bool> uploadMultipleProfilePhotos(List<String> filePaths) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _userService.uploadMultipleProfilePhotos(
        userId,
        filePaths,
      );

      if (response.success && response.data != null) {
        // Update local user model with new photo URLs
        if (currentUser.value != null) {
          currentUser.value = currentUser.value!.copyWith(
            photoUrls: response.data,
          );
        }
        successMessage.value = 'Photos uploaded successfully';
        _logger.i('Photos uploaded');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Upload photos failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to upload photos';
      _logger.e('Upload photos error', error: e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete profile photo
  Future<bool> deleteProfilePhoto(String photoId) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _userService.deleteProfilePhoto(userId, photoId);

      if (response.success) {
        if (currentUser.value != null) {
          final updatedPhotos = currentUser.value!.photoUrls
              .where((url) => url != photoId && !url.contains(photoId))
              .toList();
          currentUser.value = currentUser.value!.copyWith(
            photoUrls: updatedPhotos,
          );
        }
        successMessage.value = 'Photo deleted successfully';
        _logger.i('Photo deleted');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Delete photo failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete photo';
      _logger.e('Delete photo error', error: e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Get user preferences
  Future<bool> getUserPreferences(String userId) async {
    try {
      errorMessage.value = '';

      final response = await _userService.getUserPreferences(userId);

      if (response.success && response.data != null) {
        userPreferences.value = response.data;
        _logger.i('User preferences loaded');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Get preferences failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load preferences';
      _logger.e('Get preferences error', error: e);
      return false;
    }
  }

  /// Update user preferences
  Future<bool> updateUserPreferences(UserPreferencesModel preferences) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _userService.updateUserPreferences(userId, preferences);

      if (response.success && response.data != null) {
        userPreferences.value = response.data;
        successMessage.value = 'Preferences updated successfully';
        _logger.i('Preferences updated');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Update preferences failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update preferences';
      _logger.e('Update preferences error', error: e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Block user
  Future<bool> blockUser(String blockUserId) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _userService.blockUser(userId, blockUserId);

      if (response.success) {
        blockedUsers.add(blockUserId);
        successMessage.value = 'User blocked';
        _logger.i('User blocked');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Block user failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to block user';
      _logger.e('Block user error', error: e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Unblock user
  Future<bool> unblockUser(String blockedUserId) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _userService.unblockUser(userId, blockedUserId);

      if (response.success) {
        blockedUsers.remove(blockedUserId);
        successMessage.value = 'User unblocked';
        _logger.i('User unblocked');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Unblock user failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to unblock user';
      _logger.e('Unblock user error', error: e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Get blocked users
  Future<bool> getBlockedUsers(String userId) async {
    try {
      errorMessage.value = '';

      final response = await _userService.getBlockedUsers(userId);

      if (response.success && response.data != null) {
        blockedUsers.value = response.data ?? [];
        _logger.i('Blocked users loaded');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Get blocked users failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load blocked users';
      _logger.e('Get blocked users error', error: e);
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _userService.deleteAccount(userId);

      if (response.success) {
        // Clear local data and logout
        currentUser.value = null;
        userPreferences.value = null;
        blockedUsers.clear();
        _logger.i('Account deleted');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Delete account failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete account';
      _logger.e('Delete account error', error: e);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}
