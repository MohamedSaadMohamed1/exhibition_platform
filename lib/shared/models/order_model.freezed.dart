// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  String get serviceId => throw _privateConstructorUsedError;
  String get supplierId => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String? get eventId =>
      throw _privateConstructorUsedError; // Optional link to event
  List<String> get serviceIds =>
      throw _privateConstructorUsedError; // Multiple selected service IDs
  List<String> get serviceNames =>
      throw _privateConstructorUsedError; // Multiple selected service names
  String? get serviceName => throw _privateConstructorUsedError;
  String? get supplierName => throw _privateConstructorUsedError;
  String? get customerName => throw _privateConstructorUsedError;
  String? get customerPhone => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  int? get quantity => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get serviceDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get serviceEndDate => throw _privateConstructorUsedError;
  Map<String, dynamic> get serviceSchedules =>
      throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  String? get cancelledBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
          OrderModel value, $Res Function(OrderModel) then) =
      _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call(
      {String id,
      String serviceId,
      String supplierId,
      String customerId,
      String? eventId,
      List<String> serviceIds,
      List<String> serviceNames,
      String? serviceName,
      String? supplierName,
      String? customerName,
      String? customerPhone,
      String? notes,
      double totalPrice,
      int? quantity,
      @TimestampConverter() DateTime? serviceDate,
      @TimestampConverter() DateTime? serviceEndDate,
      Map<String, dynamic> serviceSchedules,
      OrderStatus status,
      String? rejectionReason,
      String? cancellationReason,
      String? cancelledBy,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt,
      @NullableTimestampConverter() DateTime? confirmedAt,
      @NullableTimestampConverter() DateTime? completedAt});
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceId = null,
    Object? supplierId = null,
    Object? customerId = null,
    Object? eventId = freezed,
    Object? serviceIds = null,
    Object? serviceNames = null,
    Object? serviceName = freezed,
    Object? supplierName = freezed,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? notes = freezed,
    Object? totalPrice = null,
    Object? quantity = freezed,
    Object? serviceDate = freezed,
    Object? serviceEndDate = freezed,
    Object? serviceSchedules = null,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? cancellationReason = freezed,
    Object? cancelledBy = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? confirmedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      serviceId: null == serviceId
          ? _value.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceIds: null == serviceIds
          ? _value.serviceIds
          : serviceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      serviceNames: null == serviceNames
          ? _value.serviceNames
          : serviceNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      serviceName: freezed == serviceName
          ? _value.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierName: freezed == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int?,
      serviceDate: freezed == serviceDate
          ? _value.serviceDate
          : serviceDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serviceEndDate: freezed == serviceEndDate
          ? _value.serviceEndDate
          : serviceEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serviceSchedules: null == serviceSchedules
          ? _value.serviceSchedules
          : serviceSchedules // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledBy: freezed == cancelledBy
          ? _value.cancelledBy
          : cancelledBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
          _$OrderModelImpl value, $Res Function(_$OrderModelImpl) then) =
      __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String serviceId,
      String supplierId,
      String customerId,
      String? eventId,
      List<String> serviceIds,
      List<String> serviceNames,
      String? serviceName,
      String? supplierName,
      String? customerName,
      String? customerPhone,
      String? notes,
      double totalPrice,
      int? quantity,
      @TimestampConverter() DateTime? serviceDate,
      @TimestampConverter() DateTime? serviceEndDate,
      Map<String, dynamic> serviceSchedules,
      OrderStatus status,
      String? rejectionReason,
      String? cancellationReason,
      String? cancelledBy,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt,
      @NullableTimestampConverter() DateTime? confirmedAt,
      @NullableTimestampConverter() DateTime? completedAt});
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
      _$OrderModelImpl _value, $Res Function(_$OrderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceId = null,
    Object? supplierId = null,
    Object? customerId = null,
    Object? eventId = freezed,
    Object? serviceIds = null,
    Object? serviceNames = null,
    Object? serviceName = freezed,
    Object? supplierName = freezed,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? notes = freezed,
    Object? totalPrice = null,
    Object? quantity = freezed,
    Object? serviceDate = freezed,
    Object? serviceEndDate = freezed,
    Object? serviceSchedules = null,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? cancellationReason = freezed,
    Object? cancelledBy = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? confirmedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_$OrderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      serviceId: null == serviceId
          ? _value.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceIds: null == serviceIds
          ? _value._serviceIds
          : serviceIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      serviceNames: null == serviceNames
          ? _value._serviceNames
          : serviceNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      serviceName: freezed == serviceName
          ? _value.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierName: freezed == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int?,
      serviceDate: freezed == serviceDate
          ? _value.serviceDate
          : serviceDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serviceEndDate: freezed == serviceEndDate
          ? _value.serviceEndDate
          : serviceEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serviceSchedules: null == serviceSchedules
          ? _value._serviceSchedules
          : serviceSchedules // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledBy: freezed == cancelledBy
          ? _value.cancelledBy
          : cancelledBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl extends _OrderModel {
  const _$OrderModelImpl(
      {required this.id,
      required this.serviceId,
      required this.supplierId,
      required this.customerId,
      this.eventId,
      final List<String> serviceIds = const [],
      final List<String> serviceNames = const [],
      this.serviceName,
      this.supplierName,
      this.customerName,
      this.customerPhone,
      this.notes,
      required this.totalPrice,
      this.quantity,
      @TimestampConverter() this.serviceDate,
      @TimestampConverter() this.serviceEndDate,
      final Map<String, dynamic> serviceSchedules = const {},
      this.status = OrderStatus.pending,
      this.rejectionReason,
      this.cancellationReason,
      this.cancelledBy,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() this.updatedAt,
      @NullableTimestampConverter() this.confirmedAt,
      @NullableTimestampConverter() this.completedAt})
      : _serviceIds = serviceIds,
        _serviceNames = serviceNames,
        _serviceSchedules = serviceSchedules,
        super._();

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  final String id;
  @override
  final String serviceId;
  @override
  final String supplierId;
  @override
  final String customerId;
  @override
  final String? eventId;
// Optional link to event
  final List<String> _serviceIds;
// Optional link to event
  @override
  @JsonKey()
  List<String> get serviceIds {
    if (_serviceIds is EqualUnmodifiableListView) return _serviceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_serviceIds);
  }

// Multiple selected service IDs
  final List<String> _serviceNames;
// Multiple selected service IDs
  @override
  @JsonKey()
  List<String> get serviceNames {
    if (_serviceNames is EqualUnmodifiableListView) return _serviceNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_serviceNames);
  }

// Multiple selected service names
  @override
  final String? serviceName;
  @override
  final String? supplierName;
  @override
  final String? customerName;
  @override
  final String? customerPhone;
  @override
  final String? notes;
  @override
  final double totalPrice;
  @override
  final int? quantity;
  @override
  @TimestampConverter()
  final DateTime? serviceDate;
  @override
  @TimestampConverter()
  final DateTime? serviceEndDate;
  final Map<String, dynamic> _serviceSchedules;
  @override
  @JsonKey()
  Map<String, dynamic> get serviceSchedules {
    if (_serviceSchedules is EqualUnmodifiableMapView) return _serviceSchedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_serviceSchedules);
  }

  @override
  @JsonKey()
  final OrderStatus status;
  @override
  final String? rejectionReason;
  @override
  final String? cancellationReason;
  @override
  final String? cancelledBy;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? confirmedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? completedAt;

  @override
  String toString() {
    return 'OrderModel(id: $id, serviceId: $serviceId, supplierId: $supplierId, customerId: $customerId, eventId: $eventId, serviceIds: $serviceIds, serviceNames: $serviceNames, serviceName: $serviceName, supplierName: $supplierName, customerName: $customerName, customerPhone: $customerPhone, notes: $notes, totalPrice: $totalPrice, quantity: $quantity, serviceDate: $serviceDate, serviceEndDate: $serviceEndDate, serviceSchedules: $serviceSchedules, status: $status, rejectionReason: $rejectionReason, cancellationReason: $cancellationReason, cancelledBy: $cancelledBy, createdAt: $createdAt, updatedAt: $updatedAt, confirmedAt: $confirmedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            const DeepCollectionEquality()
                .equals(other._serviceIds, _serviceIds) &&
            const DeepCollectionEquality()
                .equals(other._serviceNames, _serviceNames) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.serviceDate, serviceDate) ||
                other.serviceDate == serviceDate) &&
            (identical(other.serviceEndDate, serviceEndDate) ||
                other.serviceEndDate == serviceEndDate) &&
            const DeepCollectionEquality()
                .equals(other._serviceSchedules, _serviceSchedules) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.cancelledBy, cancelledBy) ||
                other.cancelledBy == cancelledBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        serviceId,
        supplierId,
        customerId,
        eventId,
        const DeepCollectionEquality().hash(_serviceIds),
        const DeepCollectionEquality().hash(_serviceNames),
        serviceName,
        supplierName,
        customerName,
        customerPhone,
        notes,
        totalPrice,
        quantity,
        serviceDate,
        serviceEndDate,
        const DeepCollectionEquality().hash(_serviceSchedules),
        status,
        rejectionReason,
        cancellationReason,
        cancelledBy,
        createdAt,
        updatedAt,
        confirmedAt,
        completedAt
      ]);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(
      this,
    );
  }
}

abstract class _OrderModel extends OrderModel {
  const factory _OrderModel(
          {required final String id,
          required final String serviceId,
          required final String supplierId,
          required final String customerId,
          final String? eventId,
          final List<String> serviceIds,
          final List<String> serviceNames,
          final String? serviceName,
          final String? supplierName,
          final String? customerName,
          final String? customerPhone,
          final String? notes,
          required final double totalPrice,
          final int? quantity,
          @TimestampConverter() final DateTime? serviceDate,
          @TimestampConverter() final DateTime? serviceEndDate,
          final Map<String, dynamic> serviceSchedules,
          final OrderStatus status,
          final String? rejectionReason,
          final String? cancellationReason,
          final String? cancelledBy,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() final DateTime? updatedAt,
          @NullableTimestampConverter() final DateTime? confirmedAt,
          @NullableTimestampConverter() final DateTime? completedAt}) =
      _$OrderModelImpl;
  const _OrderModel._() : super._();

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  String get id;
  @override
  String get serviceId;
  @override
  String get supplierId;
  @override
  String get customerId;
  @override
  String? get eventId; // Optional link to event
  @override
  List<String> get serviceIds; // Multiple selected service IDs
  @override
  List<String> get serviceNames; // Multiple selected service names
  @override
  String? get serviceName;
  @override
  String? get supplierName;
  @override
  String? get customerName;
  @override
  String? get customerPhone;
  @override
  String? get notes;
  @override
  double get totalPrice;
  @override
  int? get quantity;
  @override
  @TimestampConverter()
  DateTime? get serviceDate;
  @override
  @TimestampConverter()
  DateTime? get serviceEndDate;
  @override
  Map<String, dynamic> get serviceSchedules;
  @override
  OrderStatus get status;
  @override
  String? get rejectionReason;
  @override
  String? get cancellationReason;
  @override
  String? get cancelledBy;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get confirmedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get completedAt;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderFilter _$OrderFilterFromJson(Map<String, dynamic> json) {
  return _OrderFilter.fromJson(json);
}

/// @nodoc
mixin _$OrderFilter {
  String? get serviceId => throw _privateConstructorUsedError;
  String? get supplierId => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get eventId => throw _privateConstructorUsedError;
  OrderStatus? get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get fromDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get toDate => throw _privateConstructorUsedError;
  OrderSortBy get sortBy => throw _privateConstructorUsedError;
  bool get ascending => throw _privateConstructorUsedError;

  /// Serializes this OrderFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderFilterCopyWith<OrderFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderFilterCopyWith<$Res> {
  factory $OrderFilterCopyWith(
          OrderFilter value, $Res Function(OrderFilter) then) =
      _$OrderFilterCopyWithImpl<$Res, OrderFilter>;
  @useResult
  $Res call(
      {String? serviceId,
      String? supplierId,
      String? customerId,
      String? eventId,
      OrderStatus? status,
      @TimestampConverter() DateTime? fromDate,
      @TimestampConverter() DateTime? toDate,
      OrderSortBy sortBy,
      bool ascending});
}

/// @nodoc
class _$OrderFilterCopyWithImpl<$Res, $Val extends OrderFilter>
    implements $OrderFilterCopyWith<$Res> {
  _$OrderFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceId = freezed,
    Object? supplierId = freezed,
    Object? customerId = freezed,
    Object? eventId = freezed,
    Object? status = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_value.copyWith(
      serviceId: freezed == serviceId
          ? _value.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus?,
      fromDate: freezed == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      toDate: freezed == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as OrderSortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderFilterImplCopyWith<$Res>
    implements $OrderFilterCopyWith<$Res> {
  factory _$$OrderFilterImplCopyWith(
          _$OrderFilterImpl value, $Res Function(_$OrderFilterImpl) then) =
      __$$OrderFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? serviceId,
      String? supplierId,
      String? customerId,
      String? eventId,
      OrderStatus? status,
      @TimestampConverter() DateTime? fromDate,
      @TimestampConverter() DateTime? toDate,
      OrderSortBy sortBy,
      bool ascending});
}

/// @nodoc
class __$$OrderFilterImplCopyWithImpl<$Res>
    extends _$OrderFilterCopyWithImpl<$Res, _$OrderFilterImpl>
    implements _$$OrderFilterImplCopyWith<$Res> {
  __$$OrderFilterImplCopyWithImpl(
      _$OrderFilterImpl _value, $Res Function(_$OrderFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceId = freezed,
    Object? supplierId = freezed,
    Object? customerId = freezed,
    Object? eventId = freezed,
    Object? status = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_$OrderFilterImpl(
      serviceId: freezed == serviceId
          ? _value.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus?,
      fromDate: freezed == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      toDate: freezed == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as OrderSortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderFilterImpl extends _OrderFilter {
  const _$OrderFilterImpl(
      {this.serviceId,
      this.supplierId,
      this.customerId,
      this.eventId,
      this.status,
      @TimestampConverter() this.fromDate,
      @TimestampConverter() this.toDate,
      this.sortBy = OrderSortBy.createdAt,
      this.ascending = false})
      : super._();

  factory _$OrderFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderFilterImplFromJson(json);

  @override
  final String? serviceId;
  @override
  final String? supplierId;
  @override
  final String? customerId;
  @override
  final String? eventId;
  @override
  final OrderStatus? status;
  @override
  @TimestampConverter()
  final DateTime? fromDate;
  @override
  @TimestampConverter()
  final DateTime? toDate;
  @override
  @JsonKey()
  final OrderSortBy sortBy;
  @override
  @JsonKey()
  final bool ascending;

  @override
  String toString() {
    return 'OrderFilter(serviceId: $serviceId, supplierId: $supplierId, customerId: $customerId, eventId: $eventId, status: $status, fromDate: $fromDate, toDate: $toDate, sortBy: $sortBy, ascending: $ascending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderFilterImpl &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.ascending, ascending) ||
                other.ascending == ascending));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, serviceId, supplierId,
      customerId, eventId, status, fromDate, toDate, sortBy, ascending);

  /// Create a copy of OrderFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderFilterImplCopyWith<_$OrderFilterImpl> get copyWith =>
      __$$OrderFilterImplCopyWithImpl<_$OrderFilterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderFilterImplToJson(
      this,
    );
  }
}

abstract class _OrderFilter extends OrderFilter {
  const factory _OrderFilter(
      {final String? serviceId,
      final String? supplierId,
      final String? customerId,
      final String? eventId,
      final OrderStatus? status,
      @TimestampConverter() final DateTime? fromDate,
      @TimestampConverter() final DateTime? toDate,
      final OrderSortBy sortBy,
      final bool ascending}) = _$OrderFilterImpl;
  const _OrderFilter._() : super._();

  factory _OrderFilter.fromJson(Map<String, dynamic> json) =
      _$OrderFilterImpl.fromJson;

  @override
  String? get serviceId;
  @override
  String? get supplierId;
  @override
  String? get customerId;
  @override
  String? get eventId;
  @override
  OrderStatus? get status;
  @override
  @TimestampConverter()
  DateTime? get fromDate;
  @override
  @TimestampConverter()
  DateTime? get toDate;
  @override
  OrderSortBy get sortBy;
  @override
  bool get ascending;

  /// Create a copy of OrderFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderFilterImplCopyWith<_$OrderFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderStats _$OrderStatsFromJson(Map<String, dynamic> json) {
  return _OrderStats.fromJson(json);
}

/// @nodoc
mixin _$OrderStats {
  int get totalOrders => throw _privateConstructorUsedError;
  int get pendingOrders => throw _privateConstructorUsedError;
  int get acceptedOrders => throw _privateConstructorUsedError;
  int get inProgressOrders => throw _privateConstructorUsedError;
  int get completedOrders => throw _privateConstructorUsedError;
  int get cancelledOrders => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;
  double get pendingRevenue => throw _privateConstructorUsedError;

  /// Serializes this OrderStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderStatsCopyWith<OrderStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderStatsCopyWith<$Res> {
  factory $OrderStatsCopyWith(
          OrderStats value, $Res Function(OrderStats) then) =
      _$OrderStatsCopyWithImpl<$Res, OrderStats>;
  @useResult
  $Res call(
      {int totalOrders,
      int pendingOrders,
      int acceptedOrders,
      int inProgressOrders,
      int completedOrders,
      int cancelledOrders,
      double totalRevenue,
      double pendingRevenue});
}

/// @nodoc
class _$OrderStatsCopyWithImpl<$Res, $Val extends OrderStats>
    implements $OrderStatsCopyWith<$Res> {
  _$OrderStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalOrders = null,
    Object? pendingOrders = null,
    Object? acceptedOrders = null,
    Object? inProgressOrders = null,
    Object? completedOrders = null,
    Object? cancelledOrders = null,
    Object? totalRevenue = null,
    Object? pendingRevenue = null,
  }) {
    return _then(_value.copyWith(
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      pendingOrders: null == pendingOrders
          ? _value.pendingOrders
          : pendingOrders // ignore: cast_nullable_to_non_nullable
              as int,
      acceptedOrders: null == acceptedOrders
          ? _value.acceptedOrders
          : acceptedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      inProgressOrders: null == inProgressOrders
          ? _value.inProgressOrders
          : inProgressOrders // ignore: cast_nullable_to_non_nullable
              as int,
      completedOrders: null == completedOrders
          ? _value.completedOrders
          : completedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledOrders: null == cancelledOrders
          ? _value.cancelledOrders
          : cancelledOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      pendingRevenue: null == pendingRevenue
          ? _value.pendingRevenue
          : pendingRevenue // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderStatsImplCopyWith<$Res>
    implements $OrderStatsCopyWith<$Res> {
  factory _$$OrderStatsImplCopyWith(
          _$OrderStatsImpl value, $Res Function(_$OrderStatsImpl) then) =
      __$$OrderStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalOrders,
      int pendingOrders,
      int acceptedOrders,
      int inProgressOrders,
      int completedOrders,
      int cancelledOrders,
      double totalRevenue,
      double pendingRevenue});
}

/// @nodoc
class __$$OrderStatsImplCopyWithImpl<$Res>
    extends _$OrderStatsCopyWithImpl<$Res, _$OrderStatsImpl>
    implements _$$OrderStatsImplCopyWith<$Res> {
  __$$OrderStatsImplCopyWithImpl(
      _$OrderStatsImpl _value, $Res Function(_$OrderStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalOrders = null,
    Object? pendingOrders = null,
    Object? acceptedOrders = null,
    Object? inProgressOrders = null,
    Object? completedOrders = null,
    Object? cancelledOrders = null,
    Object? totalRevenue = null,
    Object? pendingRevenue = null,
  }) {
    return _then(_$OrderStatsImpl(
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      pendingOrders: null == pendingOrders
          ? _value.pendingOrders
          : pendingOrders // ignore: cast_nullable_to_non_nullable
              as int,
      acceptedOrders: null == acceptedOrders
          ? _value.acceptedOrders
          : acceptedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      inProgressOrders: null == inProgressOrders
          ? _value.inProgressOrders
          : inProgressOrders // ignore: cast_nullable_to_non_nullable
              as int,
      completedOrders: null == completedOrders
          ? _value.completedOrders
          : completedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledOrders: null == cancelledOrders
          ? _value.cancelledOrders
          : cancelledOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      pendingRevenue: null == pendingRevenue
          ? _value.pendingRevenue
          : pendingRevenue // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderStatsImpl implements _OrderStats {
  const _$OrderStatsImpl(
      {this.totalOrders = 0,
      this.pendingOrders = 0,
      this.acceptedOrders = 0,
      this.inProgressOrders = 0,
      this.completedOrders = 0,
      this.cancelledOrders = 0,
      this.totalRevenue = 0.0,
      this.pendingRevenue = 0.0});

  factory _$OrderStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderStatsImplFromJson(json);

  @override
  @JsonKey()
  final int totalOrders;
  @override
  @JsonKey()
  final int pendingOrders;
  @override
  @JsonKey()
  final int acceptedOrders;
  @override
  @JsonKey()
  final int inProgressOrders;
  @override
  @JsonKey()
  final int completedOrders;
  @override
  @JsonKey()
  final int cancelledOrders;
  @override
  @JsonKey()
  final double totalRevenue;
  @override
  @JsonKey()
  final double pendingRevenue;

  @override
  String toString() {
    return 'OrderStats(totalOrders: $totalOrders, pendingOrders: $pendingOrders, acceptedOrders: $acceptedOrders, inProgressOrders: $inProgressOrders, completedOrders: $completedOrders, cancelledOrders: $cancelledOrders, totalRevenue: $totalRevenue, pendingRevenue: $pendingRevenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderStatsImpl &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders) &&
            (identical(other.pendingOrders, pendingOrders) ||
                other.pendingOrders == pendingOrders) &&
            (identical(other.acceptedOrders, acceptedOrders) ||
                other.acceptedOrders == acceptedOrders) &&
            (identical(other.inProgressOrders, inProgressOrders) ||
                other.inProgressOrders == inProgressOrders) &&
            (identical(other.completedOrders, completedOrders) ||
                other.completedOrders == completedOrders) &&
            (identical(other.cancelledOrders, cancelledOrders) ||
                other.cancelledOrders == cancelledOrders) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.pendingRevenue, pendingRevenue) ||
                other.pendingRevenue == pendingRevenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalOrders,
      pendingOrders,
      acceptedOrders,
      inProgressOrders,
      completedOrders,
      cancelledOrders,
      totalRevenue,
      pendingRevenue);

  /// Create a copy of OrderStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderStatsImplCopyWith<_$OrderStatsImpl> get copyWith =>
      __$$OrderStatsImplCopyWithImpl<_$OrderStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderStatsImplToJson(
      this,
    );
  }
}

abstract class _OrderStats implements OrderStats {
  const factory _OrderStats(
      {final int totalOrders,
      final int pendingOrders,
      final int acceptedOrders,
      final int inProgressOrders,
      final int completedOrders,
      final int cancelledOrders,
      final double totalRevenue,
      final double pendingRevenue}) = _$OrderStatsImpl;

  factory _OrderStats.fromJson(Map<String, dynamic> json) =
      _$OrderStatsImpl.fromJson;

  @override
  int get totalOrders;
  @override
  int get pendingOrders;
  @override
  int get acceptedOrders;
  @override
  int get inProgressOrders;
  @override
  int get completedOrders;
  @override
  int get cancelledOrders;
  @override
  double get totalRevenue;
  @override
  double get pendingRevenue;

  /// Create a copy of OrderStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderStatsImplCopyWith<_$OrderStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
