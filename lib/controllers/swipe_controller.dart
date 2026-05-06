import 'dart:collection';

import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SwipeSubmissionResult {
  final bool success;
  final bool isMatch;
  final String message;

  const SwipeSubmissionResult({
    required this.success,
    this.isMatch = false,
    this.message = '',
  });
}

/// Swipe Controller
/// Keeps the swipe deck responsive while the API completes in the background.
class SwipeController extends GetxController {
  SwipeController({SwipeService? swipeService})
      : _swipeService = swipeService ?? Get.find<SwipeService>();

  final SwipeService _swipeService;
  final Logger _logger = Logger();

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isHistoryLoading = false.obs;
  final profiles = <UserModel>[].obs;
  final likedProfiles = <UserModel>[].obs;
  final dislikedProfiles = <UserModel>[].obs;
  final matches = <MatchModel>[].obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final hasMoreProfiles = true.obs;
  final currentPage = 1.obs;

  static const int pageSize = 10;
  static const int preloadThreshold = 2;

  final Set<String> _pendingSwipeIds = <String>{};

  UnmodifiableSetView<String> get pendingSwipeIds =>
      UnmodifiableSetView(_pendingSwipeIds);

  UserModel? get currentProfile => profiles.isEmpty ? null : profiles.first;

  @override
  void onInit() {
    super.onInit();
    loadProfiles(refresh: true);
    refreshSwipeHistory();
  }

  bool canSwipe(String userId) => !_pendingSwipeIds.contains(userId);

  Future<bool> loadProfiles({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreProfiles.value = true;
    }

    if ((refresh && isLoading.value) || (!refresh && (isLoadingMore.value || !hasMoreProfiles.value))) {
      return false;
    }

    try {
      if (refresh) {
        isLoading.value = true;
        errorMessage.value = '';
      } else {
        isLoadingMore.value = true;
      }

      final response = await _swipeService.getSuggestions(
        page: currentPage.value,
        limit: pageSize,
      );

      if (!response.success) {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Load profiles failed: ${response.error}');
        return false;
      }

      final incoming = _dedupeProfiles(response.data ?? const []);

      if (refresh) {
        profiles.assignAll(incoming);
      } else {
        profiles.addAll(incoming);
      }

      hasMoreProfiles.value = (response.data ?? const []).length >= pageSize;
      errorMessage.value = '';

      if (incoming.isEmpty && profiles.isEmpty) {
        successMessage.value = 'No more profiles to show.';
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to load profiles';
      _logger.e('Load profiles error', error: e);
      return false;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<bool> loadMoreProfiles() async {
    if (!hasMoreProfiles.value || isLoading.value || isLoadingMore.value) {
      return false;
    }

    currentPage.value++;
    final loaded = await loadProfiles();
    if (!loaded) {
      currentPage.value--;
    }
    return loaded;
  }

  Future<SwipeSubmissionResult> submitSwipe({
    required UserModel profile,
    required SwipeAction action,
  }) async {
    final profileIndex = profiles.indexWhere((item) => item.id == profile.id);
    if (profileIndex == -1 || _pendingSwipeIds.contains(profile.id)) {
      return const SwipeSubmissionResult(
        success: false,
        message: 'Swipe already processed.',
      );
    }

    _pendingSwipeIds.add(profile.id);
    errorMessage.value = '';

    final removedProfile = profiles.removeAt(profileIndex);
    if (profiles.length <= preloadThreshold) {
      loadMoreProfiles();
    }

    try {
      final response = action == SwipeAction.like
          ? await _swipeService.swipeRight(profile.id)
          : await _swipeService.swipeLeft(profile.id);

      if (!response.success) {
        _restoreProfile(removedProfile, profileIndex);
        final message = response.error ?? response.message;
        errorMessage.value = message;
        _logger.w('Swipe failed: $message');
        return SwipeSubmissionResult(
          success: false,
          message: message,
        );
      }

      if (action == SwipeAction.like) {
        _prependUniqueProfile(likedProfiles, removedProfile);
      } else {
        _prependUniqueProfile(dislikedProfiles, removedProfile);
      }

      final isMatch = response.data?.isMatch ?? false;
      final match = response.data?.match;
      if (isMatch && match != null) {
        _upsertMatch(match);
      }

      successMessage.value = isMatch
          ? "It's a match!"
          : action == SwipeAction.like
              ? 'Profile liked.'
              : 'Profile skipped.';

      return SwipeSubmissionResult(
        success: true,
        isMatch: isMatch,
        message: successMessage.value,
      );
    } catch (e) {
      _restoreProfile(removedProfile, profileIndex);
      errorMessage.value = 'Failed to process swipe';
      _logger.e('Submit swipe error', error: e);
      return const SwipeSubmissionResult(
        success: false,
        message: 'Failed to process swipe',
      );
    } finally {
      _pendingSwipeIds.remove(profile.id);
    }
  }

  Future<bool> refreshSwipeHistory() async {
    try {
      isHistoryLoading.value = true;

      final results = await Future.wait<Object>([
        _swipeService.getMatches(page: 1, limit: 50),
        _swipeService.getLikedProfiles(),
        _swipeService.getDislikedProfiles(),
      ]);

      final matchesResponse = results[0] as ApiResponse<List<MatchModel>>;
      final likesResponse = results[1] as ApiResponse<List<UserModel>>;
      final dislikesResponse = results[2] as ApiResponse<List<UserModel>>;

      if (matchesResponse.success) {
        matches.assignAll(matchesResponse.data ?? const <MatchModel>[]);
      }

      if (likesResponse.success) {
        likedProfiles.assignAll(_uniqueProfiles(likesResponse.data ?? const <UserModel>[]));
      }

      if (dislikesResponse.success) {
        dislikedProfiles.assignAll(_uniqueProfiles(dislikesResponse.data ?? const <UserModel>[]));
      }

      return matchesResponse.success || likesResponse.success || dislikesResponse.success;
    } catch (e) {
      _logger.e('Refresh swipe history error', error: e);
      return false;
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<bool> getMatches({bool refresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _swipeService.getMatches(page: 1, limit: 50);
      if (response.success) {
        matches.assignAll(response.data ?? const []);
        return true;
      }

      errorMessage.value = response.error ?? response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to load matches';
      _logger.e('Get matches error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> getTopMatches() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _swipeService.getTopMatches(limit: 20);
      if (response.success) {
        profiles.assignAll(_uniqueProfiles(response.data ?? const []));
        return true;
      }

      errorMessage.value = response.error ?? response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to load top matches';
      _logger.e('Get top matches error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> getNearbyProfiles({int distance = 50}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _swipeService.getNearbyProfiles(distance: distance);
      if (response.success) {
        profiles.assignAll(_uniqueProfiles(response.data ?? const []));
        return true;
      }

      errorMessage.value = response.error ?? response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to load nearby profiles';
      _logger.e('Get nearby profiles error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> acceptMatch(String matchId) async {
    try {
      final response = await _swipeService.acceptMatch(matchId);
      if (response.success && response.data != null) {
        _upsertMatch(response.data!);
        successMessage.value = 'Match accepted! You can now message.';
        return true;
      }

      errorMessage.value = response.error ?? response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to accept match';
      _logger.e('Accept match error', error: e);
      return false;
    }
  }

  Future<bool> rejectMatch(String matchId) async {
    try {
      final response = await _swipeService.rejectMatch(matchId);
      if (response.success) {
        matches.removeWhere((match) => match.id == matchId);
        successMessage.value = 'Match rejected.';
        return true;
      }

      errorMessage.value = response.error ?? response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to reject match';
      _logger.e('Reject match error', error: e);
      return false;
    }
  }

  Future<bool> unmatch(String matchId) async {
    try {
      final response = await _swipeService.unmatch(matchId);
      if (response.success) {
        matches.removeWhere((match) => match.id == matchId);
        successMessage.value = 'Unmatched.';
        return true;
      }

      errorMessage.value = response.error ?? response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to unmatch';
      _logger.e('Unmatch error', error: e);
      return false;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  List<UserModel> _dedupeProfiles(List<UserModel> incoming) {
    final excludedIds = <String>{
      ...profiles.map((profile) => profile.id),
      ...likedProfiles.map((profile) => profile.id),
      ...dislikedProfiles.map((profile) => profile.id),
      ..._pendingSwipeIds,
    };

    final unique = <UserModel>[];
    final seenIds = <String>{...excludedIds};

    for (final profile in incoming) {
      if (profile.id.isEmpty || seenIds.contains(profile.id)) {
        continue;
      }

      seenIds.add(profile.id);
      unique.add(profile);
    }

    return unique;
  }

  List<UserModel> _uniqueProfiles(List<UserModel> items) {
    final seenIds = <String>{};
    final unique = <UserModel>[];

    for (final profile in items) {
      if (profile.id.isEmpty || !seenIds.add(profile.id)) {
        continue;
      }
      unique.add(profile);
    }

    return unique;
  }

  void _restoreProfile(UserModel profile, int preferredIndex) {
    if (profiles.any((item) => item.id == profile.id)) {
      return;
    }

    final insertIndex = preferredIndex.clamp(0, profiles.length);
    profiles.insert(insertIndex, profile);
  }

  void _prependUniqueProfile(RxList<UserModel> list, UserModel profile) {
    list.removeWhere((item) => item.id == profile.id);
    list.insert(0, profile);
  }

  void _upsertMatch(MatchModel match) {
    final index = matches.indexWhere((item) => item.id == match.id);
    if (index == -1) {
      matches.insert(0, match);
    } else {
      matches[index] = match;
    }
  }
}
