import 'package:dating_app/utils/constants.dart';

class ApiEndpoints {
  /// ✅ BASE URL
  static const String baseUrl = AppConstants.baseUrl;

  // ===============================
  // ✅ AUTH (UPDATED)
  // ===============================

  static const String signup = '/users/register';
  static const String login = '/users/login';
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
  static const String deleteProfilePhoto = '/users/delete-photo/:photoId';
  static const String getUserPreferences = '/users/preferences';
  static const String updateUserPreferences = '/users/preferences';

  // My own profile (no user-id in path)
  static const String getMyProfile = '/profile';       // GET /profile
  static const String updateMyProfile = '/profile';    // PUT /profile

  // ===============================
  // SWIPE & MATCHES
  // ===============================

  static const String getProfiles = '/profiles';
  static const String getProfileDetail = '/profiles/:id';
  static const String getSuggestions = '/users/suggestions';
  static const String swipeRight = '/swipes/right/:userId';
  static const String swipeLeft = '/swipes/left/:userId';
  static const String getSwipeMatches = '/swipes/matches';
  static const String getSwipeLikes = '/swipes/likes';
  static const String getSwipeDislikes = '/swipes/dislikes';
  static const String likeProfile = '/profiles/like';
  static const String superLikeProfile = '/profiles/super-like';
  static const String passProfile = '/profiles/pass';
  static const String unlikeProfile = '/profiles/unlike';
  static const String getMatches = '/matches';
  static const String getMatchDetail = '/matches/:id';
  static const String acceptMatch = '/matches/:id/accept';
  static const String rejectMatch = '/matches/:id/reject';
  static const String unmatch = '/matches/:id/unmatch';
  static const String getTopMatches = '/matches/top';
  static const String getNearbyProfiles = '/profiles/nearby';

  // ===============================
  // CHAT
  // ===============================

  static const String getConversations = '/chats';
  static const String getConversation = '/chats/:chatId';
  static const String createChat = '/chats';             // POST /chats
  static const String updateChat = '/chats/:chatId';    // PUT  /chats/:chatId
  static const String deleteChat = '/chats/:chatId';    // DELETE /chats/:chatId
  static const String getMessages = '/chats/:chatId/messages';
  static const String sendMessage = '/chats/:chatId/messages';
  static const String markAsRead = '/chats/:chatId/read';
  static const String deleteMessage = '/chats/:chatId/messages/:messageId';
  static const String uploadChatMedia = '/chats/:chatId/upload';
  static const String typingIndicator = '/chats/:chatId/typing';
  static const String reportMessage = '/chats/messages/report';
  static const String getChatUsers = '/chat-users';               // GET /chat-users
  static const String getChatByRecipient = '/chats/recipient/:recipientId'; // GET /chats/recipient/:recipientId
  static const String chatHistory = '/chat-history/:userId';      // GET /chat-history/:userId

  // ===============================
  // BLOCKING
  // ===============================

  static const String blockUser = '/users/:id/block';
  static const String unblockUser = '/users/:id/unblock/:blockedUserId';
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
