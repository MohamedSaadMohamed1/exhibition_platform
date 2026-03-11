// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      supplierId: json['supplierId'] as String,
      customerId: json['customerId'] as String,
      eventId: json['eventId'] as String?,
      serviceName: json['serviceName'] as String?,
      supplierName: json['supplierName'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      notes: json['notes'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toInt(),
      serviceDate: const TimestampConverter().fromJson(json['serviceDate']),
      serviceEndDate:
          const TimestampConverter().fromJson(json['serviceEndDate']),
      status: $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
          OrderStatus.pending,
      rejectionReason: json['rejectionReason'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      confirmedAt:
          const NullableTimestampConverter().fromJson(json['confirmedAt']),
      completedAt:
          const NullableTimestampConverter().fromJson(json['completedAt']),
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'supplierId': instance.supplierId,
      'customerId': instance.customerId,
      'eventId': instance.eventId,
      'serviceName': instance.serviceName,
      'supplierName': instance.supplierName,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'notes': instance.notes,
      'totalPrice': instance.totalPrice,
      'quantity': instance.quantity,
      'serviceDate': _$JsonConverterToJson<dynamic, DateTime>(
          instance.serviceDate, const TimestampConverter().toJson),
      'serviceEndDate': _$JsonConverterToJson<dynamic, DateTime>(
          instance.serviceEndDate, const TimestampConverter().toJson),
      'status': _$OrderStatusEnumMap[instance.status]!,
      'rejectionReason': instance.rejectionReason,
      'cancellationReason': instance.cancellationReason,
      'cancelledBy': instance.cancelledBy,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
      'confirmedAt':
          const NullableTimestampConverter().toJson(instance.confirmedAt),
      'completedAt':
          const NullableTimestampConverter().toJson(instance.completedAt),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.accepted: 'accepted',
  OrderStatus.rejected: 'rejected',
  OrderStatus.inProgress: 'inProgress',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

_$OrderFilterImpl _$$OrderFilterImplFromJson(Map<String, dynamic> json) =>
    _$OrderFilterImpl(
      serviceId: json['serviceId'] as String?,
      supplierId: json['supplierId'] as String?,
      customerId: json['customerId'] as String?,
      eventId: json['eventId'] as String?,
      status: $enumDecodeNullable(_$OrderStatusEnumMap, json['status']),
      fromDate: const TimestampConverter().fromJson(json['fromDate']),
      toDate: const TimestampConverter().fromJson(json['toDate']),
      sortBy: $enumDecodeNullable(_$OrderSortByEnumMap, json['sortBy']) ??
          OrderSortBy.createdAt,
      ascending: json['ascending'] as bool? ?? false,
    );

Map<String, dynamic> _$$OrderFilterImplToJson(_$OrderFilterImpl instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'supplierId': instance.supplierId,
      'customerId': instance.customerId,
      'eventId': instance.eventId,
      'status': _$OrderStatusEnumMap[instance.status],
      'fromDate': _$JsonConverterToJson<dynamic, DateTime>(
          instance.fromDate, const TimestampConverter().toJson),
      'toDate': _$JsonConverterToJson<dynamic, DateTime>(
          instance.toDate, const TimestampConverter().toJson),
      'sortBy': _$OrderSortByEnumMap[instance.sortBy]!,
      'ascending': instance.ascending,
    };

const _$OrderSortByEnumMap = {
  OrderSortBy.createdAt: 'createdAt',
  OrderSortBy.serviceDate: 'serviceDate',
  OrderSortBy.totalPrice: 'totalPrice',
  OrderSortBy.status: 'status',
};

_$OrderStatsImpl _$$OrderStatsImplFromJson(Map<String, dynamic> json) =>
    _$OrderStatsImpl(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      acceptedOrders: (json['acceptedOrders'] as num?)?.toInt() ?? 0,
      inProgressOrders: (json['inProgressOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      pendingRevenue: (json['pendingRevenue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$OrderStatsImplToJson(_$OrderStatsImpl instance) =>
    <String, dynamic>{
      'totalOrders': instance.totalOrders,
      'pendingOrders': instance.pendingOrders,
      'acceptedOrders': instance.acceptedOrders,
      'inProgressOrders': instance.inProgressOrders,
      'completedOrders': instance.completedOrders,
      'cancelledOrders': instance.cancelledOrders,
      'totalRevenue': instance.totalRevenue,
      'pendingRevenue': instance.pendingRevenue,
    };
