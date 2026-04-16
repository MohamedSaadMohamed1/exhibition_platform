import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/config/environment.dart';
import 'core/config/injection.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';

/// Background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notification = message.notification;
  if (notification == null) return;

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(const InitializationSettings(android: androidSettings));

  await plugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

/// Bootstrap function to initialize the app
Future<void> bootstrap(
  Widget Function(List<Override> overrides) builder, {
  EnvironmentConfig? environment,
}) async {
  // Run in a guarded zone to catch all errors
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Set environment
      if (environment != null) {
        AppEnvironment.setEnvironment(environment);
      }

      // Initialize Firebase first
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Firestore settings for web immediately after init,
      // before any Firestore reads/writes
      if (kIsWeb) {
        try {
          FirebaseFirestore.instance.settings = const Settings(
            persistenceEnabled: false,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
          AppLogger.info(
            'Firestore configured for web without persistence',
            tag: 'Bootstrap',
          );
        } catch (e) {
          AppLogger.warning(
            'Failed to configure Firestore settings: $e',
            tag: 'Bootstrap',
          );
        }
      }

      // Set up background message handler (only for mobile)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
      }

      // Request notification permissions (mobile only)
      if (!kIsWeb) {
        await _requestNotificationPermissions();
      }

      // Set preferred orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // Initialize dependencies
      final overrides = await initializeDependencies();

      // Log app start
      AppLogger.info(
        'App started in ${AppEnvironment.config.environment.name} mode',
        tag: 'Bootstrap',
      );

      // Run the app
      runApp(builder(overrides));
    },
    (error, stackTrace) {
      AppLogger.error(
        'Unhandled error',
        tag: 'Bootstrap',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

/// Request notification permissions for iOS
Future<void> _requestNotificationPermissions() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  AppLogger.debug(
    'Notification permission status: ${settings.authorizationStatus}',
    tag: 'Bootstrap',
  );
}

/// Error widget for production
class AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const AppErrorWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (kDebugMode)
                  Text(
                    details.exception.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
