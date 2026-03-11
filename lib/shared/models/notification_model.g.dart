// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      imageUrl: json['imageUrl'] as String?,
      targetId: json['targetId'] as String?,
      targetType: json['targetType'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      readAt: const NullableTimestampConverter().fromJson(json['readAt']),
    );

Map<String, dynamic> _$$NotificationModelImplToJson(
        _$NotificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'imageUrl': instance.imageUrl,
      'targetId': instance.targetId,
      'targetType': instance.targetType,
      'data': instance.data,
      'isRead': instance.isRead,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'readAt': const NullableTimestampConverter().toJson(instance.readAt),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.eventReminder: 'eventReminder',
  NotificationType.eventUpdate: 'eventUpdate',
  NotificationType.eventCancelled: 'eventCancelled',
  NotificationType.newEvent: 'newEvent',
  NotificationType.bookingConfirmed: 'bookingConfirmed',
  NotificationType.bookingCancelled: 'bookingCancelled',
  NotificationType.bookingReminder: 'bookingReminder',
  NotificationType.paymentReceived: 'paymentReceived',
  NotificationType.paymentFailed: 'paymentFailed',
  NotificationType.orderPlaced: 'orderPlaced',
  NotificationType.orderConfirmed: 'orderConfirmed',
  NotificationType.orderShipped: 'orderShipped',
  NotificationType.orderDelivered: 'orderDelivered',
  NotificationType.orderCancelled: 'orderCancelled',
  NotificationType.jobPosted: 'jobPosted',
  NotificationType.applicationReceived: 'applicationReceived',
  NotificationType.applicationAccepted: 'applicationAccepted',
  NotificationType.applicationRejected: 'applicationRejected',
  NotificationType.newMessage: 'newMessage',
  NotificationType.newReview: 'newReview',
  NotificationType.reviewResponse: 'reviewResponse',
  NotificationType.accountVerified: 'accountVerified',
  NotificationType.profileUpdate: 'profileUpdate',
  NotificationType.systemAnnouncement: 'systemAnnouncement',
  NotificationType.promotional: 'promotional',
};

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationSettingsImpl(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      eventReminders: json['eventReminders'] as bool? ?? true,
      bookingUpdates: json['bookingUpdates'] as bool? ?? true,
      orderUpdates: json['orderUpdates'] as bool? ?? true,
      jobAlerts: json['jobAlerts'] as bool? ?? true,
      chatMessages: json['chatMessages'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? true,
      systemUpdates: json['systemUpdates'] as bool? ?? true,
    );

Map<String, dynamic> _$$NotificationSettingsImplToJson(
        _$NotificationSettingsImpl instance) =>
    <String, dynamic>{
      'pushEnabled': instance.pushEnabled,
      'emailEnabled': instance.emailEnabled,
      'eventReminders': instance.eventReminders,
      'bookingUpdates': instance.bookingUpdates,
      'orderUpdates': instance.orderUpdates,
      'jobAlerts': instance.jobAlerts,
      'chatMessages': instance.chatMessages,
      'promotions': instance.promotions,
      'systemUpdates': instance.systemUpdates,
    };
