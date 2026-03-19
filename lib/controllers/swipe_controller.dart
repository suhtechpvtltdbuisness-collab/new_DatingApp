import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/models/user_model.dart' as models;
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/data/mock_data.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Swipe Controller
/// Manages swiping, discovery, and matching state
class SwipeController extends GetxController {
  final SwipeService _swipeService = SwipeService();
  final Logger _logger = Logger();

  // Observable state variables
  final isLoading = false.obs;
  final profiles = <models.UserModel>[].obs;
  final currentProfileIndex = 0.obs;
  final matches = <MatchModel>[].obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final isProcessing = false.obs;
  final hasMoreProfiles = true.obs;
  final currentPage = 1.obs;

  // Pagination
  static const int PAGE_SIZE = 10;

  @override
  void onInit() {
    super.onInit();
    loadProfiles();
  }

  /// Get current profile being displayed
  models.UserModel? get currentProfile {
    if (currentProfileIndex.value < profiles.length) {
      return profiles[currentProfileIndex.value];
    }
    return null;
  }

  /// Load profiles for swiping
  Future<bool> loadProfiles({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        profiles.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      // Load mock data for demo
      if (profiles.isEmpty) {
        profiles.value = (MockData.sampleProfiles.cast<models.UserModel>());
        hasMoreProfiles.value = false;
        currentProfileIndex.value = 0;
        _logger.i('Loaded ${profiles.length} demo profiles');
        return true;
      }

      final response = await _swipeService.getProfiles(
        page: currentPage.value,
        limit: PAGE_SIZE,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          profiles.value = response.data!;
        } else {
          profiles.addAll(response.data!);
        }

        hasMoreProfiles.value = response.data!.length == PAGE_SIZE;
        currentProfileIndex.value = 0;

        _logger.i('Loaded ${response.data!.length} profiles');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Load profiles failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profiles';
      _logger.e('Load profiles error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more profiles for infinite scroll
  Future<bool> loadMoreProfiles() async {
    if (!hasMoreProfiles.value || isLoading.value) {
      return false;
    }

    try {
      currentPage.value++;
      return await loadProfiles();
    } catch (e) {
      _logger.e('Load more profiles error', error: e);
      currentPage.value--;
      return false;
    }
  }

  /// Like profile (swipe right)
  Future<bool> likeProfile(models.UserModel profile) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      final response = await _swipeService.likeProfile(profile.id);

      if (response.success && response.data != null) {
        successMessage.value = '❤️ Liked';
        _logger.i('Profile liked: ${profile.id}');

        // Move to next profile
        moveToNextProfile();

        // Check if match
        if (response.data!.isAccepted) {
          successMessage.value = "✨ It's a match!";
          _logger.i('Match found!');
        }

        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Like failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to like profile';
      _logger.e('Like error', error: e);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Super like profile
  Future<bool> superLikeProfile(models.UserModel profile) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      final response = await _swipeService.superLikeProfile(profile.id);

      if (response.success && response.data != null) {
        successMessage.value = '⭐ Super liked!';
        _logger.i('Profile super liked: ${profile.id}');

        // Move to next profile
        moveToNextProfile();

        // Check if match
        if (response.data!.isAccepted) {
          successMessage.value = "✨ It's a match!";
          _logger.i('Match found!');
        }

        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Super like failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to super like profile';
      _logger.e('Super like error', error: e);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Pass profile (swipe left)
  Future<bool> passProfile(models.UserModel profile) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      final response = await _swipeService.passProfile(profile.id);

      if (response.success) {
        _logger.i('Profile passed: ${profile.id}');

        // Move to next profile
        moveToNextProfile();

        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Pass failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to pass profile';
      _logger.e('Pass error', error: e);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Move to next profile
  void moveToNextProfile() {
    if (currentProfileIndex.value < profiles.length - 1) {
      currentProfileIndex.value++;

      // Load more profiles if we're near the end
      if (currentProfileIndex.value >= profiles.length - 3) {
        loadMoreProfiles();
      }
    } else if (hasMoreProfiles.value) {
      loadMoreProfiles();
    }
  }

  /// Move to previous profile (for undo)
  void moveToPreviousProfile() {
    if (currentProfileIndex.value > 0) {
      currentProfileIndex.value--;
    }
  }

  /// Get matches
  Future<bool> getMatches({bool refresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load mock matches data for demo
      matches.value = MockData.getMatches();
      _logger.i('Loaded ${matches.length} demo matches');
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to load matches';
      _logger.e('Get matches error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get top matches
  Future<bool> getTopMatches() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _swipeService.getTopMatches(limit: 20);

      if (response.success && response.data != null) {
        profiles.value = response.data!;
        currentProfileIndex.value = 0;
        _logger.i('Loaded ${response.data!.length} top matches');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Get top matches failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load top matches';
      _logger.e('Get top matches error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get nearby profiles
  Future<bool> getNearbyProfiles({int distance = 50}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _swipeService.getNearbyProfiles(distance: distance);

      if (response.success && response.data != null) {
        profiles.value = response.data!;
        currentProfileIndex.value = 0;
        _logger.i('Loaded ${response.data!.length} nearby profiles');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Get nearby profiles failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load nearby profiles';
      _logger.e('Get nearby profiles error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Accept match
  Future<bool> acceptMatch(String matchId) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      final response = await _swipeService.acceptMatch(matchId);

      if (response.success) {
        successMessage.value = 'Match accepted! You can now message.';
        _logger.i('Match accepted');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Accept match failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to accept match';
      _logger.e('Accept match error', error: e);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Reject match
  Future<bool> rejectMatch(String matchId) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      final response = await _swipeService.rejectMatch(matchId);

      if (response.success) {
        successMessage.value = 'Match rejected';
        _logger.i('Match rejected');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Reject match failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to reject match';
      _logger.e('Reject match error', error: e);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Unmatch
  Future<bool> unmatch(String matchId) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      final response = await _swipeService.unmatch(matchId);

      if (response.success) {
        successMessage.value = 'Unmatched';
        matches.removeWhere((match) => match.id == matchId);
        _logger.i('Unmatched');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Unmatch failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to unmatch';
      _logger.e('Unmatch error', error: e);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}
