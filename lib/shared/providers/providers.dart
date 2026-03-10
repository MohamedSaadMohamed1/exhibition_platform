import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../models/user_model.dart';
import 'firebase_providers.dart';
import 'repository_providers.dart';

// Re-export for backward compatibility
export 'firebase_providers.dart';
export 'repository_providers.dart';

// ==================== Auth State Providers ====================

/// Current Firebase User Stream
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Current User Model Provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Current User ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(firebaseUserProvider).valueOrNull?.uid;
});

/// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider).valueOrNull != null;
});

/// User Role Provider
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUserProvider).valueOrNull?.role;
});
