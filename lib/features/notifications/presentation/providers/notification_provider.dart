import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/notification_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/notification_repository.dart';

/// Notifications state
class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final NotificationFilter filter;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.filter = const NotificationFilter(),
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    NotificationFilter? filter,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

/// Notifications notifier
class NotificationsNotifier extends FamilyNotifier<NotificationsState, String> {
  late NotificationRepository _notificationRepository;

  @override
  NotificationsState build(String userId) {
    _notificationRepository = ref.watch(notificationRepositoryProvider);
    _loadNotifications(userId);
    return const NotificationsState(isLoading: true);
  }

  Future<void> _loadNotifications(String userId, {bool refresh = false}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      notifications: refresh ? [] : state.notifications,
    );

    final result = await _notificationRepository.getUserNotifications(
      userId,
      filter: state.filter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (notifications) {
        state = state.copyWith(
          notifications: notifications,
          isLoading: false,
          hasMore: notifications.length >= 20,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final lastId = state.notifications.isNotEmpty
        ? state.notifications.last.id
        : null;

    state = state.copyWith(isLoading: true);

    final result = await _notificationRepository.getUserNotifications(
      arg,
      filter: state.filter,
      lastNotificationId: lastId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (notifications) {
        state = state.copyWith(
          notifications: [...state.notifications, ...notifications],
          isLoading: false,
          hasMore: notifications.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadNotifications(arg, refresh: true);
  }

  void applyFilter(NotificationFilter filter) {
    state = state.copyWith(filter: filter);
    _loadNotifications(arg, refresh: true);
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await _notificationRepository.markAsRead(notificationId);

    result.fold(
      (failure) {
        // Handle error silently
      },
      (_) {
        // Update local state
        final updated = state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true, readAt: DateTime.now());
          }
          return n;
        }).toList();
        state = state.copyWith(notifications: updated);
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await _notificationRepository.markAllAsRead(arg);

    result.fold(
      (failure) {
        // Handle error silently
      },
      (_) {
        // Update local state
        final updated = state.notifications.map((n) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }).toList();
        state = state.copyWith(notifications: updated);
      },
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    final result = await _notificationRepository.deleteNotification(notificationId);

    result.fold(
      (failure) {
        // Handle error silently
      },
      (_) {
        // Update local state
        final updated = state.notifications
            .where((n) => n.id != notificationId)
            .toList();
        state = state.copyWith(notifications: updated);
      },
    );
  }

  Future<void> deleteAllNotifications() async {
    final result = await _notificationRepository.deleteAllNotifications(arg);

    result.fold(
      (failure) {
        // Handle error silently
      },
      (_) {
        state = state.copyWith(notifications: []);
      },
    );
  }
}

/// Notifications notifier provider
final notificationsNotifierProvider = NotifierProvider.family<
    NotificationsNotifier, NotificationsState, String>(() {
  return NotificationsNotifier();
});

/// Unread notifications count provider
final unreadNotificationsCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchUnreadCount(userId);
});

/// User notifications stream provider
final userNotificationsStreamProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchUserNotifications(userId);
});

/// Notification settings provider
final notificationSettingsProvider =
    FutureProvider.family<NotificationSettings, String>((ref, userId) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getNotificationSettings(userId);
  return result.fold(
    (l) => const NotificationSettings(),
    (r) => r,
  );
});
