// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get targetId => throw _privateConstructorUsedError;
  String? get targetType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get readAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
          NotificationModel value, $Res Function(NotificationModel) then) =
      _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String body,
      NotificationType type,
      String? imageUrl,
      String? targetId,
      String? targetType,
      Map<String, dynamic>? data,
      bool isRead,
      @TimestampConverter() DateTime createdAt,
      @NullableTimestampConverter() DateTime? readAt});
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? imageUrl = freezed,
    Object? targetId = freezed,
    Object? targetType = freezed,
    Object? data = freezed,
    Object? isRead = null,
    Object? createdAt = null,
    Object? readAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      targetId: freezed == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetType: freezed == targetType
          ? _value.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(_$NotificationModelImpl value,
          $Res Function(_$NotificationModelImpl) then) =
      __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String body,
      NotificationType type,
      String? imageUrl,
      String? targetId,
      String? targetType,
      Map<String, dynamic>? data,
      bool isRead,
      @TimestampConverter() DateTime createdAt,
      @NullableTimestampConverter() DateTime? readAt});
}

/// @nodoc
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(_$NotificationModelImpl _value,
      $Res Function(_$NotificationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? imageUrl = freezed,
    Object? targetId = freezed,
    Object? targetType = freezed,
    Object? data = freezed,
    Object? isRead = null,
    Object? createdAt = null,
    Object? readAt = freezed,
  }) {
    return _then(_$NotificationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      targetId: freezed == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetType: freezed == targetType
          ? _value.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationModelImpl extends _NotificationModel {
  const _$NotificationModelImpl(
      {required this.id,
      required this.userId,
      required this.title,
      required this.body,
      required this.type,
      this.imageUrl,
      this.targetId,
      this.targetType,
      final Map<String, dynamic>? data,
      this.isRead = false,
      @TimestampConverter() required this.createdAt,
      @NullableTimestampConverter() this.readAt})
      : _data = data,
        super._();

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String body;
  @override
  final NotificationType type;
  @override
  final String? imageUrl;
  @override
  final String? targetId;
  @override
  final String? targetType;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isRead;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @NullableTimestampConverter()
  final DateTime? readAt;

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, title: $title, body: $body, type: $type, imageUrl: $imageUrl, targetId: $targetId, targetType: $targetType, data: $data, isRead: $isRead, createdAt: $createdAt, readAt: $readAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.readAt, readAt) || other.readAt == readAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      body,
      type,
      imageUrl,
      targetId,
      targetType,
      const DeepCollectionEquality().hash(_data),
      isRead,
      createdAt,
      readAt);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationModel extends NotificationModel {
  const factory _NotificationModel(
          {required final String id,
          required final String userId,
          required final String title,
          required final String body,
          required final NotificationType type,
          final String? imageUrl,
          final String? targetId,
          final String? targetType,
          final Map<String, dynamic>? data,
          final bool isRead,
          @TimestampConverter() required final DateTime createdAt,
          @NullableTimestampConverter() final DateTime? readAt}) =
      _$NotificationModelImpl;
  const _NotificationModel._() : super._();

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  String get body;
  @override
  NotificationType get type;
  @override
  String? get imageUrl;
  @override
  String? get targetId;
  @override
  String? get targetType;
  @override
  Map<String, dynamic>? get data;
  @override
  bool get isRead;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @NullableTimestampConverter()
  DateTime? get readAt;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NotificationFilter {
  bool get unreadOnly => throw _privateConstructorUsedError;
  List<NotificationType>? get types => throw _privateConstructorUsedError;
  DateTime? get fromDate => throw _privateConstructorUsedError;
  DateTime? get toDate => throw _privateConstructorUsedError;

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationFilterCopyWith<NotificationFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationFilterCopyWith<$Res> {
  factory $NotificationFilterCopyWith(
          NotificationFilter value, $Res Function(NotificationFilter) then) =
      _$NotificationFilterCopyWithImpl<$Res, NotificationFilter>;
  @useResult
  $Res call(
      {bool unreadOnly,
      List<NotificationType>? types,
      DateTime? fromDate,
      DateTime? toDate});
}

/// @nodoc
class _$NotificationFilterCopyWithImpl<$Res, $Val extends NotificationFilter>
    implements $NotificationFilterCopyWith<$Res> {
  _$NotificationFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unreadOnly = null,
    Object? types = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
  }) {
    return _then(_value.copyWith(
      unreadOnly: null == unreadOnly
          ? _value.unreadOnly
          : unreadOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      types: freezed == types
          ? _value.types
          : types // ignore: cast_nullable_to_non_nullable
              as List<NotificationType>?,
      fromDate: freezed == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      toDate: freezed == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationFilterImplCopyWith<$Res>
    implements $NotificationFilterCopyWith<$Res> {
  factory _$$NotificationFilterImplCopyWith(_$NotificationFilterImpl value,
          $Res Function(_$NotificationFilterImpl) then) =
      __$$NotificationFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool unreadOnly,
      List<NotificationType>? types,
      DateTime? fromDate,
      DateTime? toDate});
}

/// @nodoc
class __$$NotificationFilterImplCopyWithImpl<$Res>
    extends _$NotificationFilterCopyWithImpl<$Res, _$NotificationFilterImpl>
    implements _$$NotificationFilterImplCopyWith<$Res> {
  __$$NotificationFilterImplCopyWithImpl(_$NotificationFilterImpl _value,
      $Res Function(_$NotificationFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unreadOnly = null,
    Object? types = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
  }) {
    return _then(_$NotificationFilterImpl(
      unreadOnly: null == unreadOnly
          ? _value.unreadOnly
          : unreadOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      types: freezed == types
          ? _value._types
          : types // ignore: cast_nullable_to_non_nullable
              as List<NotificationType>?,
      fromDate: freezed == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      toDate: freezed == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$NotificationFilterImpl implements _NotificationFilter {
  const _$NotificationFilterImpl(
      {this.unreadOnly = false,
      final List<NotificationType>? types,
      this.fromDate,
      this.toDate})
      : _types = types;

  @override
  @JsonKey()
  final bool unreadOnly;
  final List<NotificationType>? _types;
  @override
  List<NotificationType>? get types {
    final value = _types;
    if (value == null) return null;
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? fromDate;
  @override
  final DateTime? toDate;

  @override
  String toString() {
    return 'NotificationFilter(unreadOnly: $unreadOnly, types: $types, fromDate: $fromDate, toDate: $toDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationFilterImpl &&
            (identical(other.unreadOnly, unreadOnly) ||
                other.unreadOnly == unreadOnly) &&
            const DeepCollectionEquality().equals(other._types, _types) &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, unreadOnly,
      const DeepCollectionEquality().hash(_types), fromDate, toDate);

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationFilterImplCopyWith<_$NotificationFilterImpl> get copyWith =>
      __$$NotificationFilterImplCopyWithImpl<_$NotificationFilterImpl>(
          this, _$identity);
}

abstract class _NotificationFilter implements NotificationFilter {
  const factory _NotificationFilter(
      {final bool unreadOnly,
      final List<NotificationType>? types,
      final DateTime? fromDate,
      final DateTime? toDate}) = _$NotificationFilterImpl;

  @override
  bool get unreadOnly;
  @override
  List<NotificationType>? get types;
  @override
  DateTime? get fromDate;
  @override
  DateTime? get toDate;

  /// Create a copy of NotificationFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationFilterImplCopyWith<_$NotificationFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  bool get pushEnabled => throw _privateConstructorUsedError;
  bool get emailEnabled => throw _privateConstructorUsedError;
  bool get eventReminders => throw _privateConstructorUsedError;
  bool get bookingUpdates => throw _privateConstructorUsedError;
  bool get orderUpdates => throw _privateConstructorUsedError;
  bool get jobAlerts => throw _privateConstructorUsedError;
  bool get chatMessages => throw _privateConstructorUsedError;
  bool get promotions => throw _privateConstructorUsedError;
  bool get systemUpdates => throw _privateConstructorUsedError;

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(NotificationSettings value,
          $Res Function(NotificationSettings) then) =
      _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call(
      {bool pushEnabled,
      bool emailEnabled,
      bool eventReminders,
      bool bookingUpdates,
      bool orderUpdates,
      bool jobAlerts,
      bool chatMessages,
      bool promotions,
      bool systemUpdates});
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res,
        $Val extends NotificationSettings>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pushEnabled = null,
    Object? emailEnabled = null,
    Object? eventReminders = null,
    Object? bookingUpdates = null,
    Object? orderUpdates = null,
    Object? jobAlerts = null,
    Object? chatMessages = null,
    Object? promotions = null,
    Object? systemUpdates = null,
  }) {
    return _then(_value.copyWith(
      pushEnabled: null == pushEnabled
          ? _value.pushEnabled
          : pushEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      emailEnabled: null == emailEnabled
          ? _value.emailEnabled
          : emailEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      eventReminders: null == eventReminders
          ? _value.eventReminders
          : eventReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingUpdates: null == bookingUpdates
          ? _value.bookingUpdates
          : bookingUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      orderUpdates: null == orderUpdates
          ? _value.orderUpdates
          : orderUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      jobAlerts: null == jobAlerts
          ? _value.jobAlerts
          : jobAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      chatMessages: null == chatMessages
          ? _value.chatMessages
          : chatMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      promotions: null == promotions
          ? _value.promotions
          : promotions // ignore: cast_nullable_to_non_nullable
              as bool,
      systemUpdates: null == systemUpdates
          ? _value.systemUpdates
          : systemUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(_$NotificationSettingsImpl value,
          $Res Function(_$NotificationSettingsImpl) then) =
      __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool pushEnabled,
      bool emailEnabled,
      bool eventReminders,
      bool bookingUpdates,
      bool orderUpdates,
      bool jobAlerts,
      bool chatMessages,
      bool promotions,
      bool systemUpdates});
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(_$NotificationSettingsImpl _value,
      $Res Function(_$NotificationSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pushEnabled = null,
    Object? emailEnabled = null,
    Object? eventReminders = null,
    Object? bookingUpdates = null,
    Object? orderUpdates = null,
    Object? jobAlerts = null,
    Object? chatMessages = null,
    Object? promotions = null,
    Object? systemUpdates = null,
  }) {
    return _then(_$NotificationSettingsImpl(
      pushEnabled: null == pushEnabled
          ? _value.pushEnabled
          : pushEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      emailEnabled: null == emailEnabled
          ? _value.emailEnabled
          : emailEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      eventReminders: null == eventReminders
          ? _value.eventReminders
          : eventReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingUpdates: null == bookingUpdates
          ? _value.bookingUpdates
          : bookingUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      orderUpdates: null == orderUpdates
          ? _value.orderUpdates
          : orderUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      jobAlerts: null == jobAlerts
          ? _value.jobAlerts
          : jobAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      chatMessages: null == chatMessages
          ? _value.chatMessages
          : chatMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      promotions: null == promotions
          ? _value.promotions
          : promotions // ignore: cast_nullable_to_non_nullable
              as bool,
      systemUpdates: null == systemUpdates
          ? _value.systemUpdates
          : systemUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSettingsImpl implements _NotificationSettings {
  const _$NotificationSettingsImpl(
      {this.pushEnabled = true,
      this.emailEnabled = true,
      this.eventReminders = true,
      this.bookingUpdates = true,
      this.orderUpdates = true,
      this.jobAlerts = true,
      this.chatMessages = true,
      this.promotions = true,
      this.systemUpdates = true});

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool pushEnabled;
  @override
  @JsonKey()
  final bool emailEnabled;
  @override
  @JsonKey()
  final bool eventReminders;
  @override
  @JsonKey()
  final bool bookingUpdates;
  @override
  @JsonKey()
  final bool orderUpdates;
  @override
  @JsonKey()
  final bool jobAlerts;
  @override
  @JsonKey()
  final bool chatMessages;
  @override
  @JsonKey()
  final bool promotions;
  @override
  @JsonKey()
  final bool systemUpdates;

  @override
  String toString() {
    return 'NotificationSettings(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled, eventReminders: $eventReminders, bookingUpdates: $bookingUpdates, orderUpdates: $orderUpdates, jobAlerts: $jobAlerts, chatMessages: $chatMessages, promotions: $promotions, systemUpdates: $systemUpdates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.pushEnabled, pushEnabled) ||
                other.pushEnabled == pushEnabled) &&
            (identical(other.emailEnabled, emailEnabled) ||
                other.emailEnabled == emailEnabled) &&
            (identical(other.eventReminders, eventReminders) ||
                other.eventReminders == eventReminders) &&
            (identical(other.bookingUpdates, bookingUpdates) ||
                other.bookingUpdates == bookingUpdates) &&
            (identical(other.orderUpdates, orderUpdates) ||
                other.orderUpdates == orderUpdates) &&
            (identical(other.jobAlerts, jobAlerts) ||
                other.jobAlerts == jobAlerts) &&
            (identical(other.chatMessages, chatMessages) ||
                other.chatMessages == chatMessages) &&
            (identical(other.promotions, promotions) ||
                other.promotions == promotions) &&
            (identical(other.systemUpdates, systemUpdates) ||
                other.systemUpdates == systemUpdates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      pushEnabled,
      emailEnabled,
      eventReminders,
      bookingUpdates,
      orderUpdates,
      jobAlerts,
      chatMessages,
      promotions,
      systemUpdates);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith =>
          __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _NotificationSettings implements NotificationSettings {
  const factory _NotificationSettings(
      {final bool pushEnabled,
      final bool emailEnabled,
      final bool eventReminders,
      final bool bookingUpdates,
      final bool orderUpdates,
      final bool jobAlerts,
      final bool chatMessages,
      final bool promotions,
      final bool systemUpdates}) = _$NotificationSettingsImpl;

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  @override
  bool get pushEnabled;
  @override
  bool get emailEnabled;
  @override
  bool get eventReminders;
  @override
  bool get bookingUpdates;
  @override
  bool get orderUpdates;
  @override
  bool get jobAlerts;
  @override
  bool get chatMessages;
  @override
  bool get promotions;
  @override
  bool get systemUpdates;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
