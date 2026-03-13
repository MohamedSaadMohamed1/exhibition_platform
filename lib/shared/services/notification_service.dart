import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/remote/firebase_messaging_datasource.dart';
import '../providers/providers.dart';

/// Notification service for managing FCM notifications
class NotificationService {
  final FirebaseMessagingDataSource _messagingDataSource;
  final FirebaseFirestore _firestore;
  final Ref _ref;

  /// Flag to track if messaging is supported on this platform
  bool _isMessagingSupported = false;

  NotificationService(
    this._messagingDataSource,
    this._firestore,
    this._ref,
  );

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing notification service', tag: 'Notifications');

      // Check if messaging is supported (especially for web)
      if (kIsWeb) {
        try {
          // Try to get token to check if FCM is supported
          await _messagingDataSource.getToken();
          _isMessagingSupported = true;
        } catch (e) {
          AppLogger.warning(
            'FCM not supported on this browser: $e',
            tag: 'Notifications',
          );
          _isMessagingSupported = false;
          return; // Exit early, FCM not supported
        }
      } else {
        _isMessagingSupported = true;
      }

      // Request permissions
      await _messagingDataSource.requestPermission();

      // Set foreground notification options (iOS)
      await _messagingDataSource.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get and store FCM token
      await _updateFcmToken();

      // Listen for token refresh
      _messagingDataSource.onTokenRefresh.listen(_onTokenRefresh);

      AppLogger.info('Notification service initialized', tag: 'Notifications');
    } catch (e) {
      AppLogger.error('Failed to initialize notification service', error: e, tag: 'Notifications');
      _isMessagingSupported = false;
    }
  }

  /// Update FCM token for current user
  Future<void> _updateFcmToken() async {
    try {
      final token = await _messagingDataSource.getToken();
      if (token == null) return;

      final userId = _ref.read(currentUserIdProvider);
      if (userId == null) return;

      await _saveFcmToken(userId, token);
    } catch (e) {
      AppLogger.error('Failed to update FCM token', error: e, tag: 'Notifications');
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String token) async {
    AppLogger.debug('FCM token refreshed', tag: 'Notifications');

    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;

    await _saveFcmToken(userId, token);
  }

  /// Save FCM token to Firestore
  Future<void> _saveFcmToken(String userId, String token) async {
    try {
      await _firestore.collection(FirestoreCollections.users).doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.debug('FCM token saved for user: $userId', tag: 'Notifications');
    } catch (e) {
      AppLogger.error('Failed to save FCM token', error: e, tag: 'Notifications');
    }
  }

  /// Remove FCM token when user logs out
  Future<void> removeFcmToken(String userId) async {
    if (!_isMessagingSupported) return;

    try {
      final token = await _messagingDataSource.getToken();
      if (token == null) return;

      await _firestore.collection(FirestoreCollections.users).doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.debug('FCM token removed for user: $userId', tag: 'Notifications');
    } catch (e) {
      AppLogger.error('Failed to remove FCM token', error: e, tag: 'Notifications');
    }
  }

  /// Subscribe to user-specific topics
  Future<void> subscribeUserTopics(String userId, String role) async {
    if (!_isMessagingSupported) return;

    try {
      // Subscribe to user-specific topic
      await _messagingDataSource.subscribeToTopic(FCMTopics.user(userId));

      // Subscribe to role-specific topic
      await _messagingDataSource.subscribeToTopic(FCMTopics.forRole(role));

      // Subscribe to all users topic
      await _messagingDataSource.subscribeToTopic(FCMTopics.allUsers);

      AppLogger.debug(
        'Subscribed to topics for user: $userId, role: $role',
        tag: 'Notifications',
      );
    } catch (e) {
      AppLogger.error('Failed to subscribe to topics', error: e, tag: 'Notifications');
    }
  }

  /// Unsubscribe from user topics on logout
  Future<void> unsubscribeUserTopics(String userId, String role) async {
    if (!_isMessagingSupported) return;

    try {
      await _messagingDataSource.unsubscribeFromTopic(FCMTopics.user(userId));
      await _messagingDataSource.unsubscribeFromTopic(FCMTopics.forRole(role));
      await _messagingDataSource.unsubscribeFromTopic(FCMTopics.allUsers);

      AppLogger.debug(
        'Unsubscribed from topics for user: $userId',
        tag: 'Notifications',
      );
    } catch (e) {
      AppLogger.error('Failed to unsubscribe from topics', error: e, tag: 'Notifications');
    }
  }

  /// Subscribe to exhibition updates
  Future<void> subscribeToExhibition(String exhibitionId) async {
    if (!_isMessagingSupported) return;

    try {
      await _messagingDataSource.subscribeToTopic(FCMTopics.exhibition(exhibitionId));
      AppLogger.debug(
        'Subscribed to exhibition: $exhibitionId',
        tag: 'Notifications',
      );
    } catch (e) {
      AppLogger.error('Failed to subscribe to exhibition', error: e, tag: 'Notifications');
    }
  }

  /// Unsubscribe from exhibition updates
  Future<void> unsubscribeFromExhibition(String exhibitionId) async {
    if (!_isMessagingSupported) return;

    try {
      await _messagingDataSource.unsubscribeFromTopic(FCMTopics.exhibition(exhibitionId));
      AppLogger.debug(
        'Unsubscribed from exhibition: $exhibitionId',
        tag: 'Notifications',
      );
    } catch (e) {
      AppLogger.error('Failed to unsubscribe from exhibition', error: e, tag: 'Notifications');
    }
  }

  /// Get message stream for foreground notifications
  Stream<RemoteMessage> get onMessage => _messagingDataSource.onMessage;

  /// Get message opened app stream
  Stream<RemoteMessage> get onMessageOpenedApp => _messagingDataSource.onMessageOpenedApp;

  /// Get initial message if app was launched from notification
  Future<RemoteMessage?> getInitialMessage() => _messagingDataSource.getInitialMessage();
}

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    ref.watch(firebaseMessagingDataSourceProvider),
    ref.watch(firestoreProvider),
    ref,
  );
});
