import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/models/swipe_models.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:logger/logger.dart';

class IncomingLike {
  const IncomingLike({
    required this.user,
    required this.swipeId,
    required this.matchScore,
    required this.isNew,
    this.likedAt,
    this.distanceKm,
  });

  final UserModel user;
  final String swipeId;
  final int matchScore;
  final bool isNew;
  final DateTime? likedAt;
  final double? distanceKm;

  factory IncomingLike.fromJson(Map<String, dynamic> json) {
    return IncomingLike(
      user: UserModel.fromJson(json),
      swipeId: (json['swipeId'] ?? '').toString(),
      matchScore: int.tryParse('${json['matchScore'] ?? 0}') ?? 0,
      isNew: json['isNew'] == true,
      likedAt: json['likedAt'] != null
          ? DateTime.tryParse(json['likedAt'].toString())
          : null,
      distanceKm: json['distanceKm'] == null
          ? null
          : double.tryParse('${json['distanceKm']}'),
    );
  }
}

class IncomingLikesResult {
  const IncomingLikesResult({
    required this.likes,
    required this.allCount,
    required this.newCount,
    required this.nearbyCount,
  });

  final List<IncomingLike> likes;
  final int allCount;
  final int newCount;
  final int nearbyCount;
}

/// Swipe/Discovery Service
/// Handles swiping, matching, and discovery-related operations.
class SwipeService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  static final SwipeService _instance = SwipeService._internal();

  factory SwipeService() {
    return _instance;
  }

  SwipeService._internal();

  Future<ApiResponse<List<UserModel>>> getProfiles({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    try {
      _logger.i('Fetching profiles for swiping (page: $page)');

      final response = await _apiClient.get<dynamic>(
        ApiEndpoints.getProfiles,
        queryParameters: {
          'page': page,
          'limit': limit,
          ...?filters,
        },
        fromJsonT: (json) => json,
      );

      return _parseUserListResponse(
        response,
        preferredKeys: const ['profiles', 'users', 'results'],
        successMessage: 'Profiles fetched successfully',
        fallbackError: 'Failed to fetch profiles',
      );
    } catch (e) {
      _logger.e('Get profiles error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch profiles',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<UserModel>> getProfileDetail(String userId) async {
    try {
      _logger.i('Fetching profile detail: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getProfileDetail,
        {'id': userId},
      );

      final response = await _apiClient.get<dynamic>(
        endpoint,
        fromJsonT: (json) => json,
      );

      final data = response.data;
      if (response.success && data != null) {
        final profileJson = _asMap(data);
        return ApiResponse.success(
          message: response.message,
          data: UserModel.fromJson(profileJson),
        );
      }

      return ApiResponse.error(
        message: response.message,
        error: response.error ?? 'Failed to fetch profile',
      );
    } catch (e) {
      _logger.e('Get profile detail error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch profile',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<UserModel>>> getSuggestions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.i('Fetching suggestions for swiping (page: $page)');

      final response = await _apiClient.get<dynamic>(
        ApiEndpoints.getSuggestions,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        fromJsonT: (json) => json,
      );

      return _parseUserListResponse(
        response,
        preferredKeys: const ['suggestions', 'profiles', 'users', 'results'],
        successMessage: 'Suggestions fetched successfully',
        fallbackError: 'Failed to fetch suggestions',
      );
    } catch (e) {
      _logger.e('Get suggestions error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch suggestions',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<SwipeActionResponse>> swipeRight(String targetUserId) async {
    return _sendSwipe(
      endpoint: ApiEndpoints.getEndpoint(
        ApiEndpoints.swipeRight,
        {'userId': targetUserId},
      ),
      logLabel: 'right swipe',
      fallbackError: 'Failed to like profile',
    );
  }

  Future<ApiResponse<SwipeActionResponse>> swipeLeft(String targetUserId) async {
    return _sendSwipe(
      endpoint: ApiEndpoints.getEndpoint(
        ApiEndpoints.swipeLeft,
        {'userId': targetUserId},
      ),
      logLabel: 'left swipe',
      fallbackError: 'Failed to dislike profile',
    );
  }

  Future<ApiResponse<SwipeActionResponse>> likeProfile(String targetUserId) {
    return swipeRight(targetUserId);
  }

  Future<ApiResponse<SwipeActionResponse>> superLikeProfile(String targetUserId) {
    return swipeRight(targetUserId);
  }

  Future<ApiResponse<void>> passProfile(String targetUserId) async {
    final response = await swipeLeft(targetUserId);
    if (response.success) {
      return ApiResponse.success(
        message: response.message,
        data: null,
      );
    }

    return ApiResponse.error(
      message: response.message,
      error: response.error ?? 'Failed to dislike profile',
    );
  }

  Future<ApiResponse<void>> unlikeProfile(String targetUserId) async {
    return passProfile(targetUserId);
  }

  Future<ApiResponse<List<MatchModel>>> getMatches({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      _logger.i('Fetching matches from swipe history');

      final response = await _apiClient.get<dynamic>(
        ApiEndpoints.getSwipeMatches,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null && status.isNotEmpty) 'status': status,
        },
        fromJsonT: (json) => json,
      );

      final data = response.data;
      if (response.success && data != null) {
        final items = _extractList(
          data,
          preferredKeys: const ['matches', 'data', 'users', 'profiles'],
        );

        return ApiResponse.success(
          message: response.message,
          data: items
              .whereType<Map>()
              .map((item) => MatchModel.fromJson(Map<String, dynamic>.from(item)))
              .toList(),
        );
      }

      return ApiResponse.error(
        message: response.message,
        error: response.error ?? 'Failed to fetch matches',
      );
    } catch (e) {
      _logger.e('Get matches error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch matches',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<UserModel>>> getLikedProfiles() async {
    try {
      _logger.i('Fetching liked profiles');

      final response = await _apiClient.get<dynamic>(
        ApiEndpoints.getSwipeLikes,
        fromJsonT: (json) => json,
      );

      return _parseUserListResponse(
        response,
        preferredKeys: const ['likes', 'liked', 'profiles', 'users', 'data'],
        successMessage: 'Liked profiles fetched successfully',
        fallbackError: 'Failed to fetch liked profiles',
      );
    } catch (e) {
      _logger.e('Get liked profiles error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch liked profiles',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<IncomingLikesResult>> getIncomingLikes({
    String filter = 'all',
  }) async {
    try {
      _logger.i('Fetching incoming likes filter=$filter');
      final response = await _apiClient.get<dynamic>(
        ApiEndpoints.getLikedYou,
        queryParameters: {'filter': filter},
        fromJsonT: (json) => json,
      );

      final data = response.data;
      if (!response.success || data == null) {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch likes',
        );
      }

      final map = data is Map<String, dynamic>
          ? data
          : (data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{});
      final rawLikes = data is List ? data : map['likes'];
      final counts = map['counts'] is Map
          ? Map<String, dynamic>.from(map['counts'] as Map)
          : <String, dynamic>{};
      final likes = rawLikes is List
          ? rawLikes
              .whereType<Map>()
              .map((item) => IncomingLike.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : <IncomingLike>[];

      return ApiResponse.success(
        message: 'Incoming likes fetched',
        data: IncomingLikesResult(
          likes: likes,
          allCount: int.tryParse('${counts['all'] ?? likes.length}') ?? likes.length,
          newCount: int.tryParse('${counts['new'] ?? 0}') ?? 0,
          nearbyCount: int.tryParse('${counts['nearby'] ?? 0}') ?? 0,
        ),
      );
    } catch (e) {
      _logger.e('Get incoming likes error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch likes',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<UserModel>>> getDislikedProfiles() async {
    try {
      _logger.i('Fetching disliked profiles');

      final response = await _apiClient.get<dynamic>(
        ApiEndpoints.getSwipeDislikes,
        fromJsonT: (json) => json,
      );

      return _parseUserListResponse(
        response,
        preferredKeys: const ['dislikes', 'disliked', 'profiles', 'users', 'data'],
        successMessage: 'Disliked profiles fetched successfully',
        fallbackError: 'Failed to fetch disliked profiles',
      );
    } catch (e) {
      _logger.e('Get disliked profiles error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch disliked profiles',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<MatchModel>> getMatchDetail(String matchId) async {
    try {
      _logger.i('Fetching match detail: $matchId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getMatchDetail,
        {'id': matchId},
      );

      final response = await _apiClient.get<dynamic>(
        endpoint,
        fromJsonT: (json) => json,
      );

      final data = response.data;
      if (response.success && data != null) {
        return ApiResponse.success(
          message: response.message,
          data: MatchModel.fromJson(_asMap(data)),
        );
      }

      return ApiResponse.error(
        message: response.message,
        error: response.error ?? 'Failed to fetch match',
      );
    } catch (e) {
      _logger.e('Get match detail error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch match',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<MatchModel>> acceptMatch(String matchId) async {
    try {
      _logger.i('Accepting match: $matchId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.acceptMatch,
        {'id': matchId},
      );

      final response = await _apiClient.post<dynamic>(
        endpoint,
        fromJsonT: (json) => json,
      );

      final data = response.data;
      if (response.success && data != null) {
        return ApiResponse.success(
          message: response.message,
          data: MatchModel.fromJson(_asMap(data)),
        );
      }

      return ApiResponse.error(
        message: response.message,
        error: response.error ?? 'Failed to accept match',
      );
    } catch (e) {
      _logger.e('Accept match error', error: e);
      return ApiResponse.error(
        message: 'Failed to accept match',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<void>> rejectMatch(String matchId) async {
    try {
      _logger.i('Rejecting match: $matchId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.rejectMatch,
        {'id': matchId},
      );

      return await _apiClient.post<void>(
        endpoint,
        fromJsonT: (_) {},
      );
    } catch (e) {
      _logger.e('Reject match error', error: e);
      return ApiResponse.error(
        message: 'Failed to reject match',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<void>> unmatch(String matchId) async {
    try {
      _logger.i('Unmatching: $matchId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.unmatch,
        {'id': matchId},
      );

      return await _apiClient.delete<void>(
        endpoint,
        fromJsonT: (_) {},
      );
    } catch (e) {
      _logger.e('Unmatch error', error: e);
      return ApiResponse.error(
        message: 'Failed to unmatch',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<UserModel>>> getTopMatches({
    int limit = 10,
  }) async {
    try {
      _logger.i('Fetching top matches');

      final response = await _apiClient.get<dynamic>(
        ApiEndpoints.getTopMatches,
        queryParameters: {'limit': limit},
        fromJsonT: (json) => json,
      );

      return _parseUserListResponse(
        response,
        preferredKeys: const ['profiles', 'users', 'matches', 'data'],
        successMessage: 'Top matches fetched successfully',
        fallbackError: 'Failed to fetch top matches',
      );
    } catch (e) {
      _logger.e('Get top matches error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch top matches',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<UserModel>>> getNearbyProfiles({
    int limit = 10,
    int distance = 50,
  }) async {
    try {
      _logger.i('Fetching nearby profiles');

      final response = await _apiClient.get<dynamic>(
        ApiEndpoints.getNearbyProfiles,
        queryParameters: {
          'limit': limit,
          'distance': distance,
        },
        fromJsonT: (json) => json,
      );

      return _parseUserListResponse(
        response,
        preferredKeys: const ['profiles', 'users', 'results', 'data'],
        successMessage: 'Nearby profiles fetched successfully',
        fallbackError: 'Failed to fetch nearby profiles',
      );
    } catch (e) {
      _logger.e('Get nearby profiles error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch nearby profiles',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<SwipeActionResponse>> _sendSwipe({
    required String endpoint,
    required String logLabel,
    required String fallbackError,
  }) async {
    try {
      _logger.i('Sending $logLabel');

      final response = await _apiClient.post<dynamic>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.success) {
        return ApiResponse.success(
          message: response.message,
          data: SwipeActionResponse.fromJson(_asMap(response.data)),
        );
      }

      return ApiResponse.error(
        message: response.message,
        error: response.error ?? fallbackError,
      );
    } catch (e) {
      _logger.e('Swipe request error', error: e);
      return ApiResponse.error(
        message: fallbackError,
        error: e.toString(),
      );
    }
  }

  ApiResponse<List<UserModel>> _parseUserListResponse(
    ApiResponse<dynamic> response, {
    required List<String> preferredKeys,
    required String successMessage,
    required String fallbackError,
  }) {
    if (response.success && response.data != null) {
      final items = _extractList(response.data!, preferredKeys: preferredKeys);
      final profiles = items
          .whereType<Map>()
          .map((item) => UserModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return ApiResponse.success(
        message: response.message.isEmpty ? successMessage : response.message,
        data: profiles,
      );
    }

    return ApiResponse.error(
      message: response.message,
      error: response.error ?? fallbackError,
    );
  }

  static Map<String, dynamic> _asMap(dynamic source) {
    if (source is Map<String, dynamic>) {
      return _unwrapMap(source);
    }

    if (source is Map) {
      return _unwrapMap(Map<String, dynamic>.from(source));
    }

    return const {};
  }

  static Map<String, dynamic> _unwrapMap(Map<String, dynamic> source) {
    final nestedKeys = ['user', 'profile', 'match', 'data', 'result'];

    for (final key in nestedKeys) {
      final value = source[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }

    return source;
  }

  static List<dynamic> _extractList(
    dynamic source, {
    required List<String> preferredKeys,
  }) {
    if (source is List) {
      return source;
    }

    if (source is! Map) {
      return const [];
    }

    final normalizedSource = Map<String, dynamic>.from(source);

    for (final key in preferredKeys) {
      final value = normalizedSource[key];
      if (value is List) {
        return value;
      }
    }

    final nestedMaps = ['data', 'result'];
    for (final key in nestedMaps) {
      final value = normalizedSource[key];
      if (value is Map<String, dynamic>) {
        final nested = _extractList(value, preferredKeys: preferredKeys);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }

    if (normalizedSource.values.whereType<List>().isNotEmpty) {
      return normalizedSource.values.whereType<List>().first;
    }

    return const [];
  }
}
