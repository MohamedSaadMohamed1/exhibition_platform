import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../data/datasources/remote/firestore_datasource.dart';
import '../../data/datasources/remote/firebase_storage_datasource.dart';
import '../../data/datasources/remote/firebase_messaging_datasource.dart';
import '../../data/datasources/local/shared_preferences_datasource.dart';

// ==================== Firebase Instance Providers ====================

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Storage instance provider
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Firebase Messaging instance provider
final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

// ==================== Data Source Providers ====================

/// Firebase Auth Data Source provider
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSourceImpl(ref.watch(firebaseAuthProvider));
});

/// Firestore Data Source provider
final firestoreDataSourceProvider = Provider<FirestoreDataSource>((ref) {
  return FirestoreDataSourceImpl(ref.watch(firestoreProvider));
});

/// Firebase Storage Data Source provider
final firebaseStorageDataSourceProvider =
    Provider<FirebaseStorageDataSource>((ref) {
  return FirebaseStorageDataSourceImpl(ref.watch(firebaseStorageProvider));
});

/// Firebase Messaging Data Source provider
final firebaseMessagingDataSourceProvider =
    Provider<FirebaseMessagingDataSource>((ref) {
  return FirebaseMessagingDataSourceImpl(ref.watch(firebaseMessagingProvider));
});

// ==================== Local Data Source Providers ====================

/// SharedPreferences provider (must be overridden with actual instance)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

/// Local Data Source provider
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return SharedPreferencesDataSource(ref.watch(sharedPreferencesProvider));
});

/// User Preferences provider
final userPreferencesProvider = Provider<UserPreferences>((ref) {
  return UserPreferences(ref.watch(localDataSourceProvider));
});

// ==================== FCM Providers ====================

/// FCM Token provider
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final messagingDataSource = ref.watch(firebaseMessagingDataSourceProvider);
  return await messagingDataSource.getToken();
});

/// FCM Token refresh stream
final fcmTokenRefreshProvider = StreamProvider<String>((ref) {
  final messagingDataSource = ref.watch(firebaseMessagingDataSourceProvider);
  return messagingDataSource.onTokenRefresh;
});

/// Notification settings provider
final notificationSettingsProvider =
    FutureProvider<NotificationSettings>((ref) async {
  final messagingDataSource = ref.watch(firebaseMessagingDataSourceProvider);
  return await messagingDataSource.getNotificationSettings();
});
