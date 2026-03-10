import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling background message: ${message.messageId}');
}

/// Push Notification Service
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Android notification channel
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );

  /// Initialize push notifications
  Future<void> initialize() async {
    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    await _getFCMToken();

    // Listen to token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  /// Get FCM token
  Future<String?> _getFCMToken() async {
    _fcmToken = await _messaging.getToken();
    print('FCM Token: $_fcmToken');
    return _fcmToken;
  }

  /// Handle token refresh
  void _onTokenRefresh(String token) {
    _fcmToken = token;
    print('FCM Token refreshed: $token');
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');

    final notification = message.notification;
    final android = message.notification?.android;

    // Show local notification for foreground messages
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle message tap when app is in background
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    _navigateToScreen(message.data);
  }

  /// Handle local notification tap
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateToScreen(data);
    }
  }

  /// Navigate to appropriate screen based on notification data
  void _navigateToScreen(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    // Navigation will be handled by the app using a callback
    _onNotificationTapCallback?.call(type, id, data);
  }

  /// Callback for notification tap
  Function(String? type, String? id, Map<String, dynamic> data)?
      _onNotificationTapCallback;

  /// Set notification tap callback
  void setOnNotificationTap(
    Function(String? type, String? id, Map<String, dynamic> data) callback,
  ) {
    _onNotificationTapCallback = callback;
  }

  /// Save FCM token to user document
  Future<void> saveTokenToUser(String userId) async {
    if (_fcmToken == null) return;

    await _firestore.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([_fcmToken]),
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    });
  }

  /// Remove FCM token from user document
  Future<void> removeTokenFromUser(String userId) async {
    if (_fcmToken == null) return;

    await _firestore.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayRemove([_fcmToken]),
    });
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  /// Subscribe to event notifications
  Future<void> subscribeToEvent(String eventId) async {
    await subscribeToTopic('event_$eventId');
  }

  /// Unsubscribe from event notifications
  Future<void> unsubscribeFromEvent(String eventId) async {
    await unsubscribeFromTopic('event_$eventId');
  }

  /// Subscribe to role-based notifications
  Future<void> subscribeToRole(String role) async {
    await subscribeToTopic('role_$role');
  }
}

/// Push notification service provider
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});
