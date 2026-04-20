import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
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

      if (message.notification == null || !mounted) return;

      // Suppress chat notifications when the user is already viewing that chat
      final activeChatId = ref.read(activeChatIdProvider);
      final msgType = message.data['type'] as String?;
      final msgChatId = message.data['chatId'] as String?;
      if ((msgType == 'new_message' || msgType == 'message') &&
          msgChatId != null &&
          msgChatId == activeChatId) {
        return;
      }

      _showNotificationSnackbar(message);
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
    final type = data[NotificationDataKeys.type] as String?;

    AppLogger.debug('Handling notification tap: type=$type', tag: 'FCM');

    switch (type) {
      case NotificationDataTypes.order:
      case NotificationDataTypes.orderStatus:
        final orderId = data[NotificationDataKeys.orderId] as String?;
        if (orderId != null) {
          router.push('/orders/$orderId');
        }
        break;

      case NotificationDataTypes.message:
      case NotificationDataTypes.newMessage:
        final chatId = data[NotificationDataKeys.chatId] as String?;
        if (chatId != null) {
          router.push('/chats/$chatId');
        }
        break;

      case NotificationDataTypes.exhibition:
      case NotificationDataTypes.exhibitionUpdate:
        final exhibitionId = data[NotificationDataKeys.exhibitionId] as String?;
        if (exhibitionId != null) {
          router.push('/exhibitions/$exhibitionId');
        }
        break;

      case NotificationDataTypes.job:
      case NotificationDataTypes.jobApplication:
      case NotificationDataTypes.jobApplicationStatus:
        final jobId = data[NotificationDataKeys.jobId] as String?;
        if (jobId != null) {
          router.push('/jobs/$jobId');
        }
        break;

      case NotificationDataTypes.booking:
      case NotificationDataTypes.bookingStatus:
      case NotificationDataTypes.bookingRequest:
        final bookingId = data[NotificationDataKeys.bookingId] as String?;
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

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Exhibition Platform',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: router,
        );
      },
    );
  }
}
