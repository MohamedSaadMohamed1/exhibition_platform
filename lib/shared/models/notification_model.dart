import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/json_converters.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Notification types
enum NotificationType {
  // Event notifications
  eventReminder,
  eventUpdate,
  eventCancelled,
  newEvent,

  // Booking notifications
  bookingConfirmed,
  bookingCancelled,
  bookingReminder,
  paymentReceived,
  paymentFailed,

  // Order notifications
  orderPlaced,
  orderConfirmed,
  orderShipped,
  orderDelivered,
  orderCancelled,

  // Job notifications
  jobPosted,
  applicationReceived,
  applicationAccepted,
  applicationRejected,

  // Chat notifications
  newMessage,

  // Review notifications
  newReview,
  reviewResponse,

  // System notifications
  accountVerified,
  profileUpdate,
  systemAnnouncement,
  promotional,
}

/// Notification model
@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? imageUrl,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? data,
    @Default(false) bool isRead,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? readAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data() as Map<String, dynamic>;
    final typeStr = rawData['type'] as String?;
    final validTypes = NotificationType.values.map((e) => e.name).toSet();
    final data = <String, dynamic>{
      'id': doc.id,
      ...rawData,
      if (typeStr != null && !validTypes.contains(typeStr))
        'type': NotificationType.systemAnnouncement.name,
    };
    return NotificationModel.fromJson(data);
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = FieldValue.serverTimestamp();
    return json;
  }

  /// Get icon based on notification type
  String get iconName {
    switch (type) {
      case NotificationType.eventReminder:
      case NotificationType.eventUpdate:
      case NotificationType.newEvent:
        return 'event';
      case NotificationType.eventCancelled:
        return 'event_busy';
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingReminder:
        return 'confirmation_number';
      case NotificationType.bookingCancelled:
        return 'cancel';
      case NotificationType.paymentReceived:
        return 'payment';
      case NotificationType.paymentFailed:
        return 'money_off';
      case NotificationType.orderPlaced:
      case NotificationType.orderConfirmed:
        return 'shopping_bag';
      case NotificationType.orderShipped:
        return 'local_shipping';
      case NotificationType.orderDelivered:
        return 'check_circle';
      case NotificationType.orderCancelled:
        return 'cancel';
      case NotificationType.jobPosted:
        return 'work';
      case NotificationType.applicationReceived:
      case NotificationType.applicationAccepted:
      case NotificationType.applicationRejected:
        return 'assignment';
      case NotificationType.newMessage:
        return 'chat';
      case NotificationType.newReview:
      case NotificationType.reviewResponse:
        return 'star';
      case NotificationType.accountVerified:
        return 'verified';
      case NotificationType.profileUpdate:
        return 'person';
      case NotificationType.systemAnnouncement:
        return 'campaign';
      case NotificationType.promotional:
        return 'local_offer';
    }
  }

  /// Get route based on notification type
  String? get targetRoute {
    if (targetId == null) return null;

    switch (type) {
      case NotificationType.eventReminder:
      case NotificationType.eventUpdate:
      case NotificationType.eventCancelled:
      case NotificationType.newEvent:
        return '/events/$targetId';
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingCancelled:
      case NotificationType.bookingReminder:
        return '/bookings/$targetId';
      case NotificationType.orderPlaced:
      case NotificationType.orderConfirmed:
      case NotificationType.orderShipped:
      case NotificationType.orderDelivered:
      case NotificationType.orderCancelled:
        return '/orders/$targetId';
      case NotificationType.jobPosted:
        return '/jobs/$targetId';
      case NotificationType.applicationReceived:
      case NotificationType.applicationAccepted:
      case NotificationType.applicationRejected:
        return '/jobs/$targetId/applications';
      case NotificationType.newMessage:
        return '/chats/$targetId';
      case NotificationType.newReview:
      case NotificationType.reviewResponse:
        return targetType != null ? '/$targetType/$targetId' : null;
      default:
        return null;
    }
  }

  /// Format time ago
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

/// Notification filter
@freezed
class NotificationFilter with _$NotificationFilter {
  const factory NotificationFilter({
    @Default(false) bool unreadOnly,
    List<NotificationType>? types,
    DateTime? fromDate,
    DateTime? toDate,
  }) = _NotificationFilter;
}

/// Notification settings model
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool pushEnabled,
    @Default(true) bool emailEnabled,
    @Default(true) bool eventReminders,
    @Default(true) bool bookingUpdates,
    @Default(true) bool orderUpdates,
    @Default(true) bool jobAlerts,
    @Default(true) bool chatMessages,
    @Default(true) bool promotions,
    @Default(true) bool systemUpdates,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}
