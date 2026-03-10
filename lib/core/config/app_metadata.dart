/// App metadata and store information
class AppMetadata {
  AppMetadata._();

  // App Information
  static const String appName = 'ExhibitConnect';
  static const String appDescription =
      'Your complete platform for exhibitions, suppliers, and services';
  static const String appTagline = 'Connect. Exhibit. Succeed.';

  // Contact Information
  static const String supportEmail = 'support@exhibitconnect.com';
  static const String salesEmail = 'sales@exhibitconnect.com';
  static const String websiteUrl = 'https://exhibitconnect.com';
  static const String privacyPolicyUrl = 'https://exhibitconnect.com/privacy';
  static const String termsOfServiceUrl = 'https://exhibitconnect.com/terms';
  static const String faqUrl = 'https://exhibitconnect.com/faq';

  // Social Media
  static const String twitterUrl = 'https://twitter.com/ExhibitConnect';
  static const String instagramUrl = 'https://instagram.com/exhibitconnect';
  static const String facebookUrl = 'https://facebook.com/ExhibitConnect';
  static const String linkedInUrl = 'https://linkedin.com/company/exhibitconnect';

  // Store Links
  static const String appStoreId = '123456789';
  static const String playStoreId = 'com.exhibitconnect.app';
  static const String appStoreUrl =
      'https://apps.apple.com/app/exhibitconnect/id$appStoreId';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$playStoreId';

  // App Store Metadata (for store listings)
  static const String shortDescription =
      'Book exhibition booths, find suppliers, and connect with event organizers.';

  static const String fullDescription = '''
ExhibitConnect is your all-in-one platform for exhibition management and event services.

FOR VISITORS:
• Browse upcoming exhibitions and events
• Get detailed event information and schedules
• Mark events as interested and receive updates
• Find and contact suppliers for event services

FOR EXHIBITORS:
• Discover exhibitions in your industry
• View booth layouts and availability
• Book booths online with secure payment
• Manage your exhibition schedule

FOR SUPPLIERS:
• Showcase your services to exhibitors
• Receive service requests and orders
• Build your reputation with reviews
• Grow your exhibition services business

FOR ORGANIZERS:
• Create and manage exhibitions
• Set up booth layouts and pricing
• Track bookings and revenue
• Communicate with exhibitors

KEY FEATURES:
✓ Real-time availability and booking
✓ Secure payment processing
✓ In-app messaging
✓ Push notifications
✓ Reviews and ratings
✓ Job opportunities
''';

  static const List<String> keywords = [
    'exhibition',
    'trade show',
    'booth booking',
    'event management',
    'supplier marketplace',
    'B2B events',
    'exhibition services',
    'event planning',
  ];

  // Categories
  static const String appStoreCategory = 'Business';
  static const String playStoreCategory = 'Business';

  // Age Rating
  static const String contentRating = '4+'; // App Store
  static const String maturityRating = 'Everyone'; // Play Store

  // Supported Platforms
  static const int minAndroidSdk = 21; // Android 5.0
  static const String minIosVersion = '12.0';

  // Feature Graphics
  static const String featureGraphicPath = 'assets/store/feature_graphic.png';
  static const String iconPath = 'assets/store/app_icon.png';
  static const List<String> screenshotPaths = [
    'assets/store/screenshot_1.png',
    'assets/store/screenshot_2.png',
    'assets/store/screenshot_3.png',
    'assets/store/screenshot_4.png',
    'assets/store/screenshot_5.png',
  ];
}

/// App permissions description for store listings
class AppPermissions {
  static const Map<String, String> androidPermissions = {
    'INTERNET': 'Required for app functionality',
    'CAMERA': 'Used for profile photos and document scanning',
    'READ_EXTERNAL_STORAGE': 'Used for uploading images',
    'WRITE_EXTERNAL_STORAGE': 'Used for downloading documents',
    'RECEIVE_BOOT_COMPLETED': 'For scheduled notifications',
    'VIBRATE': 'For notification alerts',
    'ACCESS_NETWORK_STATE': 'To check connectivity',
  };

  static const Map<String, String> iosPermissions = {
    'NSCameraUsageDescription': 'Used for profile photos and document scanning',
    'NSPhotoLibraryUsageDescription': 'Used for uploading images',
    'NSLocationWhenInUseUsageDescription': 'Used to find events near you',
  };
}

/// Legal information
class LegalInfo {
  static const String companyName = 'ExhibitConnect Inc.';
  static const String copyrightYear = '2024';
  static const String copyright = '© $copyrightYear $companyName. All rights reserved.';

  static const String privacyPolicySummary =
      'We collect minimal data required to provide our services. '
      'Your data is encrypted and never sold to third parties.';

  static const String termsOfServiceSummary =
      'By using ExhibitConnect, you agree to our terms of service '
      'and community guidelines.';
}
