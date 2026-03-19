import 'package:dating_app/utils/constants.dart';

/// API Endpoints configuration
class ApiEndpoints {
  // Base URL
  static const String baseUrl = AppConstants.baseUrl;

  // Authentication endpoints
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendOtp = '/auth/resend-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // User endpoints
  static const String getUserProfile = '/users/:id';
  static const String updateUserProfile = '/users/:id';
  static const String deleteAccount = '/users/:id';
  static const String getUserPreferences = '/users/:id/preferences';
  static const String updateUserPreferences = '/users/:id/preferences';
  static const String uploadProfilePhoto = '/users/:id/photos';
  static const String deleteProfilePhoto = '/users/:id/photos/:photoId';
  static const String blockUser = '/users/:id/blocks';
  static const String unblockUser = '/users/:id/blocks/:blockedUserId';
  static const String getBlockedUsers = '/users/:id/blocks';

  // Discovery/Swipe endpoints
  static const String getProfiles = '/discovery/profiles';
  static const String likeProfile = '/discovery/like';
  static const String unlikeProfile = '/discovery/unlike';
  static const String superLikeProfile = '/discovery/super-like';
  static const String passProfile = '/discovery/pass';
  static const String getProfileDetail = '/discovery/profiles/:id';

  // Match endpoints
  static const String getMatches = '/matches';
  static const String getMatchDetail = '/matches/:id';
  static const String acceptMatch = '/matches/:id/accept';
  static const String rejectMatch = '/matches/:id/reject';
  static const String unmatch = '/matches/:id/unmatch';

  // Chat endpoints
  static const String getConversations = '/chat/conversations';
  static const String getConversation = '/chat/conversations/:id';
  static const String sendMessage = '/chat/conversations/:id/messages';
  static const String getMessages = '/chat/conversations/:id/messages';
  static const String markAsRead = '/chat/conversations/:id/mark-read';
  static const String deleteMessage = '/chat/conversations/:id/messages/:messageId';
  static const String uploadChatMedia = '/chat/conversations/:id/media';
  static const String typingIndicator = '/chat/conversations/:id/typing';

  // Notification endpoints
  static const String getNotifications = '/notifications';
  static const String markNotificationRead = '/notifications/:id/read';
  static const String deleteNotification = '/notifications/:id';
  static const String updateFcmToken = '/notifications/fcm-token';

  // Search & Filter endpoints
  static const String searchUsers = '/search/users';
  static const String getTopMatches = '/discovery/top-matches';
  static const String getNearbyProfiles = '/discovery/nearby';

  // Report & Safety endpoints
  static const String reportUser = '/reports/users';
  static const String reportMessage = '/reports/messages';

  // Subscription/Premium endpoints
  static const String getPricingPlans = '/subscription/plans';
  static const String updateSubscription = '/subscription/update';
  static const String getSubscriptionStatus = '/subscription/status';

  // Analytics endpoints
  static const String trackEvent = '/analytics/events';
  static const String getMeMatchStatistics = '/analytics/me';

  // Helper method to get endpoint with path parameters
  static String getEndpoint(String endpoint, Map<String, String> pathParams) {
    var result = endpoint;
    pathParams.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  // Helper method to get full URL with path parameters
  static String getFullUrlWithParams(String endpoint, Map<String, String> pathParams) {
    return getFullUrl(getEndpoint(endpoint, pathParams));
  }
}
