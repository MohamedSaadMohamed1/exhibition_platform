import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/json_converters.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

/// Order model - represents an order for a service
@freezed
class OrderModel with _$OrderModel {
  const OrderModel._();

  const factory OrderModel({
    required String id,
    required String serviceId,
    required String supplierId,
    required String customerId,
    String? eventId, // Optional link to event
    String? serviceName,
    String? supplierName,
    String? customerName,
    String? customerPhone,
    String? notes,
    required double totalPrice,
    int? quantity,
    @TimestampConverter() DateTime? serviceDate,
    @TimestampConverter() DateTime? serviceEndDate,
    @Default(OrderStatus.pending) OrderStatus status,
    String? rejectionReason,
    String? cancellationReason,
    String? cancelledBy,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @NullableTimestampConverter() DateTime? confirmedAt,
    @NullableTimestampConverter() DateTime? completedAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  /// Status checks
  bool get isPending => status == OrderStatus.pending;
  bool get isAccepted => status == OrderStatus.accepted;
  bool get isRejected => status == OrderStatus.rejected;
  bool get isInProgress => status == OrderStatus.inProgress;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isCancelled => status == OrderStatus.cancelled;

  /// Check if order can be cancelled
  bool get canBeCancelled => isPending || isAccepted;

  /// Check if order can be accepted
  bool get canBeAccepted => isPending;

  /// Check if order can be marked as in progress
  bool get canStartProgress => isAccepted;

  /// Check if order can be completed
  bool get canBeCompleted => isInProgress;

  /// Get formatted price
  String get formattedPrice => '\$${totalPrice.toStringAsFixed(2)}';

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get status color (for UI)
  String get statusColorHex {
    switch (status) {
      case OrderStatus.pending:
        return '#FFA726'; // Orange
      case OrderStatus.accepted:
        return '#42A5F5'; // Blue
      case OrderStatus.rejected:
        return '#EF5350'; // Red
      case OrderStatus.inProgress:
        return '#7E57C2'; // Purple
      case OrderStatus.completed:
        return '#66BB6A'; // Green
      case OrderStatus.cancelled:
        return '#78909C'; // Grey
    }
  }
}

/// Order status enum
enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
  @JsonValue('inProgress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled;

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.rejected:
        return 'rejected';
      case OrderStatus.inProgress:
        return 'inProgress';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// Order filter model
@freezed
class OrderFilter with _$OrderFilter {
  const OrderFilter._();

  const factory OrderFilter({
    String? serviceId,
    String? supplierId,
    String? customerId,
    String? eventId,
    OrderStatus? status,
    @TimestampConverter() DateTime? fromDate,
    @TimestampConverter() DateTime? toDate,
    @Default(OrderSortBy.createdAt) OrderSortBy sortBy,
    @Default(false) bool ascending,
  }) = _OrderFilter;

  factory OrderFilter.fromJson(Map<String, dynamic> json) =>
      _$OrderFilterFromJson(json);

  /// Check if filter is active
  bool get isActive =>
      serviceId != null ||
      supplierId != null ||
      customerId != null ||
      eventId != null ||
      status != null ||
      fromDate != null ||
      toDate != null;
}

/// Order sort options
enum OrderSortBy {
  createdAt,
  serviceDate,
  totalPrice,
  status,
}

/// Order statistics for supplier dashboard
@freezed
class OrderStats with _$OrderStats {
  const factory OrderStats({
    @Default(0) int totalOrders,
    @Default(0) int pendingOrders,
    @Default(0) int acceptedOrders,
    @Default(0) int inProgressOrders,
    @Default(0) int completedOrders,
    @Default(0) int cancelledOrders,
    @Default(0.0) double totalRevenue,
    @Default(0.0) double pendingRevenue,
  }) = _OrderStats;

  factory OrderStats.fromJson(Map<String, dynamic> json) =>
      _$OrderStatsFromJson(json);
}
