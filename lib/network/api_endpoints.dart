import 'package:dating_app/utils/constants.dart';

class ApiEndpoints {
  /// ✅ BASE URL
  static const String baseUrl = AppConstants.baseUrl;

  // ===============================
  // ✅ AUTH (UPDATED)
  // ===============================

  static const String signup = '/users/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  /// ✅ EMAIL OTP FLOW (CORRECT)
  static String sendEmailOtp(String email) =>
      '/users/otp/email/$email';

  static const String verifyEmailOtp =
      '/users/otp/email/validate';

  // ===============================
  // USER
  // ===============================

  static const String getUserProfile = '/users/:id';
  static const String updateUserProfile = '/users/:id';
  static const String deleteAccount = '/users/:id';
  static const String uploadProfilePhoto = '/users/upload-photo';
  static const String deleteProfilePhoto = '/users/delete-photo';
  static const String getUserPreferences = '/users/preferences';
  static const String updateUserPreferences = '/users/preferences';

  // ===============================
  // SWIPE & MATCHES
  // ===============================

  static const String getProfiles = '/profiles';
  static const String getProfileDetail = '/profiles/:id';
  static const String likeProfile = '/profiles/like';
  static const String superLikeProfile = '/profiles/super-like';
  static const String passProfile = '/profiles/pass';
  static const String unlikeProfile = '/profiles/unlike';
  static const String getMatches = '/matches';
  static const String getMatchDetail = '/matches/:id';
  static const String acceptMatch = '/matches/accept';
  static const String rejectMatch = '/matches/reject';
  static const String unmatch = '/matches/unmatch';
  static const String getTopMatches = '/matches/top';
  static const String getNearbyProfiles = '/profiles/nearby';

  // ===============================
  // CHAT
  // ===============================

  static const String getConversations = '/conversations';
  static const String getConversation = '/conversations/:id';
  static const String getMessages = '/conversations/:conversationId/messages';
  static const String sendMessage = '/messages';
  static const String markAsRead = '/conversations/:conversationId/read';
  static const String deleteMessage = '/messages/:id';
  static const String uploadChatMedia = '/messages/upload';
  static const String typingIndicator = '/typing';
  static const String reportMessage = '/messages/report';

  // ===============================
  // BLOCKING
  // ===============================

  static const String blockUser = '/users/:id/block';
  static const String unblockUser = '/users/:id/unblock';
  static const String getBlockedUsers = '/users/blocked';

  // ===============================
  // HELPERS
  // ===============================

  static String getEndpoint(String endpoint, Map<String, String> params) {
    var result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }

  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static String getFullUrlWithParams(
      String endpoint, Map<String, String> params) {
    return getFullUrl(getEndpoint(endpoint, params));
  }
}