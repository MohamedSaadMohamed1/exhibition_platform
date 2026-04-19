/// Firestore collection names
abstract class FirestoreCollections {
  static const String users = 'users';
  static const String events = 'events';
  static const String booths = 'booths';
  static const String bookings = 'bookings';
  static const String bookingRequests = 'booking_requests';
  static const String suppliers = 'suppliers';
  static const String services = 'services';
  static const String orders = 'orders';
  static const String reviews = 'reviews';
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String notifications = 'notifications';
  static const String jobs = 'jobs';
  static const String jobApplications = 'job_applications';
  static const String interests = 'interests';
  static const String favorites = 'favorites';
  static const String payments = 'payments';
  static const String analytics = 'analytics';
  static const String settings = 'settings';
  static const String reports = 'reports';
  static const String logs = 'logs';
  static const String supportTickets = 'support_tickets';
  static const String businessRequests = 'business_requests';
}

/// Storage bucket paths
abstract class StoragePaths {
  static const String profileImages = 'profile_images';
  static const String eventImages = 'event_images';
  static const String supplierImages = 'supplier_images';
  static const String serviceImages = 'service_images';
  static const String chatMedia = 'chat_media';
  static const String resumes = 'resumes';
  static const String documents = 'documents';
}
