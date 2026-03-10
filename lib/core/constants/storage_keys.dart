/// Local storage keys
class StorageKeys {
  StorageKeys._();

  // Auth keys
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';

  // User preferences
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricEnabled = 'biometric_enabled';

  // Onboarding
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  static const String isFirstLaunch = 'is_first_launch';

  // FCM
  static const String fcmToken = 'fcm_token';
  static const String fcmTokenLastUpdated = 'fcm_token_last_updated';

  // Cache
  static const String userCache = 'user_cache';
  static const String exhibitionsCache = 'exhibitions_cache';
  static const String lastCacheUpdate = 'last_cache_update';

  // Search history
  static const String searchHistory = 'search_history';
  static const String recentViews = 'recent_views';

  // App state
  static const String lastActiveTimestamp = 'last_active_timestamp';
  static const String appVersion = 'app_version';
}
