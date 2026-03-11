// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

JobModel _$JobModelFromJson(Map<String, dynamic> json) {
  return _JobModel.fromJson(json);
}

/// @nodoc
mixin _$JobModel {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get organizerId => throw _privateConstructorUsedError;
  String? get eventTitle => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get requirements => throw _privateConstructorUsedError;
  String? get salary => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get jobType =>
      throw _privateConstructorUsedError; // Full-time, Part-time, Contract
  @TimestampConverter()
  DateTime get deadline => throw _privateConstructorUsedError;
  int get applicationsCount => throw _privateConstructorUsedError;
  JobStatus get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this JobModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobModelCopyWith<JobModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobModelCopyWith<$Res> {
  factory $JobModelCopyWith(JobModel value, $Res Function(JobModel) then) =
      _$JobModelCopyWithImpl<$Res, JobModel>;
  @useResult
  $Res call(
      {String id,
      String eventId,
      String organizerId,
      String? eventTitle,
      String title,
      String description,
      List<String> requirements,
      String? salary,
      String? location,
      String? jobType,
      @TimestampConverter() DateTime deadline,
      int applicationsCount,
      JobStatus status,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$JobModelCopyWithImpl<$Res, $Val extends JobModel>
    implements $JobModelCopyWith<$Res> {
  _$JobModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? organizerId = null,
    Object? eventTitle = freezed,
    Object? title = null,
    Object? description = null,
    Object? requirements = null,
    Object? salary = freezed,
    Object? location = freezed,
    Object? jobType = freezed,
    Object? deadline = null,
    Object? applicationsCount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      eventTitle: freezed == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      requirements: null == requirements
          ? _value.requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      salary: freezed == salary
          ? _value.salary
          : salary // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      jobType: freezed == jobType
          ? _value.jobType
          : jobType // ignore: cast_nullable_to_non_nullable
              as String?,
      deadline: null == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime,
      applicationsCount: null == applicationsCount
          ? _value.applicationsCount
          : applicationsCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as JobStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobModelImplCopyWith<$Res>
    implements $JobModelCopyWith<$Res> {
  factory _$$JobModelImplCopyWith(
          _$JobModelImpl value, $Res Function(_$JobModelImpl) then) =
      __$$JobModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String eventId,
      String organizerId,
      String? eventTitle,
      String title,
      String description,
      List<String> requirements,
      String? salary,
      String? location,
      String? jobType,
      @TimestampConverter() DateTime deadline,
      int applicationsCount,
      JobStatus status,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$JobModelImplCopyWithImpl<$Res>
    extends _$JobModelCopyWithImpl<$Res, _$JobModelImpl>
    implements _$$JobModelImplCopyWith<$Res> {
  __$$JobModelImplCopyWithImpl(
      _$JobModelImpl _value, $Res Function(_$JobModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? organizerId = null,
    Object? eventTitle = freezed,
    Object? title = null,
    Object? description = null,
    Object? requirements = null,
    Object? salary = freezed,
    Object? location = freezed,
    Object? jobType = freezed,
    Object? deadline = null,
    Object? applicationsCount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$JobModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      eventTitle: freezed == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      requirements: null == requirements
          ? _value._requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      salary: freezed == salary
          ? _value.salary
          : salary // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      jobType: freezed == jobType
          ? _value.jobType
          : jobType // ignore: cast_nullable_to_non_nullable
              as String?,
      deadline: null == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime,
      applicationsCount: null == applicationsCount
          ? _value.applicationsCount
          : applicationsCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as JobStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JobModelImpl extends _JobModel {
  const _$JobModelImpl(
      {required this.id,
      required this.eventId,
      required this.organizerId,
      this.eventTitle,
      required this.title,
      required this.description,
      final List<String> requirements = const [],
      this.salary,
      this.location,
      this.jobType,
      @TimestampConverter() required this.deadline,
      this.applicationsCount = 0,
      this.status = JobStatus.open,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() this.updatedAt})
      : _requirements = requirements,
        super._();

  factory _$JobModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobModelImplFromJson(json);

  @override
  final String id;
  @override
  final String eventId;
  @override
  final String organizerId;
  @override
  final String? eventTitle;
  @override
  final String title;
  @override
  final String description;
  final List<String> _requirements;
  @override
  @JsonKey()
  List<String> get requirements {
    if (_requirements is EqualUnmodifiableListView) return _requirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requirements);
  }

  @override
  final String? salary;
  @override
  final String? location;
  @override
  final String? jobType;
// Full-time, Part-time, Contract
  @override
  @TimestampConverter()
  final DateTime deadline;
  @override
  @JsonKey()
  final int applicationsCount;
  @override
  @JsonKey()
  final JobStatus status;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'JobModel(id: $id, eventId: $eventId, organizerId: $organizerId, eventTitle: $eventTitle, title: $title, description: $description, requirements: $requirements, salary: $salary, location: $location, jobType: $jobType, deadline: $deadline, applicationsCount: $applicationsCount, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.organizerId, organizerId) ||
                other.organizerId == organizerId) &&
            (identical(other.eventTitle, eventTitle) ||
                other.eventTitle == eventTitle) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._requirements, _requirements) &&
            (identical(other.salary, salary) || other.salary == salary) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.jobType, jobType) || other.jobType == jobType) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.applicationsCount, applicationsCount) ||
                other.applicationsCount == applicationsCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      eventId,
      organizerId,
      eventTitle,
      title,
      description,
      const DeepCollectionEquality().hash(_requirements),
      salary,
      location,
      jobType,
      deadline,
      applicationsCount,
      status,
      createdAt,
      updatedAt);

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobModelImplCopyWith<_$JobModelImpl> get copyWith =>
      __$$JobModelImplCopyWithImpl<_$JobModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobModelImplToJson(
      this,
    );
  }
}

abstract class _JobModel extends JobModel {
  const factory _JobModel(
      {required final String id,
      required final String eventId,
      required final String organizerId,
      final String? eventTitle,
      required final String title,
      required final String description,
      final List<String> requirements,
      final String? salary,
      final String? location,
      final String? jobType,
      @TimestampConverter() required final DateTime deadline,
      final int applicationsCount,
      final JobStatus status,
      @TimestampConverter() required final DateTime createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$JobModelImpl;
  const _JobModel._() : super._();

  factory _JobModel.fromJson(Map<String, dynamic> json) =
      _$JobModelImpl.fromJson;

  @override
  String get id;
  @override
  String get eventId;
  @override
  String get organizerId;
  @override
  String? get eventTitle;
  @override
  String get title;
  @override
  String get description;
  @override
  List<String> get requirements;
  @override
  String? get salary;
  @override
  String? get location;
  @override
  String? get jobType; // Full-time, Part-time, Contract
  @override
  @TimestampConverter()
  DateTime get deadline;
  @override
  int get applicationsCount;
  @override
  JobStatus get status;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobModelImplCopyWith<_$JobModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JobApplication _$JobApplicationFromJson(Map<String, dynamic> json) {
  return _JobApplication.fromJson(json);
}

/// @nodoc
mixin _$JobApplication {
  String get id => throw _privateConstructorUsedError;
  String get jobId => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;
  String? get userPhone => throw _privateConstructorUsedError;
  String? get userEmail => throw _privateConstructorUsedError;
  String? get coverLetter => throw _privateConstructorUsedError;
  String? get resumeUrl => throw _privateConstructorUsedError;
  ApplicationStatus get status => throw _privateConstructorUsedError;
  String? get feedback => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get reviewedAt => throw _privateConstructorUsedError;

  /// Serializes this JobApplication to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobApplicationCopyWith<JobApplication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobApplicationCopyWith<$Res> {
  factory $JobApplicationCopyWith(
          JobApplication value, $Res Function(JobApplication) then) =
      _$JobApplicationCopyWithImpl<$Res, JobApplication>;
  @useResult
  $Res call(
      {String id,
      String jobId,
      String eventId,
      String userId,
      String? userName,
      String? userPhone,
      String? userEmail,
      String? coverLetter,
      String? resumeUrl,
      ApplicationStatus status,
      String? feedback,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt,
      @NullableTimestampConverter() DateTime? reviewedAt});
}

/// @nodoc
class _$JobApplicationCopyWithImpl<$Res, $Val extends JobApplication>
    implements $JobApplicationCopyWith<$Res> {
  _$JobApplicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? eventId = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? userPhone = freezed,
    Object? userEmail = freezed,
    Object? coverLetter = freezed,
    Object? resumeUrl = freezed,
    Object? status = null,
    Object? feedback = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? reviewedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userPhone: freezed == userPhone
          ? _value.userPhone
          : userPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      userEmail: freezed == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      coverLetter: freezed == coverLetter
          ? _value.coverLetter
          : coverLetter // ignore: cast_nullable_to_non_nullable
              as String?,
      resumeUrl: freezed == resumeUrl
          ? _value.resumeUrl
          : resumeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ApplicationStatus,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobApplicationImplCopyWith<$Res>
    implements $JobApplicationCopyWith<$Res> {
  factory _$$JobApplicationImplCopyWith(_$JobApplicationImpl value,
          $Res Function(_$JobApplicationImpl) then) =
      __$$JobApplicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String jobId,
      String eventId,
      String userId,
      String? userName,
      String? userPhone,
      String? userEmail,
      String? coverLetter,
      String? resumeUrl,
      ApplicationStatus status,
      String? feedback,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt,
      @NullableTimestampConverter() DateTime? reviewedAt});
}

/// @nodoc
class __$$JobApplicationImplCopyWithImpl<$Res>
    extends _$JobApplicationCopyWithImpl<$Res, _$JobApplicationImpl>
    implements _$$JobApplicationImplCopyWith<$Res> {
  __$$JobApplicationImplCopyWithImpl(
      _$JobApplicationImpl _value, $Res Function(_$JobApplicationImpl) _then)
      : super(_value, _then);

  /// Create a copy of JobApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? eventId = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? userPhone = freezed,
    Object? userEmail = freezed,
    Object? coverLetter = freezed,
    Object? resumeUrl = freezed,
    Object? status = null,
    Object? feedback = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? reviewedAt = freezed,
  }) {
    return _then(_$JobApplicationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userPhone: freezed == userPhone
          ? _value.userPhone
          : userPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      userEmail: freezed == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      coverLetter: freezed == coverLetter
          ? _value.coverLetter
          : coverLetter // ignore: cast_nullable_to_non_nullable
              as String?,
      resumeUrl: freezed == resumeUrl
          ? _value.resumeUrl
          : resumeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ApplicationStatus,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JobApplicationImpl extends _JobApplication {
  const _$JobApplicationImpl(
      {required this.id,
      required this.jobId,
      required this.eventId,
      required this.userId,
      this.userName,
      this.userPhone,
      this.userEmail,
      this.coverLetter,
      this.resumeUrl,
      this.status = ApplicationStatus.pending,
      this.feedback,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() this.updatedAt,
      @NullableTimestampConverter() this.reviewedAt})
      : super._();

  factory _$JobApplicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobApplicationImplFromJson(json);

  @override
  final String id;
  @override
  final String jobId;
  @override
  final String eventId;
  @override
  final String userId;
  @override
  final String? userName;
  @override
  final String? userPhone;
  @override
  final String? userEmail;
  @override
  final String? coverLetter;
  @override
  final String? resumeUrl;
  @override
  @JsonKey()
  final ApplicationStatus status;
  @override
  final String? feedback;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? reviewedAt;

  @override
  String toString() {
    return 'JobApplication(id: $id, jobId: $jobId, eventId: $eventId, userId: $userId, userName: $userName, userPhone: $userPhone, userEmail: $userEmail, coverLetter: $coverLetter, resumeUrl: $resumeUrl, status: $status, feedback: $feedback, createdAt: $createdAt, updatedAt: $updatedAt, reviewedAt: $reviewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobApplicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userPhone, userPhone) ||
                other.userPhone == userPhone) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.coverLetter, coverLetter) ||
                other.coverLetter == coverLetter) &&
            (identical(other.resumeUrl, resumeUrl) ||
                other.resumeUrl == resumeUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      jobId,
      eventId,
      userId,
      userName,
      userPhone,
      userEmail,
      coverLetter,
      resumeUrl,
      status,
      feedback,
      createdAt,
      updatedAt,
      reviewedAt);

  /// Create a copy of JobApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobApplicationImplCopyWith<_$JobApplicationImpl> get copyWith =>
      __$$JobApplicationImplCopyWithImpl<_$JobApplicationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobApplicationImplToJson(
      this,
    );
  }
}

abstract class _JobApplication extends JobApplication {
  const factory _JobApplication(
          {required final String id,
          required final String jobId,
          required final String eventId,
          required final String userId,
          final String? userName,
          final String? userPhone,
          final String? userEmail,
          final String? coverLetter,
          final String? resumeUrl,
          final ApplicationStatus status,
          final String? feedback,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() final DateTime? updatedAt,
          @NullableTimestampConverter() final DateTime? reviewedAt}) =
      _$JobApplicationImpl;
  const _JobApplication._() : super._();

  factory _JobApplication.fromJson(Map<String, dynamic> json) =
      _$JobApplicationImpl.fromJson;

  @override
  String get id;
  @override
  String get jobId;
  @override
  String get eventId;
  @override
  String get userId;
  @override
  String? get userName;
  @override
  String? get userPhone;
  @override
  String? get userEmail;
  @override
  String? get coverLetter;
  @override
  String? get resumeUrl;
  @override
  ApplicationStatus get status;
  @override
  String? get feedback;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get reviewedAt;

  /// Create a copy of JobApplication
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobApplicationImplCopyWith<_$JobApplicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$JobFilter {
  String? get searchQuery => throw _privateConstructorUsedError;
  String? get eventId => throw _privateConstructorUsedError;
  String? get jobType => throw _privateConstructorUsedError;
  bool get showClosedJobs => throw _privateConstructorUsedError;
  JobSortBy get sortBy => throw _privateConstructorUsedError;
  bool get ascending => throw _privateConstructorUsedError;

  /// Create a copy of JobFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobFilterCopyWith<JobFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobFilterCopyWith<$Res> {
  factory $JobFilterCopyWith(JobFilter value, $Res Function(JobFilter) then) =
      _$JobFilterCopyWithImpl<$Res, JobFilter>;
  @useResult
  $Res call(
      {String? searchQuery,
      String? eventId,
      String? jobType,
      bool showClosedJobs,
      JobSortBy sortBy,
      bool ascending});
}

/// @nodoc
class _$JobFilterCopyWithImpl<$Res, $Val extends JobFilter>
    implements $JobFilterCopyWith<$Res> {
  _$JobFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = freezed,
    Object? eventId = freezed,
    Object? jobType = freezed,
    Object? showClosedJobs = null,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_value.copyWith(
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      jobType: freezed == jobType
          ? _value.jobType
          : jobType // ignore: cast_nullable_to_non_nullable
              as String?,
      showClosedJobs: null == showClosedJobs
          ? _value.showClosedJobs
          : showClosedJobs // ignore: cast_nullable_to_non_nullable
              as bool,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as JobSortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobFilterImplCopyWith<$Res>
    implements $JobFilterCopyWith<$Res> {
  factory _$$JobFilterImplCopyWith(
          _$JobFilterImpl value, $Res Function(_$JobFilterImpl) then) =
      __$$JobFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? searchQuery,
      String? eventId,
      String? jobType,
      bool showClosedJobs,
      JobSortBy sortBy,
      bool ascending});
}

/// @nodoc
class __$$JobFilterImplCopyWithImpl<$Res>
    extends _$JobFilterCopyWithImpl<$Res, _$JobFilterImpl>
    implements _$$JobFilterImplCopyWith<$Res> {
  __$$JobFilterImplCopyWithImpl(
      _$JobFilterImpl _value, $Res Function(_$JobFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of JobFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = freezed,
    Object? eventId = freezed,
    Object? jobType = freezed,
    Object? showClosedJobs = null,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_$JobFilterImpl(
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      jobType: freezed == jobType
          ? _value.jobType
          : jobType // ignore: cast_nullable_to_non_nullable
              as String?,
      showClosedJobs: null == showClosedJobs
          ? _value.showClosedJobs
          : showClosedJobs // ignore: cast_nullable_to_non_nullable
              as bool,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as JobSortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$JobFilterImpl extends _JobFilter {
  const _$JobFilterImpl(
      {this.searchQuery,
      this.eventId,
      this.jobType,
      this.showClosedJobs = false,
      this.sortBy = JobSortBy.deadline,
      this.ascending = true})
      : super._();

  @override
  final String? searchQuery;
  @override
  final String? eventId;
  @override
  final String? jobType;
  @override
  @JsonKey()
  final bool showClosedJobs;
  @override
  @JsonKey()
  final JobSortBy sortBy;
  @override
  @JsonKey()
  final bool ascending;

  @override
  String toString() {
    return 'JobFilter(searchQuery: $searchQuery, eventId: $eventId, jobType: $jobType, showClosedJobs: $showClosedJobs, sortBy: $sortBy, ascending: $ascending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobFilterImpl &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.jobType, jobType) || other.jobType == jobType) &&
            (identical(other.showClosedJobs, showClosedJobs) ||
                other.showClosedJobs == showClosedJobs) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.ascending, ascending) ||
                other.ascending == ascending));
  }

  @override
  int get hashCode => Object.hash(runtimeType, searchQuery, eventId, jobType,
      showClosedJobs, sortBy, ascending);

  /// Create a copy of JobFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobFilterImplCopyWith<_$JobFilterImpl> get copyWith =>
      __$$JobFilterImplCopyWithImpl<_$JobFilterImpl>(this, _$identity);
}

abstract class _JobFilter extends JobFilter {
  const factory _JobFilter(
      {final String? searchQuery,
      final String? eventId,
      final String? jobType,
      final bool showClosedJobs,
      final JobSortBy sortBy,
      final bool ascending}) = _$JobFilterImpl;
  const _JobFilter._() : super._();

  @override
  String? get searchQuery;
  @override
  String? get eventId;
  @override
  String? get jobType;
  @override
  bool get showClosedJobs;
  @override
  JobSortBy get sortBy;
  @override
  bool get ascending;

  /// Create a copy of JobFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobFilterImplCopyWith<_$JobFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
