/// Application-wide constants
abstract class AppConstants {
  // App Info
  static const String appName = 'Exhibition Platform';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int chatPageSize = 50;
  static const int searchPageSize = 15;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration otpTimeout = Duration(seconds: 60);
  static const Duration cacheExpiry = Duration(hours: 1);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 1000;
  static const int maxMessageLength = 500;

  // Image
  static const int maxImageSizeKB = 5120; // 5MB
  static const int thumbnailSize = 200;
  static const double imageQuality = 0.8;

  // Booth reservation timeout (minutes)
  static const int boothReservationTimeout = 15;
}

/// Firestore collection names
abstract class FirestoreCollections {
  static const String users = 'users';
  static const String events = 'events';
  static const String exhibitions = 'exhibitions'; // Alias for events
  static const String booths = 'booths';
  static const String bookings = 'bookings';
  static const String bookingRequests = 'booking_requests';
  static const String suppliers = 'suppliers';
  static const String services = 'services';
  static const String orders = 'orders';
  static const String jobs = 'jobs';
  static const String jobApplications = 'job_applications';
  static const String chats = 'chats';
  static const String rooms = 'rooms'; // Alias for chats
  static const String messages = 'messages';
  static const String reviews = 'reviews';
  static const String notifications = 'notifications';
  static const String interests = 'interests';
  static const String interestedUsers = 'interested_users';
  static const String appConfig = 'app_config';
  static const String accountRequests = 'account_requests';
}

/// Firebase Storage paths
abstract class StoragePaths {
  static const String profileImages = 'profile_images';
  static const String eventImages = 'event_images';
  static const String supplierImages = 'supplier_images';
  static const String chatMedia = 'chat_media';
  static const String resumes = 'resumes';
}

/// Asset paths
abstract class AssetPaths {
  static const String images = 'assets/images';
  static const String icons = 'assets/icons';
  static const String animations = 'assets/animations';

  // Specific assets
  static const String logo = '$images/logo.png';
  static const String placeholder = '$images/placeholder.png';
  static const String emptyState = '$animations/empty.json';
  static const String loading = '$animations/loading.json';
}
