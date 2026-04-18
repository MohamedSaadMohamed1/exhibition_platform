import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/services/notification_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../supplier/presentation/providers/supplier_dashboard_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../organizer/presentation/providers/organizer_booking_provider.dart' hide bookingStatsProvider;
import '../../../bookings/presentation/providers/booking_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

/// Auth state class
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? verificationId;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.verificationId,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? verificationId,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Auth status enum
enum AuthStatus {
  initial,
  codeSent,
  verifying,
  authenticated,
  profileIncomplete,
  error,
}

/// Auth Notifier using Riverpod 2.x
class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _authRepository;
  late NotificationService _notificationService;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _notificationService = ref.watch(notificationServiceProvider);
    // Schedule auth check after build completes
    Future.microtask(() => _checkAuthState());
    return const AuthState();
  }

  /// Check initial auth state
  Future<void> _checkAuthState() async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.getCurrentUser();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.initial,
          isLoading: false,
        );
      },
      (user) async {
        if (user != null) {
          if (user.name.isEmpty) {
            state = state.copyWith(
              status: AuthStatus.profileIncomplete,
              user: user,
              isLoading: false,
            );
          } else {
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              isLoading: false,
            );
            // Initialize notifications for authenticated user
            await _initializeNotifications(user);
          }
        } else {
          state = state.copyWith(
            status: AuthStatus.initial,
            isLoading: false,
          );
        }
      },
    );
  }

  /// Initialize notifications for user
  Future<void> _initializeNotifications(UserModel user) async {
    try {
      await _notificationService.initialize();
      await _notificationService.subscribeUserTopics(user.id, user.role.value);
      AppLogger.info('Notifications initialized for user: ${user.id}', tag: 'Auth');
    } catch (e) {
      AppLogger.error('Failed to initialize notifications', error: e, tag: 'Auth');
    }
  }

  /// Send OTP to phone number
  Future<void> sendOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    AppLogger.info('📱 sendOtp called: $countryCode$phoneNumber', tag: 'Auth');
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.sendOtp(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
    );

    result.fold(
      (failure) {
        AppLogger.error('❌ sendOtp FAILED: ${failure.message}', tag: 'Auth');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (verificationId) {
        AppLogger.info('✅ sendOtp SUCCESS, verificationId: $verificationId', tag: 'Auth');
        state = state.copyWith(
          status: AuthStatus.codeSent,
          verificationId: verificationId,
          isLoading: false,
        );
      },
    );
  }

  /// Verify OTP
  Future<void> verifyOtp(String otp) async {
    if (state.verificationId == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Verification ID not found. Please request OTP again.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, status: AuthStatus.verifying);

    final result = await _authRepository.verifyOtp(
      verificationId: state.verificationId!,
      otp: otp,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (user) async {
        if (user.name.isEmpty) {
          state = state.copyWith(
            status: AuthStatus.profileIncomplete,
            user: user,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
          );
          // Initialize notifications for authenticated user
          await _initializeNotifications(user);
          // Force auth stream providers to re-subscribe now that Firestore cache
          // is clear and the new user is fully signed in
          ref.invalidate(currentUserProvider);
          ref.invalidate(firebaseUserProvider);
        }
      },
    );
  }

  /// Complete profile
  Future<void> completeProfile({
    required String name,
    String? email,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true);

    final result = await _authRepository.updateUserProfile(
      userId: state.user!.id,
      name: name,
      email: email,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (user) async {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
        // Initialize notifications after profile completion
        await _initializeNotifications(user);
      },
    );
  }

  /// Update profile
  Future<void> updateProfile({
    String? name,
    String? profileImage,
    String? email,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true);

    final result = await _authRepository.updateUserProfile(
      userId: state.user!.id,
      name: name,
      profileImage: profileImage,
      email: email,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
        );
      },
    );
  }

  /// Sign out
  Future<void> signOut() async {
    final currentUser = state.user;
    state = state.copyWith(isLoading: true);

    // Clean up notifications before signing out
    if (currentUser != null) {
      try {
        await _notificationService.removeFcmToken(currentUser.id);
        await _notificationService.unsubscribeUserTopics(
          currentUser.id,
          currentUser.role.value,
        );
        AppLogger.info('Cleaned up notifications for user: ${currentUser.id}', tag: 'Auth');
      } catch (e) {
        AppLogger.error('Failed to clean up notifications', error: e, tag: 'Auth');
      }
    }

    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (_) {
        // Reset StateProviders so old user's selections don't leak into the next session
        ref.read(selectedSupplierIdProvider.notifier).state = null;
        ref.read(activeChatIdProvider.notifier).state = null;

        // Invalidate core auth stream providers so the new user's Firestore data
        // is fetched fresh (prevents stale name/role showing after account switch)
        ref.invalidate(currentUserProvider);
        ref.invalidate(firebaseUserProvider);

        // Invalidate all user-data providers so they rebuild fresh on next login
        // For family providers, ref.invalidate clears ALL family instances
        ref.invalidate(userSuppliersProvider);
        ref.invalidate(currentSupplierProvider);
        ref.invalidate(myServicesProvider);
        ref.invalidate(myOrdersAsSupplierProvider);
        ref.invalidate(supplierStatsProvider);
        ref.invalidate(recentOrdersProvider);
        ref.invalidate(userChatsProvider);              // family — all instances
        ref.invalidate(organizerBookingProvider);        // family — all instances
        ref.invalidate(organizerBookingStreamProvider);  // family — cancels Firestore streams
        // booking_provider.dart providers
        ref.invalidate(exhibitorBookingsProvider);        // family
        ref.invalidate(exhibitorBookingsStreamProvider);  // family — cancels Firestore stream
        ref.invalidate(organizerBookingsProvider);        // family
        ref.invalidate(organizerBookingsStreamProvider);  // family — cancels Firestore stream
        ref.invalidate(bookingStatsProvider);             // family
        // notification providers — cancel Firestore streams per user
        ref.invalidate(notificationsNotifierProvider);
        ref.invalidate(unreadNotificationsCountProvider); // family — cancels stream
        ref.invalidate(userNotificationsStreamProvider);  // family — cancels stream
        ref.invalidate(notificationSettingsProvider);     // family

        AppLogger.info('All user providers invalidated on sign-out', tag: 'Auth');
        state = const AuthState(status: AuthStatus.initial);
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset state
  void reset() {
    state = const AuthState();
  }
}

/// Auth Notifier Provider
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
