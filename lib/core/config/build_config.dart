import 'package:flutter/foundation.dart';
import 'environment.dart';

/// Build configuration for different flavors
class BuildConfig {
  BuildConfig._();

  /// App flavor names
  static const String flavorDev = 'dev';
  static const String flavorStaging = 'staging';
  static const String flavorProd = 'prod';

  /// Get current flavor from environment
  static String get currentFlavor {
    if (AppEnvironment.config.isDevelopment) return flavorDev;
    if (AppEnvironment.config.isStaging) return flavorStaging;
    return flavorProd;
  }

  /// Bundle identifiers
  static String get bundleId {
    switch (currentFlavor) {
      case flavorDev:
        return 'com.exhibitconnect.app.dev';
      case flavorStaging:
        return 'com.exhibitconnect.app.staging';
      default:
        return 'com.exhibitconnect.app';
    }
  }

  /// App name based on flavor
  static String get appName {
    switch (currentFlavor) {
      case flavorDev:
        return 'ExhibitConnect Dev';
      case flavorStaging:
        return 'ExhibitConnect Staging';
      default:
        return 'ExhibitConnect';
    }
  }

  /// Firebase options based on flavor
  static String get firebaseProjectId {
    switch (currentFlavor) {
      case flavorDev:
        return 'exhibition-platform-dev';
      case flavorStaging:
        return 'exhibition-platform-staging';
      default:
        return 'exhibition-platform-prod';
    }
  }

  /// Whether to use emulators
  static bool get useEmulators => kDebugMode && currentFlavor == flavorDev;

  /// Firestore emulator settings
  static const String firestoreEmulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;

  /// Auth emulator settings
  static const String authEmulatorHost = 'localhost';
  static const int authEmulatorPort = 9099;

  /// Storage emulator settings
  static const String storageEmulatorHost = 'localhost';
  static const int storageEmulatorPort = 9199;

  /// Functions emulator settings
  static const String functionsEmulatorHost = 'localhost';
  static const int functionsEmulatorPort = 5001;
}

/// Release notes and changelog
class ReleaseNotes {
  static const String currentVersion = '1.0.0';
  static const String buildDate = '2024-03-10';

  static const List<ReleaseNote> changelog = [
    ReleaseNote(
      version: '1.0.0',
      date: '2024-03-10',
      notes: [
        'Initial release',
        'Event browsing and details',
        'Booth booking system',
        'Supplier marketplace',
        'Jobs portal',
        'Push notifications',
        'Real-time chat',
        'Profile management',
      ],
    ),
  ];
}

class ReleaseNote {
  final String version;
  final String date;
  final List<String> notes;

  const ReleaseNote({
    required this.version,
    required this.date,
    required this.notes,
  });
}
