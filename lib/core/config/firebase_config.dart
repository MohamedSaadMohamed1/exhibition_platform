/// Firebase collection names
class FirebaseCollections {
  FirebaseCollections._();

  static const String users = 'users';
  static const String exhibitions = 'exhibitions';
  static const String booths = 'booths';
  static const String suppliers = 'suppliers';
  static const String services = 'services';
  static const String orders = 'orders';
  static const String jobs = 'jobs';
  static const String jobApplications = 'job_applications';
  static const String rooms = 'rooms';
  static const String messages = 'messages';
  static const String reviews = 'reviews';
  static const String notifications = 'notifications';
  static const String appConfig = 'app_config';
  static const String interestedUsers = 'interested_users';
}

/// Firebase storage paths
class FirebaseStoragePaths {
  FirebaseStoragePaths._();

  static const String profileImages = 'profile_images';
  static const String exhibitionImages = 'exhibition_images';
  static const String supplierLogos = 'supplier_logos';
  static const String serviceImages = 'service_images';
  static const String chatImages = 'chat_images';
  static const String reviewImages = 'review_images';
  static const String resumes = 'resumes';
  static const String jobImages = 'job_images';

  /// Get profile image path
  static String getProfileImagePath(String userId) =>
      '$profileImages/$userId/profile.jpg';

  /// Get exhibition image path
  static String getExhibitionImagePath(String exhibitionId, String fileName) =>
      '$exhibitionImages/$exhibitionId/$fileName';

  /// Get supplier logo path
  static String getSupplierLogoPath(String supplierId) =>
      '$supplierLogos/$supplierId/logo.jpg';

  /// Get service image path
  static String getServiceImagePath(String serviceId, String fileName) =>
      '$serviceImages/$serviceId/$fileName';

  /// Get chat image path
  static String getChatImagePath(String roomId, String messageId) =>
      '$chatImages/$roomId/$messageId.jpg';

  /// Get review image path
  static String getReviewImagePath(String reviewId, String fileName) =>
      '$reviewImages/$reviewId/$fileName';

  /// Get resume path
  static String getResumePath(String userId, String fileName) =>
      '$resumes/$userId/$fileName';
}

/// Firebase field names
class FirebaseFields {
  FirebaseFields._();

  // Common fields
  static const String id = 'id';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String isActive = 'isActive';

  // User fields
  static const String phone = 'phone';
  static const String name = 'name';
  static const String email = 'email';
  static const String role = 'role';
  static const String profileImage = 'profileImage';
  static const String fcmTokens = 'fcmTokens';
  static const String isProfileComplete = 'isProfileComplete';

  // Exhibition fields
  static const String title = 'title';
  static const String description = 'description';
  static const String banner = 'banner';
  static const String images = 'images';
  static const String location = 'location';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  static const String organizerId = 'organizerId';
  static const String status = 'status';

  // Booth fields
  static const String exhibitionId = 'exhibitionId';
  static const String price = 'price';
  static const String reservedBy = 'reservedBy';

  // Order fields
  static const String serviceId = 'serviceId';
  static const String supplierId = 'supplierId';
  static const String customerId = 'customerId';
  static const String orderNumber = 'orderNumber';

  // Chat fields
  static const String userIds = 'userIds';
  static const String participants = 'participants';
  static const String lastMessage = 'lastMessage';
  static const String unreadCount = 'unreadCount';
  static const String senderId = 'senderId';
  static const String roomId = 'roomId';
  static const String text = 'text';
  static const String type = 'type';
  static const String isRead = 'isRead';
}
