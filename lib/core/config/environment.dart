/// Environment configuration for the app
enum Environment {
  development,
  staging,
  production,
}

/// Environment configuration class
class EnvironmentConfig {
  final Environment environment;
  final String appName;
  final String baseUrl;
  final bool enableLogging;
  final bool enableCrashlytics;

  const EnvironmentConfig({
    required this.environment,
    required this.appName,
    required this.baseUrl,
    required this.enableLogging,
    required this.enableCrashlytics,
  });

  /// Development environment configuration
  static const development = EnvironmentConfig(
    environment: Environment.development,
    appName: 'Exhibition Platform (Dev)',
    baseUrl: 'https://dev-api.exhibition-platform.com',
    enableLogging: true,
    enableCrashlytics: false,
  );

  /// Staging environment configuration
  static const staging = EnvironmentConfig(
    environment: Environment.staging,
    appName: 'Exhibition Platform (Staging)',
    baseUrl: 'https://staging-api.exhibition-platform.com',
    enableLogging: true,
    enableCrashlytics: true,
  );

  /// Production environment configuration
  static const production = EnvironmentConfig(
    environment: Environment.production,
    appName: 'Exhibition Platform',
    baseUrl: 'https://api.exhibition-platform.com',
    enableLogging: false,
    enableCrashlytics: true,
  );

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}

/// Current environment - change this for different builds
class AppEnvironment {
  static EnvironmentConfig _config = EnvironmentConfig.development;

  static EnvironmentConfig get config => _config;

  static void setEnvironment(EnvironmentConfig config) {
    _config = config;
  }

  static void setDevelopment() {
    _config = EnvironmentConfig.development;
  }

  static void setStaging() {
    _config = EnvironmentConfig.staging;
  }

  static void setProduction() {
    _config = EnvironmentConfig.production;
  }
}

/// Feature flags for controlling app features
class FeatureFlags {
  FeatureFlags._();

  /// Enable new booking flow UI
  static bool get enableNewBookingFlow =>
      AppEnvironment.config.isDevelopment || AppEnvironment.config.isStaging;

  /// Enable chat feature
  static bool get enableChat => true;

  /// Enable jobs marketplace feature
  static bool get enableJobs => true;

  /// Enable supplier marketplace feature
  static bool get enableSuppliers => true;

  /// Enable push notifications
  static bool get enablePushNotifications => true;

  /// Enable biometric authentication
  static bool get enableBiometricAuth =>
      AppEnvironment.config.isProduction || AppEnvironment.config.isStaging;

  /// Enable offline mode
  static bool get enableOfflineMode => true;

  /// Enable dark mode
  static bool get enableDarkMode => true;

  /// Show debug information
  static bool get showDebugInfo => AppEnvironment.config.isDevelopment;

  /// Enable analytics tracking
  static bool get enableAnalytics => !AppEnvironment.config.isDevelopment;

  /// Enable performance monitoring
  static bool get enablePerformanceMonitoring => true;

  /// Enable in-app reviews
  static bool get enableInAppReview => AppEnvironment.config.isProduction;

  /// Enable social login
  static bool get enableSocialLogin => true;

  /// Enable QR code scanner
  static bool get enableQRScanner => true;
}
