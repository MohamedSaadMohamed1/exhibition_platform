// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) {
  return _ServiceModel.fromJson(json);
}

/// @nodoc
mixin _$ServiceModel {
  String get id => throw _privateConstructorUsedError;
  String get supplierId => throw _privateConstructorUsedError;
  String? get supplierName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  String? get priceUnit =>
      throw _privateConstructorUsedError; // per hour, per day, per event, fixed
  bool get isActive => throw _privateConstructorUsedError;
  int get ordersCount => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get reviewsCount => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceModelCopyWith<ServiceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceModelCopyWith<$Res> {
  factory $ServiceModelCopyWith(
          ServiceModel value, $Res Function(ServiceModel) then) =
      _$ServiceModelCopyWithImpl<$Res, ServiceModel>;
  @useResult
  $Res call(
      {String id,
      String supplierId,
      String? supplierName,
      String title,
      String description,
      String category,
      List<String> images,
      double? price,
      String? priceUnit,
      bool isActive,
      int ordersCount,
      double rating,
      int reviewsCount,
      List<String> tags,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$ServiceModelCopyWithImpl<$Res, $Val extends ServiceModel>
    implements $ServiceModelCopyWith<$Res> {
  _$ServiceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? supplierId = null,
    Object? supplierName = freezed,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? images = null,
    Object? price = freezed,
    Object? priceUnit = freezed,
    Object? isActive = null,
    Object? ordersCount = null,
    Object? rating = null,
    Object? reviewsCount = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: freezed == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      priceUnit: freezed == priceUnit
          ? _value.priceUnit
          : priceUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      ordersCount: null == ordersCount
          ? _value.ordersCount
          : ordersCount // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewsCount: null == reviewsCount
          ? _value.reviewsCount
          : reviewsCount // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
abstract class _$$ServiceModelImplCopyWith<$Res>
    implements $ServiceModelCopyWith<$Res> {
  factory _$$ServiceModelImplCopyWith(
          _$ServiceModelImpl value, $Res Function(_$ServiceModelImpl) then) =
      __$$ServiceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String supplierId,
      String? supplierName,
      String title,
      String description,
      String category,
      List<String> images,
      double? price,
      String? priceUnit,
      bool isActive,
      int ordersCount,
      double rating,
      int reviewsCount,
      List<String> tags,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$ServiceModelImplCopyWithImpl<$Res>
    extends _$ServiceModelCopyWithImpl<$Res, _$ServiceModelImpl>
    implements _$$ServiceModelImplCopyWith<$Res> {
  __$$ServiceModelImplCopyWithImpl(
      _$ServiceModelImpl _value, $Res Function(_$ServiceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? supplierId = null,
    Object? supplierName = freezed,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? images = null,
    Object? price = freezed,
    Object? priceUnit = freezed,
    Object? isActive = null,
    Object? ordersCount = null,
    Object? rating = null,
    Object? reviewsCount = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ServiceModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: freezed == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      priceUnit: freezed == priceUnit
          ? _value.priceUnit
          : priceUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      ordersCount: null == ordersCount
          ? _value.ordersCount
          : ordersCount // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewsCount: null == reviewsCount
          ? _value.reviewsCount
          : reviewsCount // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
class _$ServiceModelImpl extends _ServiceModel {
  const _$ServiceModelImpl(
      {required this.id,
      required this.supplierId,
      this.supplierName,
      required this.title,
      required this.description,
      required this.category,
      final List<String> images = const [],
      this.price,
      this.priceUnit,
      this.isActive = true,
      this.ordersCount = 0,
      this.rating = 0.0,
      this.reviewsCount = 0,
      final List<String> tags = const [],
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() this.updatedAt})
      : _images = images,
        _tags = tags,
        super._();

  factory _$ServiceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceModelImplFromJson(json);

  @override
  final String id;
  @override
  final String supplierId;
  @override
  final String? supplierName;
  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final double? price;
  @override
  final String? priceUnit;
// per hour, per day, per event, fixed
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int ordersCount;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int reviewsCount;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ServiceModel(id: $id, supplierId: $supplierId, supplierName: $supplierName, title: $title, description: $description, category: $category, images: $images, price: $price, priceUnit: $priceUnit, isActive: $isActive, ordersCount: $ordersCount, rating: $rating, reviewsCount: $reviewsCount, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceUnit, priceUnit) ||
                other.priceUnit == priceUnit) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.ordersCount, ordersCount) ||
                other.ordersCount == ordersCount) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewsCount, reviewsCount) ||
                other.reviewsCount == reviewsCount) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
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
      supplierId,
      supplierName,
      title,
      description,
      category,
      const DeepCollectionEquality().hash(_images),
      price,
      priceUnit,
      isActive,
      ordersCount,
      rating,
      reviewsCount,
      const DeepCollectionEquality().hash(_tags),
      createdAt,
      updatedAt);

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceModelImplCopyWith<_$ServiceModelImpl> get copyWith =>
      __$$ServiceModelImplCopyWithImpl<_$ServiceModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceModelImplToJson(
      this,
    );
  }
}

abstract class _ServiceModel extends ServiceModel {
  const factory _ServiceModel(
      {required final String id,
      required final String supplierId,
      final String? supplierName,
      required final String title,
      required final String description,
      required final String category,
      final List<String> images,
      final double? price,
      final String? priceUnit,
      final bool isActive,
      final int ordersCount,
      final double rating,
      final int reviewsCount,
      final List<String> tags,
      @TimestampConverter() required final DateTime createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$ServiceModelImpl;
  const _ServiceModel._() : super._();

  factory _ServiceModel.fromJson(Map<String, dynamic> json) =
      _$ServiceModelImpl.fromJson;

  @override
  String get id;
  @override
  String get supplierId;
  @override
  String? get supplierName;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  List<String> get images;
  @override
  double? get price;
  @override
  String? get priceUnit; // per hour, per day, per event, fixed
  @override
  bool get isActive;
  @override
  int get ordersCount;
  @override
  double get rating;
  @override
  int get reviewsCount;
  @override
  List<String> get tags;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceModelImplCopyWith<_$ServiceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ServiceFilter {
  String? get searchQuery => throw _privateConstructorUsedError;
  String? get supplierId => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  double? get minPrice => throw _privateConstructorUsedError;
  double? get maxPrice => throw _privateConstructorUsedError;
  double? get minRating => throw _privateConstructorUsedError;
  ServiceSortBy get sortBy => throw _privateConstructorUsedError;
  bool get ascending => throw _privateConstructorUsedError;

  /// Create a copy of ServiceFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceFilterCopyWith<ServiceFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceFilterCopyWith<$Res> {
  factory $ServiceFilterCopyWith(
          ServiceFilter value, $Res Function(ServiceFilter) then) =
      _$ServiceFilterCopyWithImpl<$Res, ServiceFilter>;
  @useResult
  $Res call(
      {String? searchQuery,
      String? supplierId,
      String? category,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      ServiceSortBy sortBy,
      bool ascending});
}

/// @nodoc
class _$ServiceFilterCopyWithImpl<$Res, $Val extends ServiceFilter>
    implements $ServiceFilterCopyWith<$Res> {
  _$ServiceFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = freezed,
    Object? supplierId = freezed,
    Object? category = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_value.copyWith(
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as ServiceSortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceFilterImplCopyWith<$Res>
    implements $ServiceFilterCopyWith<$Res> {
  factory _$$ServiceFilterImplCopyWith(
          _$ServiceFilterImpl value, $Res Function(_$ServiceFilterImpl) then) =
      __$$ServiceFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? searchQuery,
      String? supplierId,
      String? category,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      ServiceSortBy sortBy,
      bool ascending});
}

/// @nodoc
class __$$ServiceFilterImplCopyWithImpl<$Res>
    extends _$ServiceFilterCopyWithImpl<$Res, _$ServiceFilterImpl>
    implements _$$ServiceFilterImplCopyWith<$Res> {
  __$$ServiceFilterImplCopyWithImpl(
      _$ServiceFilterImpl _value, $Res Function(_$ServiceFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = freezed,
    Object? supplierId = freezed,
    Object? category = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_$ServiceFilterImpl(
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as ServiceSortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ServiceFilterImpl extends _ServiceFilter {
  const _$ServiceFilterImpl(
      {this.searchQuery,
      this.supplierId,
      this.category,
      this.minPrice,
      this.maxPrice,
      this.minRating,
      this.sortBy = ServiceSortBy.createdAt,
      this.ascending = false})
      : super._();

  @override
  final String? searchQuery;
  @override
  final String? supplierId;
  @override
  final String? category;
  @override
  final double? minPrice;
  @override
  final double? maxPrice;
  @override
  final double? minRating;
  @override
  @JsonKey()
  final ServiceSortBy sortBy;
  @override
  @JsonKey()
  final bool ascending;

  @override
  String toString() {
    return 'ServiceFilter(searchQuery: $searchQuery, supplierId: $supplierId, category: $category, minPrice: $minPrice, maxPrice: $maxPrice, minRating: $minRating, sortBy: $sortBy, ascending: $ascending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceFilterImpl &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.ascending, ascending) ||
                other.ascending == ascending));
  }

  @override
  int get hashCode => Object.hash(runtimeType, searchQuery, supplierId,
      category, minPrice, maxPrice, minRating, sortBy, ascending);

  /// Create a copy of ServiceFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceFilterImplCopyWith<_$ServiceFilterImpl> get copyWith =>
      __$$ServiceFilterImplCopyWithImpl<_$ServiceFilterImpl>(this, _$identity);
}

abstract class _ServiceFilter extends ServiceFilter {
  const factory _ServiceFilter(
      {final String? searchQuery,
      final String? supplierId,
      final String? category,
      final double? minPrice,
      final double? maxPrice,
      final double? minRating,
      final ServiceSortBy sortBy,
      final bool ascending}) = _$ServiceFilterImpl;
  const _ServiceFilter._() : super._();

  @override
  String? get searchQuery;
  @override
  String? get supplierId;
  @override
  String? get category;
  @override
  double? get minPrice;
  @override
  double? get maxPrice;
  @override
  double? get minRating;
  @override
  ServiceSortBy get sortBy;
  @override
  bool get ascending;

  /// Create a copy of ServiceFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceFilterImplCopyWith<_$ServiceFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
