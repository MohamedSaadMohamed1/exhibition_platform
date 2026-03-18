import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'router/app_router.dart';

/// Main application widget
class ExhibitionPlatformApp extends ConsumerStatefulWidget {
  const ExhibitionPlatformApp({super.key});

  @override
  ConsumerState<ExhibitionPlatformApp> createState() =>
      _ExhibitionPlatformAppState();
}

class _ExhibitionPlatformAppState extends ConsumerState<ExhibitionPlatformApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.debug(
        'Received foreground message: ${message.messageId}',
        tag: 'FCM',
      );

      if (message.notification != null && mounted) {
        _showNotificationSnackbar(message);
      }
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.debug(
        'Notification opened app: ${message.messageId}',
        tag: 'FCM',
      );
      _handleNotificationTap(message);
    });

    // Check for initial notification (app was terminated)
    _checkInitialNotification();
  }

  Future<void> _checkInitialNotification() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      AppLogger.debug(
        'App opened from terminated state via notification',
        tag: 'FCM',
      );
      _handleNotificationTap(initialMessage);
    }
  }

  void _showNotificationSnackbar(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.title != null)
              Text(
                notification.title!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (notification.body != null) Text(notification.body!),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _handleNotificationTap(message),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final router = ref.read(goRouterProvider);
    final type = data['type'] as String?;

    AppLogger.debug('Handling notification tap: type=$type', tag: 'FCM');

    switch (type) {
      case 'order':
      case 'order_status':
        final orderId = data['orderId'] as String?;
        if (orderId != null) {
          router.push('/orders/$orderId');
        }
        break;

      case 'message':
      case 'new_message':
        final roomId = data['roomId'] as String?;
        if (roomId != null) {
          router.push('/chat/$roomId');
        }
        break;

      case 'exhibition':
      case 'exhibition_update':
        final exhibitionId = data['exhibitionId'] as String?;
        if (exhibitionId != null) {
          router.push('/exhibitions/$exhibitionId');
        }
        break;

      case 'job':
      case 'job_application':
        final jobId = data['jobId'] as String?;
        if (jobId != null) {
          router.push('/jobs/$jobId');
        }
        break;

      case 'booking':
      case 'booking_status':
        final bookingId = data['bookingId'] as String?;
        if (bookingId != null) {
          router.push('/bookings/$bookingId');
        }
        break;

      default:
        // Navigate to notifications page
        router.push('/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Exhibition Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
