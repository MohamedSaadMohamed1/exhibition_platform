import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/notification_model.dart';

/// Notification repository interface
abstract class NotificationRepository {
  /// Get user notifications
  Future<Either<Failure, List<NotificationModel>>> getUserNotifications(
    String userId, {
    NotificationFilter? filter,
    String? lastNotificationId,
    int limit = 20,
  });

  /// Watch user notifications
  Stream<List<NotificationModel>> watchUserNotifications(
    String userId, {
    NotificationFilter? filter,
    int limit = 50,
  });

  /// Get notification by ID
  Future<Either<Failure, NotificationModel>> getNotificationById(String id);

  /// Mark notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead(String userId);

  /// Delete notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Delete all notifications
  Future<Either<Failure, void>> deleteAllNotifications(String userId);

  /// Get unread count
  Future<Either<Failure, int>> getUnreadCount(String userId);

  /// Watch unread count
  Stream<int> watchUnreadCount(String userId);

  /// Get notification settings
  Future<Either<Failure, NotificationSettings>> getNotificationSettings(
    String userId,
  );

  /// Update notification settings
  Future<Either<Failure, void>> updateNotificationSettings(
    String userId,
    NotificationSettings settings,
  );

  /// Send notification to user
  Future<Either<Failure, void>> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? imageUrl,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? data,
  });

  /// Send notification to multiple users
  Future<Either<Failure, void>> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String body,
    required NotificationType type,
    String? imageUrl,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? data,
  });

  /// Send notification to topic
  Future<Either<Failure, void>> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    required NotificationType type,
    String? imageUrl,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? data,
  });
}
