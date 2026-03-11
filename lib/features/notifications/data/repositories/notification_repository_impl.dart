import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

/// Notification repository implementation
class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection(FirestoreCollections.notifications);

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Future<Either<Failure, List<NotificationModel>>> getUserNotifications(
    String userId, {
    NotificationFilter? filter,
    String? lastNotificationId,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _notificationsRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      // Apply filters
      if (filter != null) {
        if (filter.unreadOnly) {
          query = query.where('isRead', isEqualTo: false);
        }
        if (filter.types != null && filter.types!.isNotEmpty) {
          query = query.where(
            'type',
            whereIn: filter.types!.map((t) => t.name).toList(),
          );
        }
      }

      // Pagination
      if (lastNotificationId != null) {
        final lastDoc = await _notificationsRef.doc(lastNotificationId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.limit(limit).get();
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to fetch notifications: $e'));
    }
  }

  @override
  Stream<List<NotificationModel>> watchUserNotifications(
    String userId, {
    NotificationFilter? filter,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (filter != null && filter.unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<Either<Failure, NotificationModel>> getNotificationById(String id) async {
    try {
      final doc = await _notificationsRef.doc(id).get();

      if (!doc.exists) {
        return Left(NotFoundFailure.withMessage('Notification not found'));
      }

      return Right(NotificationModel.fromFirestore(doc));
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to fetch notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to mark notification as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();

      final unreadDocs = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to mark all notifications as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to delete notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();

      final docs = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to delete all notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      final snapshot = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return Right(snapshot.count ?? 0);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to get unread count: $e'));
    }
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<Either<Failure, NotificationSettings>> getNotificationSettings(
    String userId,
  ) async {
    try {
      final doc = await _usersRef.doc(userId).get();

      if (!doc.exists) {
        return const Right(NotificationSettings());
      }

      final data = doc.data();
      final settingsData = data?['notificationSettings'] as Map<String, dynamic>?;

      if (settingsData == null) {
        return const Right(NotificationSettings());
      }

      return Right(NotificationSettings.fromJson(settingsData));
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to get notification settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings(
    String userId,
    NotificationSettings settings,
  ) async {
    try {
      await _usersRef.doc(userId).update({
        'notificationSettings': settings.toJson(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to update notification settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? imageUrl,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        body: body,
        type: type,
        imageUrl: imageUrl,
        targetId: targetId,
        targetType: targetType,
        data: data,
        createdAt: DateTime.now(),
      );

      await _notificationsRef.add(notification.toFirestore());

      // TODO: Trigger FCM push notification via Cloud Function
      // This would typically be handled by a Cloud Function that
      // listens to new documents in the notifications collection

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to send notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String body,
    required NotificationType type,
    String? imageUrl,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? data,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final userId in userIds) {
        final notification = NotificationModel(
          id: '',
          userId: userId,
          title: title,
          body: body,
          type: type,
          imageUrl: imageUrl,
          targetId: targetId,
          targetType: targetType,
          data: data,
          createdAt: DateTime.now(),
        );

        final docRef = _notificationsRef.doc();
        batch.set(docRef, notification.toFirestore());
      }

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to send bulk notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    required NotificationType type,
    String? imageUrl,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Store in a separate collection for topic notifications
      await _firestore.collection('topicNotifications').add({
        'topic': topic,
        'title': title,
        'body': body,
        'type': type.name,
        'imageUrl': imageUrl,
        'targetId': targetId,
        'targetType': targetType,
        'data': data,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // TODO: Trigger FCM topic notification via Cloud Function

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure.withMessage('Failed to send topic notification: $e'));
    }
  }
}
