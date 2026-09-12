import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration
  static const String _defaultBaseUrl =
      'https://dating-backend-rust.vercel.app';

  static String get baseUrl {
    if (!dotenv.isInitialized) return _defaultBaseUrl;
    final url = dotenv.env['BASE_URL'];
    if (url != null && url.isNotEmpty) return url;
    return _defaultBaseUrl;
  }

  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // App Configuration
  static const String appName = 'Velora';
  static const String appVersion = '1.0.0';

  // Firebase
  static const String firebaseProjectId = 'dating-app-project';

  // Assets
  static const String noProfileImage = 'assets/images/no_profile.png';
  static const String defaultAvatar = 'assets/images/default_avatar.png';

  // Pagination
  static const int pageSize = 10;
  static const int initialPageSize = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration userProfileCacheDuration = Duration(hours: 6);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 20.0;

  // Age Range
  static const int minAge = 18;
  static const int maxAge = 70;

  // Swipe Constants
  static const double swipeThreshold = 0.3; // 30% of screen
  static const Duration swipeAnimationDuration = Duration(milliseconds: 300);

  // Chat Constants
  static const int maxChatMessageLength = 1000;
  static const Duration typingIndicatorDuration = Duration(seconds: 3);

  // Profile Constants
  static const int maxBioLength = 500;
  static const int maxPhotos = 9;
  static const int minPhotos = 1;

  // Match Features
  static const int maxLikesPerDay = 100;
  static const int maxMessagesPerDay = 999;

  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Unauthorized access';
  static const String notFoundError = 'Resource not found';
  static const String invalidInputError = 'Invalid input provided';

  // Features Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableOfflineMode = true;
}

class DateTimeConstants {
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';
}

class StorageKeys {
  // Authentication
  static const String userToken = 'user_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';

  // User Data
  static const String userData = 'user_data';
  static const String userProfile = 'user_profile';
  static const String userPreferences = 'user_preferences';

  // App Settings
  static const String isDarkMode = 'is_dark_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String locationEnabled = 'location_enabled';
  static const String isFirstLaunch = 'is_first_launch';

  // Cache
  static const String cachedProfiles = 'cached_profiles';
  static const String cachedMatches = 'cached_matches';
  static const String cachedChats = 'cached_chats';

  // User Preferences
  static const String ageRange = 'age_range';
  static const String distanceRange = 'distance_range';
  static const String lookingFor = 'looking_for';
  static const String interests = 'interests';
}

enum UserLookingFor {
  dating,
  relationship,
  friendship,
  networking
}

enum Gender {
  male,
  female,
  other
}

enum RelationshipStatus {
  single,
  divorced,
  widowed,
  complicated
}

enum MatchStatus {
  pending,
  accepted,
  rejected,
  expired
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read
}
