import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:logger/logger.dart';

/// Swipe/Discovery Service
/// Handles swiping, matching, and discovery-related operations
class SwipeService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  // Singleton
  static final SwipeService _instance = SwipeService._internal();

  factory SwipeService() {
    return _instance;
  }

  SwipeService._internal();

  // Get profiles for swiping
  Future<ApiResponse<List<UserModel>>> getProfiles({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    try {
      _logger.i('Fetching profiles for swiping (page: $page)');

      final queryParams = {
        'page': page,
        'limit': limit,
        ...?filters,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getProfiles,
        queryParameters: queryParams,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final profiles = (response.data!['profiles'] as List?)
                ?.map((e) => UserModel.fromJson(e))
                .toList() ??
            [];
        return ApiResponse.success(
          message: 'Profiles fetched successfully',
          data: profiles,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch profiles',
        );
      }
    } catch (e) {
      _logger.e('Get profiles error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch profiles',
        error: e.toString(),
      );
    }
  }

  // Get profile detail
  Future<ApiResponse<UserModel>> getProfileDetail(String userId) async {
    try {
      _logger.i('Fetching profile detail: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getProfileDetail,
        {'id': userId},
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final profile = UserModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Profile fetched successfully',
          data: profile,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch profile',
        );
      }
    } catch (e) {
      _logger.e('Get profile detail error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch profile',
        error: e.toString(),
      );
    }
  }

  // Get suggestions for swiping
  Future<ApiResponse<List<UserModel>>> getSuggestions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.i('Fetching suggestions for swiping (page: $page)');

      final queryParams = {
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getSuggestions,
        queryParameters: queryParams,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final suggestions = (response.data!['suggestions'] as List?)
                ?.map((e) => UserModel.fromJson(e))
                .toList() ??
            [];
        return ApiResponse.success(
          message: 'Suggestions fetched successfully',
          data: suggestions,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch suggestions',
        );
      }
    } catch (e) {
      _logger.e('Get suggestions error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch suggestions',
        error: e.toString(),
      );
    }
  }

  // Like profile
  Future<ApiResponse<MatchModel>> likeProfile(String targetUserId) async {
    try {
      _logger.i('Liking profile: $targetUserId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.likeProfile,
        data: {'targetUserId': targetUserId},
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final match = MatchModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Like sent successfully',
          data: match,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to like profile',
        );
      }
    } catch (e) {
      _logger.e('Like profile error', error: e);
      return ApiResponse.error(
        message: 'Failed to like profile',
        error: e.toString(),
      );
    }
  }

  // Super like profile
  Future<ApiResponse<MatchModel>> superLikeProfile(String targetUserId) async {
    try {
      _logger.i('Super liking profile: $targetUserId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.superLikeProfile,
        data: {'targetUserId': targetUserId},
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final match = MatchModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Super like sent successfully',
          data: match,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to super like profile',
        );
      }
    } catch (e) {
      _logger.e('Super like profile error', error: e);
      return ApiResponse.error(
        message: 'Failed to super like profile',
        error: e.toString(),
      );
    }
  }

  // Pass/Reject profile
  Future<ApiResponse<void>> passProfile(String targetUserId) async {
    try {
      _logger.i('Passing profile: $targetUserId');

      final response = await _apiClient.post<void>(
        ApiEndpoints.passProfile,
        data: {'targetUserId': targetUserId},
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Pass profile error', error: e);
      return ApiResponse.error(
        message: 'Failed to pass profile',
        error: e.toString(),
      );
    }
  }

  // Unlike profile
  Future<ApiResponse<void>> unlikeProfile(String targetUserId) async {
    try {
      _logger.i('Unliking profile: $targetUserId');

      final response = await _apiClient.post<void>(
        ApiEndpoints.unlikeProfile,
        data: {'targetUserId': targetUserId},
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Unlike profile error', error: e);
      return ApiResponse.error(
        message: 'Failed to unlike profile',
        error: e.toString(),
      );
    }
  }

  // Get matches
  Future<ApiResponse<List<MatchModel>>> getMatches({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      _logger.i('Fetching matches (page: $page)');

      final queryParams = {
        'page': page,
        'limit': limit,
        'status': ?status,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getMatches,
        queryParameters: queryParams,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final matches = (response.data!['matches'] as List?)
                ?.map((e) => MatchModel.fromJson(e))
                .toList() ??
            [];
        return ApiResponse.success(
          message: 'Matches fetched successfully',
          data: matches,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch matches',
        );
      }
    } catch (e) {
      _logger.e('Get matches error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch matches',
        error: e.toString(),
      );
    }
  }

  // Get match detail
  Future<ApiResponse<MatchModel>> getMatchDetail(String matchId) async {
    try {
      _logger.i('Fetching match detail: $matchId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getMatchDetail,
        {'id': matchId},
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final match = MatchModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Match fetched successfully',
          data: match,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch match',
        );
      }
    } catch (e) {
      _logger.e('Get match detail error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch match',
        error: e.toString(),
      );
    }
  }

  // Accept match
  Future<ApiResponse<MatchModel>> acceptMatch(String matchId) async {
    try {
      _logger.i('Accepting match: $matchId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.acceptMatch,
        {'id': matchId},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final match = MatchModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Match accepted successfully',
          data: match,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to accept match',
        );
      }
    } catch (e) {
      _logger.e('Accept match error', error: e);
      return ApiResponse.error(
        message: 'Failed to accept match',
        error: e.toString(),
      );
    }
  }

  // Reject match
  Future<ApiResponse<void>> rejectMatch(String matchId) async {
    try {
      _logger.i('Rejecting match: $matchId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.rejectMatch,
        {'id': matchId},
      );

      final response = await _apiClient.post<void>(
        endpoint,
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Reject match error', error: e);
      return ApiResponse.error(
        message: 'Failed to reject match',
        error: e.toString(),
      );
    }
  }

  // Unmatch
  Future<ApiResponse<void>> unmatch(String matchId) async {
    try {
      _logger.i('Unmatching: $matchId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.unmatch,
        {'id': matchId},
      );

      final response = await _apiClient.delete<void>(
        endpoint,
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Unmatch error', error: e);
      return ApiResponse.error(
        message: 'Failed to unmatch',
        error: e.toString(),
      );
    }
  }

  // Get top matches
  Future<ApiResponse<List<UserModel>>> getTopMatches({
    int limit = 10,
  }) async {
    try {
      _logger.i('Fetching top matches');

      final queryParams = {'limit': limit};

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getTopMatches,
        queryParameters: queryParams,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final profiles = (response.data!['profiles'] as List?)
                ?.map((e) => UserModel.fromJson(e))
                .toList() ??
            [];
        return ApiResponse.success(
          message: 'Top matches fetched successfully',
          data: profiles,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch top matches',
        );
      }
    } catch (e) {
      _logger.e('Get top matches error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch top matches',
        error: e.toString(),
      );
    }
  }

  // Get nearby profiles
  Future<ApiResponse<List<UserModel>>> getNearbyProfiles({
    int limit = 10,
    int distance = 50,
  }) async {
    try {
      _logger.i('Fetching nearby profiles');

      final queryParams = {
        'limit': limit,
        'distance': distance,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getNearbyProfiles,
        queryParameters: queryParams,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final profiles = (response.data!['profiles'] as List?)
                ?.map((e) => UserModel.fromJson(e))
                .toList() ??
            [];
        return ApiResponse.success(
          message: 'Nearby profiles fetched successfully',
          data: profiles,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch nearby profiles',
        );
      }
    } catch (e) {
      _logger.e('Get nearby profiles error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch nearby profiles',
        error: e.toString(),
      );
    }
  }
}
