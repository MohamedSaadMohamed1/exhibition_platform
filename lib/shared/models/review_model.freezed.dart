// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) {
  return _ReviewModel.fromJson(json);
}

/// @nodoc
mixin _$ReviewModel {
  String get id => throw _privateConstructorUsedError;
  String get reviewerId => throw _privateConstructorUsedError;
  String? get reviewerName => throw _privateConstructorUsedError;
  String? get reviewerImage => throw _privateConstructorUsedError;
  ReviewType get type => throw _privateConstructorUsedError;
  String get targetId =>
      throw _privateConstructorUsedError; // eventId, supplierId, or serviceId
  String? get targetName => throw _privateConstructorUsedError;
  String? get orderId =>
      throw _privateConstructorUsedError; // For service reviews, link to order
  double get rating => throw _privateConstructorUsedError; // 1-5
  String? get title => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  int get helpfulCount => throw _privateConstructorUsedError;
  List<String> get helpfulBy =>
      throw _privateConstructorUsedError; // User IDs who found this helpful
  String? get supplierResponse => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get supplierResponseAt => throw _privateConstructorUsedError;
  bool get isVerified =>
      throw _privateConstructorUsedError; // Verified purchase/attendance
  bool get isVisible => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ReviewModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewModelCopyWith<ReviewModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewModelCopyWith<$Res> {
  factory $ReviewModelCopyWith(
          ReviewModel value, $Res Function(ReviewModel) then) =
      _$ReviewModelCopyWithImpl<$Res, ReviewModel>;
  @useResult
  $Res call(
      {String id,
      String reviewerId,
      String? reviewerName,
      String? reviewerImage,
      ReviewType type,
      String targetId,
      String? targetName,
      String? orderId,
      double rating,
      String? title,
      String? comment,
      List<String> images,
      int helpfulCount,
      List<String> helpfulBy,
      String? supplierResponse,
      @NullableTimestampConverter() DateTime? supplierResponseAt,
      bool isVerified,
      bool isVisible,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$ReviewModelCopyWithImpl<$Res, $Val extends ReviewModel>
    implements $ReviewModelCopyWith<$Res> {
  _$ReviewModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reviewerId = null,
    Object? reviewerName = freezed,
    Object? reviewerImage = freezed,
    Object? type = null,
    Object? targetId = null,
    Object? targetName = freezed,
    Object? orderId = freezed,
    Object? rating = null,
    Object? title = freezed,
    Object? comment = freezed,
    Object? images = null,
    Object? helpfulCount = null,
    Object? helpfulBy = null,
    Object? supplierResponse = freezed,
    Object? supplierResponseAt = freezed,
    Object? isVerified = null,
    Object? isVisible = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reviewerId: null == reviewerId
          ? _value.reviewerId
          : reviewerId // ignore: cast_nullable_to_non_nullable
              as String,
      reviewerName: freezed == reviewerName
          ? _value.reviewerName
          : reviewerName // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewerImage: freezed == reviewerImage
          ? _value.reviewerImage
          : reviewerImage // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReviewType,
      targetId: null == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      targetName: freezed == targetName
          ? _value.targetName
          : targetName // ignore: cast_nullable_to_non_nullable
              as String?,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      helpfulBy: null == helpfulBy
          ? _value.helpfulBy
          : helpfulBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      supplierResponse: freezed == supplierResponse
          ? _value.supplierResponse
          : supplierResponse // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierResponseAt: freezed == supplierResponseAt
          ? _value.supplierResponseAt
          : supplierResponseAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$ReviewModelImplCopyWith<$Res>
    implements $ReviewModelCopyWith<$Res> {
  factory _$$ReviewModelImplCopyWith(
          _$ReviewModelImpl value, $Res Function(_$ReviewModelImpl) then) =
      __$$ReviewModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String reviewerId,
      String? reviewerName,
      String? reviewerImage,
      ReviewType type,
      String targetId,
      String? targetName,
      String? orderId,
      double rating,
      String? title,
      String? comment,
      List<String> images,
      int helpfulCount,
      List<String> helpfulBy,
      String? supplierResponse,
      @NullableTimestampConverter() DateTime? supplierResponseAt,
      bool isVerified,
      bool isVisible,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$ReviewModelImplCopyWithImpl<$Res>
    extends _$ReviewModelCopyWithImpl<$Res, _$ReviewModelImpl>
    implements _$$ReviewModelImplCopyWith<$Res> {
  __$$ReviewModelImplCopyWithImpl(
      _$ReviewModelImpl _value, $Res Function(_$ReviewModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reviewerId = null,
    Object? reviewerName = freezed,
    Object? reviewerImage = freezed,
    Object? type = null,
    Object? targetId = null,
    Object? targetName = freezed,
    Object? orderId = freezed,
    Object? rating = null,
    Object? title = freezed,
    Object? comment = freezed,
    Object? images = null,
    Object? helpfulCount = null,
    Object? helpfulBy = null,
    Object? supplierResponse = freezed,
    Object? supplierResponseAt = freezed,
    Object? isVerified = null,
    Object? isVisible = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ReviewModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reviewerId: null == reviewerId
          ? _value.reviewerId
          : reviewerId // ignore: cast_nullable_to_non_nullable
              as String,
      reviewerName: freezed == reviewerName
          ? _value.reviewerName
          : reviewerName // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewerImage: freezed == reviewerImage
          ? _value.reviewerImage
          : reviewerImage // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReviewType,
      targetId: null == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      targetName: freezed == targetName
          ? _value.targetName
          : targetName // ignore: cast_nullable_to_non_nullable
              as String?,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      helpfulBy: null == helpfulBy
          ? _value._helpfulBy
          : helpfulBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      supplierResponse: freezed == supplierResponse
          ? _value.supplierResponse
          : supplierResponse // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierResponseAt: freezed == supplierResponseAt
          ? _value.supplierResponseAt
          : supplierResponseAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$ReviewModelImpl extends _ReviewModel {
  const _$ReviewModelImpl(
      {required this.id,
      required this.reviewerId,
      this.reviewerName,
      this.reviewerImage,
      required this.type,
      required this.targetId,
      this.targetName,
      this.orderId,
      required this.rating,
      this.title,
      this.comment,
      final List<String> images = const [],
      this.helpfulCount = 0,
      final List<String> helpfulBy = const [],
      this.supplierResponse,
      @NullableTimestampConverter() this.supplierResponseAt,
      this.isVerified = false,
      this.isVisible = true,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() this.updatedAt})
      : _images = images,
        _helpfulBy = helpfulBy,
        super._();

  factory _$ReviewModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewModelImplFromJson(json);

  @override
  final String id;
  @override
  final String reviewerId;
  @override
  final String? reviewerName;
  @override
  final String? reviewerImage;
  @override
  final ReviewType type;
  @override
  final String targetId;
// eventId, supplierId, or serviceId
  @override
  final String? targetName;
  @override
  final String? orderId;
// For service reviews, link to order
  @override
  final double rating;
// 1-5
  @override
  final String? title;
  @override
  final String? comment;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey()
  final int helpfulCount;
  final List<String> _helpfulBy;
  @override
  @JsonKey()
  List<String> get helpfulBy {
    if (_helpfulBy is EqualUnmodifiableListView) return _helpfulBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_helpfulBy);
  }

// User IDs who found this helpful
  @override
  final String? supplierResponse;
  @override
  @NullableTimestampConverter()
  final DateTime? supplierResponseAt;
  @override
  @JsonKey()
  final bool isVerified;
// Verified purchase/attendance
  @override
  @JsonKey()
  final bool isVisible;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ReviewModel(id: $id, reviewerId: $reviewerId, reviewerName: $reviewerName, reviewerImage: $reviewerImage, type: $type, targetId: $targetId, targetName: $targetName, orderId: $orderId, rating: $rating, title: $title, comment: $comment, images: $images, helpfulCount: $helpfulCount, helpfulBy: $helpfulBy, supplierResponse: $supplierResponse, supplierResponseAt: $supplierResponseAt, isVerified: $isVerified, isVisible: $isVisible, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reviewerId, reviewerId) ||
                other.reviewerId == reviewerId) &&
            (identical(other.reviewerName, reviewerName) ||
                other.reviewerName == reviewerName) &&
            (identical(other.reviewerImage, reviewerImage) ||
                other.reviewerImage == reviewerImage) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetName, targetName) ||
                other.targetName == targetName) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.helpfulCount, helpfulCount) ||
                other.helpfulCount == helpfulCount) &&
            const DeepCollectionEquality()
                .equals(other._helpfulBy, _helpfulBy) &&
            (identical(other.supplierResponse, supplierResponse) ||
                other.supplierResponse == supplierResponse) &&
            (identical(other.supplierResponseAt, supplierResponseAt) ||
                other.supplierResponseAt == supplierResponseAt) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        reviewerId,
        reviewerName,
        reviewerImage,
        type,
        targetId,
        targetName,
        orderId,
        rating,
        title,
        comment,
        const DeepCollectionEquality().hash(_images),
        helpfulCount,
        const DeepCollectionEquality().hash(_helpfulBy),
        supplierResponse,
        supplierResponseAt,
        isVerified,
        isVisible,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewModelImplCopyWith<_$ReviewModelImpl> get copyWith =>
      __$$ReviewModelImplCopyWithImpl<_$ReviewModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewModelImplToJson(
      this,
    );
  }
}

abstract class _ReviewModel extends ReviewModel {
  const factory _ReviewModel(
      {required final String id,
      required final String reviewerId,
      final String? reviewerName,
      final String? reviewerImage,
      required final ReviewType type,
      required final String targetId,
      final String? targetName,
      final String? orderId,
      required final double rating,
      final String? title,
      final String? comment,
      final List<String> images,
      final int helpfulCount,
      final List<String> helpfulBy,
      final String? supplierResponse,
      @NullableTimestampConverter() final DateTime? supplierResponseAt,
      final bool isVerified,
      final bool isVisible,
      @TimestampConverter() required final DateTime createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$ReviewModelImpl;
  const _ReviewModel._() : super._();

  factory _ReviewModel.fromJson(Map<String, dynamic> json) =
      _$ReviewModelImpl.fromJson;

  @override
  String get id;
  @override
  String get reviewerId;
  @override
  String? get reviewerName;
  @override
  String? get reviewerImage;
  @override
  ReviewType get type;
  @override
  String get targetId; // eventId, supplierId, or serviceId
  @override
  String? get targetName;
  @override
  String? get orderId; // For service reviews, link to order
  @override
  double get rating; // 1-5
  @override
  String? get title;
  @override
  String? get comment;
  @override
  List<String> get images;
  @override
  int get helpfulCount;
  @override
  List<String> get helpfulBy; // User IDs who found this helpful
  @override
  String? get supplierResponse;
  @override
  @NullableTimestampConverter()
  DateTime? get supplierResponseAt;
  @override
  bool get isVerified; // Verified purchase/attendance
  @override
  bool get isVisible;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewModelImplCopyWith<_$ReviewModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReviewFilter {
  ReviewType? get type => throw _privateConstructorUsedError;
  String? get targetId => throw _privateConstructorUsedError;
  String? get reviewerId => throw _privateConstructorUsedError;
  double? get minRating => throw _privateConstructorUsedError;
  bool get verifiedOnly => throw _privateConstructorUsedError;
  ReviewSortBy get sortBy => throw _privateConstructorUsedError;
  bool get ascending => throw _privateConstructorUsedError;

  /// Create a copy of ReviewFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewFilterCopyWith<ReviewFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewFilterCopyWith<$Res> {
  factory $ReviewFilterCopyWith(
          ReviewFilter value, $Res Function(ReviewFilter) then) =
      _$ReviewFilterCopyWithImpl<$Res, ReviewFilter>;
  @useResult
  $Res call(
      {ReviewType? type,
      String? targetId,
      String? reviewerId,
      double? minRating,
      bool verifiedOnly,
      ReviewSortBy sortBy,
      bool ascending});
}

/// @nodoc
class _$ReviewFilterCopyWithImpl<$Res, $Val extends ReviewFilter>
    implements $ReviewFilterCopyWith<$Res> {
  _$ReviewFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? targetId = freezed,
    Object? reviewerId = freezed,
    Object? minRating = freezed,
    Object? verifiedOnly = null,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_value.copyWith(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReviewType?,
      targetId: freezed == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewerId: freezed == reviewerId
          ? _value.reviewerId
          : reviewerId // ignore: cast_nullable_to_non_nullable
              as String?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      verifiedOnly: null == verifiedOnly
          ? _value.verifiedOnly
          : verifiedOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as ReviewSortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewFilterImplCopyWith<$Res>
    implements $ReviewFilterCopyWith<$Res> {
  factory _$$ReviewFilterImplCopyWith(
          _$ReviewFilterImpl value, $Res Function(_$ReviewFilterImpl) then) =
      __$$ReviewFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ReviewType? type,
      String? targetId,
      String? reviewerId,
      double? minRating,
      bool verifiedOnly,
      ReviewSortBy sortBy,
      bool ascending});
}

/// @nodoc
class __$$ReviewFilterImplCopyWithImpl<$Res>
    extends _$ReviewFilterCopyWithImpl<$Res, _$ReviewFilterImpl>
    implements _$$ReviewFilterImplCopyWith<$Res> {
  __$$ReviewFilterImplCopyWithImpl(
      _$ReviewFilterImpl _value, $Res Function(_$ReviewFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? targetId = freezed,
    Object? reviewerId = freezed,
    Object? minRating = freezed,
    Object? verifiedOnly = null,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_$ReviewFilterImpl(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReviewType?,
      targetId: freezed == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewerId: freezed == reviewerId
          ? _value.reviewerId
          : reviewerId // ignore: cast_nullable_to_non_nullable
              as String?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      verifiedOnly: null == verifiedOnly
          ? _value.verifiedOnly
          : verifiedOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as ReviewSortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ReviewFilterImpl extends _ReviewFilter {
  const _$ReviewFilterImpl(
      {this.type,
      this.targetId,
      this.reviewerId,
      this.minRating,
      this.verifiedOnly = false,
      this.sortBy = ReviewSortBy.createdAt,
      this.ascending = false})
      : super._();

  @override
  final ReviewType? type;
  @override
  final String? targetId;
  @override
  final String? reviewerId;
  @override
  final double? minRating;
  @override
  @JsonKey()
  final bool verifiedOnly;
  @override
  @JsonKey()
  final ReviewSortBy sortBy;
  @override
  @JsonKey()
  final bool ascending;

  @override
  String toString() {
    return 'ReviewFilter(type: $type, targetId: $targetId, reviewerId: $reviewerId, minRating: $minRating, verifiedOnly: $verifiedOnly, sortBy: $sortBy, ascending: $ascending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewFilterImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.reviewerId, reviewerId) ||
                other.reviewerId == reviewerId) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            (identical(other.verifiedOnly, verifiedOnly) ||
                other.verifiedOnly == verifiedOnly) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.ascending, ascending) ||
                other.ascending == ascending));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, targetId, reviewerId,
      minRating, verifiedOnly, sortBy, ascending);

  /// Create a copy of ReviewFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewFilterImplCopyWith<_$ReviewFilterImpl> get copyWith =>
      __$$ReviewFilterImplCopyWithImpl<_$ReviewFilterImpl>(this, _$identity);
}

abstract class _ReviewFilter extends ReviewFilter {
  const factory _ReviewFilter(
      {final ReviewType? type,
      final String? targetId,
      final String? reviewerId,
      final double? minRating,
      final bool verifiedOnly,
      final ReviewSortBy sortBy,
      final bool ascending}) = _$ReviewFilterImpl;
  const _ReviewFilter._() : super._();

  @override
  ReviewType? get type;
  @override
  String? get targetId;
  @override
  String? get reviewerId;
  @override
  double? get minRating;
  @override
  bool get verifiedOnly;
  @override
  ReviewSortBy get sortBy;
  @override
  bool get ascending;

  /// Create a copy of ReviewFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewFilterImplCopyWith<_$ReviewFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewStats _$ReviewStatsFromJson(Map<String, dynamic> json) {
  return _ReviewStats.fromJson(json);
}

/// @nodoc
mixin _$ReviewStats {
  int get totalReviews => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError;
  int get fiveStarCount => throw _privateConstructorUsedError;
  int get fourStarCount => throw _privateConstructorUsedError;
  int get threeStarCount => throw _privateConstructorUsedError;
  int get twoStarCount => throw _privateConstructorUsedError;
  int get oneStarCount => throw _privateConstructorUsedError;

  /// Serializes this ReviewStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewStatsCopyWith<ReviewStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewStatsCopyWith<$Res> {
  factory $ReviewStatsCopyWith(
          ReviewStats value, $Res Function(ReviewStats) then) =
      _$ReviewStatsCopyWithImpl<$Res, ReviewStats>;
  @useResult
  $Res call(
      {int totalReviews,
      double averageRating,
      int fiveStarCount,
      int fourStarCount,
      int threeStarCount,
      int twoStarCount,
      int oneStarCount});
}

/// @nodoc
class _$ReviewStatsCopyWithImpl<$Res, $Val extends ReviewStats>
    implements $ReviewStatsCopyWith<$Res> {
  _$ReviewStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReviews = null,
    Object? averageRating = null,
    Object? fiveStarCount = null,
    Object? fourStarCount = null,
    Object? threeStarCount = null,
    Object? twoStarCount = null,
    Object? oneStarCount = null,
  }) {
    return _then(_value.copyWith(
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      fiveStarCount: null == fiveStarCount
          ? _value.fiveStarCount
          : fiveStarCount // ignore: cast_nullable_to_non_nullable
              as int,
      fourStarCount: null == fourStarCount
          ? _value.fourStarCount
          : fourStarCount // ignore: cast_nullable_to_non_nullable
              as int,
      threeStarCount: null == threeStarCount
          ? _value.threeStarCount
          : threeStarCount // ignore: cast_nullable_to_non_nullable
              as int,
      twoStarCount: null == twoStarCount
          ? _value.twoStarCount
          : twoStarCount // ignore: cast_nullable_to_non_nullable
              as int,
      oneStarCount: null == oneStarCount
          ? _value.oneStarCount
          : oneStarCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewStatsImplCopyWith<$Res>
    implements $ReviewStatsCopyWith<$Res> {
  factory _$$ReviewStatsImplCopyWith(
          _$ReviewStatsImpl value, $Res Function(_$ReviewStatsImpl) then) =
      __$$ReviewStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalReviews,
      double averageRating,
      int fiveStarCount,
      int fourStarCount,
      int threeStarCount,
      int twoStarCount,
      int oneStarCount});
}

/// @nodoc
class __$$ReviewStatsImplCopyWithImpl<$Res>
    extends _$ReviewStatsCopyWithImpl<$Res, _$ReviewStatsImpl>
    implements _$$ReviewStatsImplCopyWith<$Res> {
  __$$ReviewStatsImplCopyWithImpl(
      _$ReviewStatsImpl _value, $Res Function(_$ReviewStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReviews = null,
    Object? averageRating = null,
    Object? fiveStarCount = null,
    Object? fourStarCount = null,
    Object? threeStarCount = null,
    Object? twoStarCount = null,
    Object? oneStarCount = null,
  }) {
    return _then(_$ReviewStatsImpl(
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      fiveStarCount: null == fiveStarCount
          ? _value.fiveStarCount
          : fiveStarCount // ignore: cast_nullable_to_non_nullable
              as int,
      fourStarCount: null == fourStarCount
          ? _value.fourStarCount
          : fourStarCount // ignore: cast_nullable_to_non_nullable
              as int,
      threeStarCount: null == threeStarCount
          ? _value.threeStarCount
          : threeStarCount // ignore: cast_nullable_to_non_nullable
              as int,
      twoStarCount: null == twoStarCount
          ? _value.twoStarCount
          : twoStarCount // ignore: cast_nullable_to_non_nullable
              as int,
      oneStarCount: null == oneStarCount
          ? _value.oneStarCount
          : oneStarCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewStatsImpl extends _ReviewStats {
  const _$ReviewStatsImpl(
      {this.totalReviews = 0,
      this.averageRating = 0.0,
      this.fiveStarCount = 0,
      this.fourStarCount = 0,
      this.threeStarCount = 0,
      this.twoStarCount = 0,
      this.oneStarCount = 0})
      : super._();

  factory _$ReviewStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewStatsImplFromJson(json);

  @override
  @JsonKey()
  final int totalReviews;
  @override
  @JsonKey()
  final double averageRating;
  @override
  @JsonKey()
  final int fiveStarCount;
  @override
  @JsonKey()
  final int fourStarCount;
  @override
  @JsonKey()
  final int threeStarCount;
  @override
  @JsonKey()
  final int twoStarCount;
  @override
  @JsonKey()
  final int oneStarCount;

  @override
  String toString() {
    return 'ReviewStats(totalReviews: $totalReviews, averageRating: $averageRating, fiveStarCount: $fiveStarCount, fourStarCount: $fourStarCount, threeStarCount: $threeStarCount, twoStarCount: $twoStarCount, oneStarCount: $oneStarCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewStatsImpl &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.fiveStarCount, fiveStarCount) ||
                other.fiveStarCount == fiveStarCount) &&
            (identical(other.fourStarCount, fourStarCount) ||
                other.fourStarCount == fourStarCount) &&
            (identical(other.threeStarCount, threeStarCount) ||
                other.threeStarCount == threeStarCount) &&
            (identical(other.twoStarCount, twoStarCount) ||
                other.twoStarCount == twoStarCount) &&
            (identical(other.oneStarCount, oneStarCount) ||
                other.oneStarCount == oneStarCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalReviews, averageRating,
      fiveStarCount, fourStarCount, threeStarCount, twoStarCount, oneStarCount);

  /// Create a copy of ReviewStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewStatsImplCopyWith<_$ReviewStatsImpl> get copyWith =>
      __$$ReviewStatsImplCopyWithImpl<_$ReviewStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewStatsImplToJson(
      this,
    );
  }
}

abstract class _ReviewStats extends ReviewStats {
  const factory _ReviewStats(
      {final int totalReviews,
      final double averageRating,
      final int fiveStarCount,
      final int fourStarCount,
      final int threeStarCount,
      final int twoStarCount,
      final int oneStarCount}) = _$ReviewStatsImpl;
  const _ReviewStats._() : super._();

  factory _ReviewStats.fromJson(Map<String, dynamic> json) =
      _$ReviewStatsImpl.fromJson;

  @override
  int get totalReviews;
  @override
  double get averageRating;
  @override
  int get fiveStarCount;
  @override
  int get fourStarCount;
  @override
  int get threeStarCount;
  @override
  int get twoStarCount;
  @override
  int get oneStarCount;

  /// Create a copy of ReviewStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewStatsImplCopyWith<_$ReviewStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
