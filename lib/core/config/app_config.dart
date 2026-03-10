import 'environment.dart';

/// App configuration class
class AppConfig {
  AppConfig._();

  /// Get current environment config
  static EnvironmentConfig get environment => AppEnvironment.config;

  /// App version
  static const String version = '1.0.0';

  /// Build number
  static const String buildNumber = '1';

  /// Full version string
  static String get fullVersion => '$version+$buildNumber';

  /// Pagination settings
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Cache settings
  static const Duration cacheTimeout = Duration(minutes: 30);
  static const Duration shortCacheTimeout = Duration(minutes: 5);
  static const Duration longCacheTimeout = Duration(hours: 24);

  /// Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Retry settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Image settings
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int thumbnailSize = 200;
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// File upload settings
  static const int maxFileSizeInBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileExtensions = ['pdf', 'doc', 'docx'];

  /// OTP settings
  static const int otpLength = 6;
  static const Duration otpTimeout = Duration(seconds: 60);
  static const int maxOtpRetries = 3;

  /// Chat settings
  static const int maxMessageLength = 1000;
  static const int chatPageSize = 50;

  /// Review settings
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int maxReviewLength = 500;

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  /// Debounce durations
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration buttonDebounce = Duration(milliseconds: 300);
}
