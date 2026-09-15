import 'dart:collection';
import 'dart:convert';

import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/models/discovery_filters.dart';
import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Saved People filters (see [DiscoveryFilters] for where each is stored).
  final filters = const DiscoveryFilters().obs;
  final filtersLoaded = false.obs;
  final isSavingFilters = false.obs;

  /// True when the deck had to use the "if I run out" relaxations.
  final isRelaxed = false.obs;

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

  static const int _maxEmptyPagesToSkip = 5;

  Future<bool> loadProfiles({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreProfiles.value = true;
      isRelaxed.value = false;
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

      if (!filtersLoaded.value) {
        await loadFilters();
      }

      var incoming = <UserModel>[];
      var skipped = 0;
      // Device-side filters can empty a whole page; keep paging a little so
      // the deck doesn't look empty while matching people exist further on.
      while (true) {
        final response = await _swipeService.getProfiles(
          page: currentPage.value,
          limit: pageSize,
          filters: filters.value.toQuery(relaxed: isRelaxed.value),
        );

        if (!response.success) {
          _logger.w('Load profiles failed: ${response.error}');
          errorMessage.value = response.message.isNotEmpty
              ? response.message
              : 'Could not load people. Please try again.';
          return false;
        }

        final page = response.data ?? const <UserModel>[];
        hasMoreProfiles.value = page.length >= pageSize;
        incoming = _applyFilters(_dedupeProfiles(page));

        if (incoming.isNotEmpty ||
            !hasMoreProfiles.value ||
            skipped >= _maxEmptyPagesToSkip) {
          break;
        }
        skipped++;
        currentPage.value++;
      }

      if (refresh) {
        profiles.assignAll(incoming);
      } else {
        profiles.addAll(incoming);
      }

      // "If I run out" relaxations: retry once with widened age/distance.
      if (refresh &&
          profiles.isEmpty &&
          !isRelaxed.value &&
          (filters.value.expandAge || filters.value.expandDistance)) {
        isRelaxed.value = true;
        currentPage.value = 1;
        hasMoreProfiles.value = true;
        isLoading.value = false;
        return loadProfiles();
      }

      errorMessage.value = '';
      if (profiles.isEmpty) {
        successMessage.value = 'No more profiles to show.';
      }

      return true;
    } catch (e) {
      _logger.e('Load profiles error', error: e);
      errorMessage.value = 'Could not load people. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  List<UserModel> _applyFilters(List<UserModel> people) {
    final me = Get.isRegistered<UserController>()
        ? Get.find<UserController>().currentUser.value
        : null;
    final myId = AuthService().getCurrentUserId() ?? '';
    return filters.value
        .apply(
          people,
          originLat: me?.latitude,
          originLng: me?.longitude,
          relaxed: isRelaxed.value,
        )
        // Defensive: the viewer's own card never belongs in their deck.
        .where((p) => p.id != myId)
        .toList();
  }

  String get _localFiltersKey =>
      'discovery_filters_${AuthService().getCurrentUserId() ?? ''}';

  /// Loads filters from GET /profile + GET /users/preferences, plus the
  /// device-only options. Falls back to defaults if the calls fail.
  Future<bool> loadFilters() async {
    final userService = UserService();
    var next = const DiscoveryFilters();
    var ok = true;

    final profileFuture = userService.getMyProfile();
    final prefsFuture = userService.getUserPreferences(
      AuthService().getCurrentUserId() ?? '',
    );
    final profile = await profileFuture;
    final prefs = await prefsFuture;

    if (profile.success && profile.data != null) {
      next = next.copyWith(
        interestedIn: DiscoveryFilters.normalizeInterestedIn(
          profile.data!.interestedIn,
        ),
      );
    } else {
      ok = false;
    }

    if (prefs.success && prefs.data != null) {
      final p = prefs.data!;
      next = next.copyWith(
        minAge: p.minAge.clamp(DiscoveryFilters.ageFloor, DiscoveryFilters.ageCeiling),
        maxAge: p.maxAge.clamp(DiscoveryFilters.ageFloor, DiscoveryFilters.ageCeiling),
        maxDistance: p.maxDistance,
        interests: p.interests,
      );
    } else {
      ok = false;
    }

    try {
      final local = await SharedPreferences.getInstance();
      final raw = local.getString(_localFiltersKey);
      if (raw != null) {
        next = next.withLocal(Map<String, dynamic>.from(jsonDecode(raw) as Map));
      }
    } catch (e) {
      _logger.w('Could not read device filters: $e');
    }

    filters.value = next;
    filtersLoaded.value = ok;
    return ok;
  }

  /// Persists filters to the backend (and device-only options locally),
  /// then reloads the deck. Returns an error message, or null on success.
  Future<String?> saveFilters(DiscoveryFilters draft) async {
    if (isSavingFilters.value) return 'Already saving';
    isSavingFilters.value = true;
    try {
      final userService = UserService();
      final userId = AuthService().getCurrentUserId() ?? '';
      if (userId.isEmpty) return 'Please sign in to continue.';

      final prefsResponse = await userService.getUserPreferences(userId);
      if (!prefsResponse.success || prefsResponse.data == null) {
        return prefsResponse.message.isNotEmpty
            ? prefsResponse.message
            : 'Could not load your current preferences';
      }

      final saved = await userService.updateUserPreferences(
        userId,
        prefsResponse.data!.copyWith(
          minAge: draft.minAge,
          maxAge: draft.maxAge,
          maxDistance: draft.maxDistance,
          interests: draft.interests,
        ),
      );
      if (!saved.success) {
        return saved.message.isNotEmpty ? saved.message : 'Could not save filters';
      }

      if (draft.interestedIn.isNotEmpty) {
        final profileSaved = await userService.updateMyProfile({
          'interestedIn': draft.interestedIn,
        });
        if (!profileSaved.success) {
          return profileSaved.message.isNotEmpty
              ? profileSaved.message
              : 'Could not save who you want to date';
        }
        if (Get.isRegistered<UserController>() && profileSaved.data != null) {
          Get.find<UserController>().currentUser.value = profileSaved.data;
        }
      }

      final local = await SharedPreferences.getInstance();
      final effective = draft.copyWith(distanceEnabled: true);
      await local.setString(_localFiltersKey, jsonEncode(effective.localToJson()));

      // Reflect what the server actually stored (it normalises interests).
      final p = saved.data;
      filters.value = effective.copyWith(
        minAge: p?.minAge,
        maxAge: p?.maxAge,
        maxDistance: p?.maxDistance,
        interests: p?.interests,
      );
      filtersLoaded.value = true;

      await loadProfiles(refresh: true);
      return null;
    } catch (e) {
      _logger.e('Save filters error', error: e);
      return 'Could not save filters. Please try again.';
    } finally {
      isSavingFilters.value = false;
    }
  }

  /// Clears everything tied to the signed-in user (called on logout).
  void resetSession() {
    profiles.clear();
    likedProfiles.clear();
    dislikedProfiles.clear();
    matches.clear();
    _pendingSwipeIds.clear();
    filters.value = const DiscoveryFilters();
    filtersLoaded.value = false;
    isRelaxed.value = false;
    currentPage.value = 1;
    hasMoreProfiles.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    isLoading.value = false;
    isLoadingMore.value = false;
  }

  /// Removes a person from the deck immediately (e.g. after blocking).
  void removeProfile(String userId) {
    profiles.removeWhere((p) => p.id == userId);
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
        final message = response.message;
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

      errorMessage.value = response.message;
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

      errorMessage.value = response.message;
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

      errorMessage.value = response.message;
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

      errorMessage.value = response.message;
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

      errorMessage.value = response.message;
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

      errorMessage.value = response.message;
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
