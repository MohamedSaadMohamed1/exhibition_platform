import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/logger.dart';

/// Firebase Messaging Data Source Interface
abstract class FirebaseMessagingDataSource {
  /// Get FCM token for this device
  Future<String?> getToken();

  /// Stream of token refresh events
  Stream<String> get onTokenRefresh;

  /// Request notification permissions (iOS)
  Future<NotificationSettings> requestPermission();

  /// Get current notification settings
  Future<NotificationSettings> getNotificationSettings();

  /// Stream of foreground messages
  Stream<RemoteMessage> get onMessage;

  /// Stream of messages when app is opened from background
  Stream<RemoteMessage> get onMessageOpenedApp;

  /// Get initial message if app was opened from terminated state
  Future<RemoteMessage?> getInitialMessage();

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Delete FCM token
  Future<void> deleteToken();

  /// Set foreground notification presentation options (iOS)
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  });
}

/// Firebase Messaging Data Source Implementation
class FirebaseMessagingDataSourceImpl implements FirebaseMessagingDataSource {
  final FirebaseMessaging _messaging;

  FirebaseMessagingDataSourceImpl(this._messaging);

  @override
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      AppLogger.debug('FCM Token: $token', tag: 'FCM');
      return token;
    } catch (e) {
      AppLogger.error('Failed to get FCM token', error: e, tag: 'FCM');
      throw ServerException(
        message: 'Failed to get FCM token: $e',
        originalException: e,
      );
    }
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<NotificationSettings> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      AppLogger.debug(
        'Notification permission: ${settings.authorizationStatus}',
        tag: 'FCM',
      );

      return settings;
    } catch (e) {
      AppLogger.error('Failed to request permission', error: e, tag: 'FCM');
      throw ServerException(
        message: 'Failed to request notification permission: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      return await _messaging.getNotificationSettings();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get notification settings: $e',
        originalException: e,
      );
    }
  }

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();
      if (message != null) {
        AppLogger.debug(
          'Initial message: ${message.messageId}',
          tag: 'FCM',
        );
      }
      return message;
    } catch (e) {
      AppLogger.error('Failed to get initial message', error: e, tag: 'FCM');
      return null;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.debug('Subscribed to topic: $topic', tag: 'FCM');
    } catch (e) {
      AppLogger.error('Failed to subscribe to topic', error: e, tag: 'FCM');
      throw ServerException(
        message: 'Failed to subscribe to topic: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.debug('Unsubscribed from topic: $topic', tag: 'FCM');
    } catch (e) {
      AppLogger.error('Failed to unsubscribe from topic', error: e, tag: 'FCM');
      throw ServerException(
        message: 'Failed to unsubscribe from topic: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      AppLogger.debug('FCM token deleted', tag: 'FCM');
    } catch (e) {
      AppLogger.error('Failed to delete token', error: e, tag: 'FCM');
      throw ServerException(
        message: 'Failed to delete FCM token: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: alert,
        badge: badge,
        sound: sound,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to set foreground options',
        error: e,
        tag: 'FCM',
      );
    }
  }
}

/// FCM Topic names for the app
class FCMTopics {
  FCMTopics._();

  /// All users topic
  static const String allUsers = 'all_users';

  /// Visitors topic
  static const String visitors = 'visitors';

  /// Suppliers topic
  static const String suppliers = 'suppliers';

  /// Organizers topic
  static const String organizers = 'organizers';

  /// Owners topic
  static const String owners = 'owners';

  /// Admins topic
  static const String admins = 'admins';

  /// Exhibition specific topic
  static String exhibition(String exhibitionId) => 'exhibition_$exhibitionId';

  /// User specific topic (for targeted notifications)
  static String user(String userId) => 'user_$userId';

  /// Get topic for role
  static String forRole(String role) {
    switch (role) {
      case 'visitor':
        return visitors;
      case 'supplier':
        return suppliers;
      case 'organizer':
        return organizers;
      case 'owner':
        return owners;
      case 'admin':
        return admins;
      default:
        return allUsers;
    }
  }
}

/// Notification payload helper
class NotificationPayload {
  final String type;
  final Map<String, dynamic> data;

  const NotificationPayload({
    required this.type,
    required this.data,
  });

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload(
      type: message.data['type'] ?? 'general',
      data: message.data,
    );
  }

  /// Check if this is an order notification
  bool get isOrderNotification =>
      type == 'order' ||
      type == 'order_status' ||
      type == 'new_order';

  /// Check if this is a message notification
  bool get isMessageNotification =>
      type == 'message' ||
      type == 'new_message';

  /// Check if this is a booking notification
  bool get isBookingNotification =>
      type == 'booking' ||
      type == 'booking_status' ||
      type == 'booking_request';

  /// Check if this is a job notification
  bool get isJobNotification =>
      type == 'job' ||
      type == 'job_application' ||
      type == 'job_application_status';

  /// Check if this is an exhibition notification
  bool get isExhibitionNotification =>
      type == 'exhibition' ||
      type == 'exhibition_update';

  /// Get target route for navigation
  String? getTargetRoute() {
    if (isOrderNotification && data.containsKey('orderId')) {
      return '/orders/${data['orderId']}';
    }
    if (isMessageNotification && data.containsKey('roomId')) {
      return '/chat/${data['roomId']}';
    }
    if (isBookingNotification && data.containsKey('bookingId')) {
      return '/bookings/${data['bookingId']}';
    }
    if (isJobNotification && data.containsKey('jobId')) {
      return '/jobs/${data['jobId']}';
    }
    if (isExhibitionNotification && data.containsKey('exhibitionId')) {
      return '/exhibitions/${data['exhibitionId']}';
    }
    return null;
  }
}
