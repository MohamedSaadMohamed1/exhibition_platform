// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventAnalytics _$EventAnalyticsFromJson(Map<String, dynamic> json) {
  return _EventAnalytics.fromJson(json);
}

/// @nodoc
mixin _$EventAnalytics {
  String get eventId => throw _privateConstructorUsedError;
  String get eventTitle => throw _privateConstructorUsedError;
  int get totalViews => throw _privateConstructorUsedError;
  int get uniqueVisitors => throw _privateConstructorUsedError;
  int get interestedCount => throw _privateConstructorUsedError;
  int get totalBookings => throw _privateConstructorUsedError;
  int get confirmedBookings => throw _privateConstructorUsedError;
  int get pendingBookings => throw _privateConstructorUsedError;
  int get cancelledBookings => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;
  int get totalBooths => throw _privateConstructorUsedError;
  int get bookedBooths => throw _privateConstructorUsedError;
  int get availableBooths => throw _privateConstructorUsedError;
  double get occupancyRate => throw _privateConstructorUsedError;
  List<DailyStats> get dailyStats => throw _privateConstructorUsedError;
  Map<String, int> get boothTypeBreakdown => throw _privateConstructorUsedError;
  Map<String, double> get revenueByBoothType =>
      throw _privateConstructorUsedError;

  /// Serializes this EventAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventAnalyticsCopyWith<EventAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventAnalyticsCopyWith<$Res> {
  factory $EventAnalyticsCopyWith(
          EventAnalytics value, $Res Function(EventAnalytics) then) =
      _$EventAnalyticsCopyWithImpl<$Res, EventAnalytics>;
  @useResult
  $Res call(
      {String eventId,
      String eventTitle,
      int totalViews,
      int uniqueVisitors,
      int interestedCount,
      int totalBookings,
      int confirmedBookings,
      int pendingBookings,
      int cancelledBookings,
      double totalRevenue,
      int totalBooths,
      int bookedBooths,
      int availableBooths,
      double occupancyRate,
      List<DailyStats> dailyStats,
      Map<String, int> boothTypeBreakdown,
      Map<String, double> revenueByBoothType});
}

/// @nodoc
class _$EventAnalyticsCopyWithImpl<$Res, $Val extends EventAnalytics>
    implements $EventAnalyticsCopyWith<$Res> {
  _$EventAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? eventTitle = null,
    Object? totalViews = null,
    Object? uniqueVisitors = null,
    Object? interestedCount = null,
    Object? totalBookings = null,
    Object? confirmedBookings = null,
    Object? pendingBookings = null,
    Object? cancelledBookings = null,
    Object? totalRevenue = null,
    Object? totalBooths = null,
    Object? bookedBooths = null,
    Object? availableBooths = null,
    Object? occupancyRate = null,
    Object? dailyStats = null,
    Object? boothTypeBreakdown = null,
    Object? revenueByBoothType = null,
  }) {
    return _then(_value.copyWith(
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      eventTitle: null == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String,
      totalViews: null == totalViews
          ? _value.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueVisitors: null == uniqueVisitors
          ? _value.uniqueVisitors
          : uniqueVisitors // ignore: cast_nullable_to_non_nullable
              as int,
      interestedCount: null == interestedCount
          ? _value.interestedCount
          : interestedCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      confirmedBookings: null == confirmedBookings
          ? _value.confirmedBookings
          : confirmedBookings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingBookings: null == pendingBookings
          ? _value.pendingBookings
          : pendingBookings // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledBookings: null == cancelledBookings
          ? _value.cancelledBookings
          : cancelledBookings // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      totalBooths: null == totalBooths
          ? _value.totalBooths
          : totalBooths // ignore: cast_nullable_to_non_nullable
              as int,
      bookedBooths: null == bookedBooths
          ? _value.bookedBooths
          : bookedBooths // ignore: cast_nullable_to_non_nullable
              as int,
      availableBooths: null == availableBooths
          ? _value.availableBooths
          : availableBooths // ignore: cast_nullable_to_non_nullable
              as int,
      occupancyRate: null == occupancyRate
          ? _value.occupancyRate
          : occupancyRate // ignore: cast_nullable_to_non_nullable
              as double,
      dailyStats: null == dailyStats
          ? _value.dailyStats
          : dailyStats // ignore: cast_nullable_to_non_nullable
              as List<DailyStats>,
      boothTypeBreakdown: null == boothTypeBreakdown
          ? _value.boothTypeBreakdown
          : boothTypeBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      revenueByBoothType: null == revenueByBoothType
          ? _value.revenueByBoothType
          : revenueByBoothType // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventAnalyticsImplCopyWith<$Res>
    implements $EventAnalyticsCopyWith<$Res> {
  factory _$$EventAnalyticsImplCopyWith(_$EventAnalyticsImpl value,
          $Res Function(_$EventAnalyticsImpl) then) =
      __$$EventAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String eventId,
      String eventTitle,
      int totalViews,
      int uniqueVisitors,
      int interestedCount,
      int totalBookings,
      int confirmedBookings,
      int pendingBookings,
      int cancelledBookings,
      double totalRevenue,
      int totalBooths,
      int bookedBooths,
      int availableBooths,
      double occupancyRate,
      List<DailyStats> dailyStats,
      Map<String, int> boothTypeBreakdown,
      Map<String, double> revenueByBoothType});
}

/// @nodoc
class __$$EventAnalyticsImplCopyWithImpl<$Res>
    extends _$EventAnalyticsCopyWithImpl<$Res, _$EventAnalyticsImpl>
    implements _$$EventAnalyticsImplCopyWith<$Res> {
  __$$EventAnalyticsImplCopyWithImpl(
      _$EventAnalyticsImpl _value, $Res Function(_$EventAnalyticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? eventTitle = null,
    Object? totalViews = null,
    Object? uniqueVisitors = null,
    Object? interestedCount = null,
    Object? totalBookings = null,
    Object? confirmedBookings = null,
    Object? pendingBookings = null,
    Object? cancelledBookings = null,
    Object? totalRevenue = null,
    Object? totalBooths = null,
    Object? bookedBooths = null,
    Object? availableBooths = null,
    Object? occupancyRate = null,
    Object? dailyStats = null,
    Object? boothTypeBreakdown = null,
    Object? revenueByBoothType = null,
  }) {
    return _then(_$EventAnalyticsImpl(
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      eventTitle: null == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String,
      totalViews: null == totalViews
          ? _value.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueVisitors: null == uniqueVisitors
          ? _value.uniqueVisitors
          : uniqueVisitors // ignore: cast_nullable_to_non_nullable
              as int,
      interestedCount: null == interestedCount
          ? _value.interestedCount
          : interestedCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      confirmedBookings: null == confirmedBookings
          ? _value.confirmedBookings
          : confirmedBookings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingBookings: null == pendingBookings
          ? _value.pendingBookings
          : pendingBookings // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledBookings: null == cancelledBookings
          ? _value.cancelledBookings
          : cancelledBookings // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      totalBooths: null == totalBooths
          ? _value.totalBooths
          : totalBooths // ignore: cast_nullable_to_non_nullable
              as int,
      bookedBooths: null == bookedBooths
          ? _value.bookedBooths
          : bookedBooths // ignore: cast_nullable_to_non_nullable
              as int,
      availableBooths: null == availableBooths
          ? _value.availableBooths
          : availableBooths // ignore: cast_nullable_to_non_nullable
              as int,
      occupancyRate: null == occupancyRate
          ? _value.occupancyRate
          : occupancyRate // ignore: cast_nullable_to_non_nullable
              as double,
      dailyStats: null == dailyStats
          ? _value._dailyStats
          : dailyStats // ignore: cast_nullable_to_non_nullable
              as List<DailyStats>,
      boothTypeBreakdown: null == boothTypeBreakdown
          ? _value._boothTypeBreakdown
          : boothTypeBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      revenueByBoothType: null == revenueByBoothType
          ? _value._revenueByBoothType
          : revenueByBoothType // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventAnalyticsImpl implements _EventAnalytics {
  const _$EventAnalyticsImpl(
      {required this.eventId,
      required this.eventTitle,
      this.totalViews = 0,
      this.uniqueVisitors = 0,
      this.interestedCount = 0,
      this.totalBookings = 0,
      this.confirmedBookings = 0,
      this.pendingBookings = 0,
      this.cancelledBookings = 0,
      this.totalRevenue = 0.0,
      this.totalBooths = 0,
      this.bookedBooths = 0,
      this.availableBooths = 0,
      this.occupancyRate = 0.0,
      final List<DailyStats> dailyStats = const [],
      final Map<String, int> boothTypeBreakdown = const {},
      final Map<String, double> revenueByBoothType = const {}})
      : _dailyStats = dailyStats,
        _boothTypeBreakdown = boothTypeBreakdown,
        _revenueByBoothType = revenueByBoothType;

  factory _$EventAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventAnalyticsImplFromJson(json);

  @override
  final String eventId;
  @override
  final String eventTitle;
  @override
  @JsonKey()
  final int totalViews;
  @override
  @JsonKey()
  final int uniqueVisitors;
  @override
  @JsonKey()
  final int interestedCount;
  @override
  @JsonKey()
  final int totalBookings;
  @override
  @JsonKey()
  final int confirmedBookings;
  @override
  @JsonKey()
  final int pendingBookings;
  @override
  @JsonKey()
  final int cancelledBookings;
  @override
  @JsonKey()
  final double totalRevenue;
  @override
  @JsonKey()
  final int totalBooths;
  @override
  @JsonKey()
  final int bookedBooths;
  @override
  @JsonKey()
  final int availableBooths;
  @override
  @JsonKey()
  final double occupancyRate;
  final List<DailyStats> _dailyStats;
  @override
  @JsonKey()
  List<DailyStats> get dailyStats {
    if (_dailyStats is EqualUnmodifiableListView) return _dailyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyStats);
  }

  final Map<String, int> _boothTypeBreakdown;
  @override
  @JsonKey()
  Map<String, int> get boothTypeBreakdown {
    if (_boothTypeBreakdown is EqualUnmodifiableMapView)
      return _boothTypeBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_boothTypeBreakdown);
  }

  final Map<String, double> _revenueByBoothType;
  @override
  @JsonKey()
  Map<String, double> get revenueByBoothType {
    if (_revenueByBoothType is EqualUnmodifiableMapView)
      return _revenueByBoothType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_revenueByBoothType);
  }

  @override
  String toString() {
    return 'EventAnalytics(eventId: $eventId, eventTitle: $eventTitle, totalViews: $totalViews, uniqueVisitors: $uniqueVisitors, interestedCount: $interestedCount, totalBookings: $totalBookings, confirmedBookings: $confirmedBookings, pendingBookings: $pendingBookings, cancelledBookings: $cancelledBookings, totalRevenue: $totalRevenue, totalBooths: $totalBooths, bookedBooths: $bookedBooths, availableBooths: $availableBooths, occupancyRate: $occupancyRate, dailyStats: $dailyStats, boothTypeBreakdown: $boothTypeBreakdown, revenueByBoothType: $revenueByBoothType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventAnalyticsImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.eventTitle, eventTitle) ||
                other.eventTitle == eventTitle) &&
            (identical(other.totalViews, totalViews) ||
                other.totalViews == totalViews) &&
            (identical(other.uniqueVisitors, uniqueVisitors) ||
                other.uniqueVisitors == uniqueVisitors) &&
            (identical(other.interestedCount, interestedCount) ||
                other.interestedCount == interestedCount) &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings) &&
            (identical(other.confirmedBookings, confirmedBookings) ||
                other.confirmedBookings == confirmedBookings) &&
            (identical(other.pendingBookings, pendingBookings) ||
                other.pendingBookings == pendingBookings) &&
            (identical(other.cancelledBookings, cancelledBookings) ||
                other.cancelledBookings == cancelledBookings) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.totalBooths, totalBooths) ||
                other.totalBooths == totalBooths) &&
            (identical(other.bookedBooths, bookedBooths) ||
                other.bookedBooths == bookedBooths) &&
            (identical(other.availableBooths, availableBooths) ||
                other.availableBooths == availableBooths) &&
            (identical(other.occupancyRate, occupancyRate) ||
                other.occupancyRate == occupancyRate) &&
            const DeepCollectionEquality()
                .equals(other._dailyStats, _dailyStats) &&
            const DeepCollectionEquality()
                .equals(other._boothTypeBreakdown, _boothTypeBreakdown) &&
            const DeepCollectionEquality()
                .equals(other._revenueByBoothType, _revenueByBoothType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      eventId,
      eventTitle,
      totalViews,
      uniqueVisitors,
      interestedCount,
      totalBookings,
      confirmedBookings,
      pendingBookings,
      cancelledBookings,
      totalRevenue,
      totalBooths,
      bookedBooths,
      availableBooths,
      occupancyRate,
      const DeepCollectionEquality().hash(_dailyStats),
      const DeepCollectionEquality().hash(_boothTypeBreakdown),
      const DeepCollectionEquality().hash(_revenueByBoothType));

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventAnalyticsImplCopyWith<_$EventAnalyticsImpl> get copyWith =>
      __$$EventAnalyticsImplCopyWithImpl<_$EventAnalyticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventAnalyticsImplToJson(
      this,
    );
  }
}

abstract class _EventAnalytics implements EventAnalytics {
  const factory _EventAnalytics(
      {required final String eventId,
      required final String eventTitle,
      final int totalViews,
      final int uniqueVisitors,
      final int interestedCount,
      final int totalBookings,
      final int confirmedBookings,
      final int pendingBookings,
      final int cancelledBookings,
      final double totalRevenue,
      final int totalBooths,
      final int bookedBooths,
      final int availableBooths,
      final double occupancyRate,
      final List<DailyStats> dailyStats,
      final Map<String, int> boothTypeBreakdown,
      final Map<String, double> revenueByBoothType}) = _$EventAnalyticsImpl;

  factory _EventAnalytics.fromJson(Map<String, dynamic> json) =
      _$EventAnalyticsImpl.fromJson;

  @override
  String get eventId;
  @override
  String get eventTitle;
  @override
  int get totalViews;
  @override
  int get uniqueVisitors;
  @override
  int get interestedCount;
  @override
  int get totalBookings;
  @override
  int get confirmedBookings;
  @override
  int get pendingBookings;
  @override
  int get cancelledBookings;
  @override
  double get totalRevenue;
  @override
  int get totalBooths;
  @override
  int get bookedBooths;
  @override
  int get availableBooths;
  @override
  double get occupancyRate;
  @override
  List<DailyStats> get dailyStats;
  @override
  Map<String, int> get boothTypeBreakdown;
  @override
  Map<String, double> get revenueByBoothType;

  /// Create a copy of EventAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventAnalyticsImplCopyWith<_$EventAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyStats _$DailyStatsFromJson(Map<String, dynamic> json) {
  return _DailyStats.fromJson(json);
}

/// @nodoc
mixin _$DailyStats {
  DateTime get date => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  int get bookings => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;

  /// Serializes this DailyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStatsCopyWith<DailyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStatsCopyWith<$Res> {
  factory $DailyStatsCopyWith(
          DailyStats value, $Res Function(DailyStats) then) =
      _$DailyStatsCopyWithImpl<$Res, DailyStats>;
  @useResult
  $Res call({DateTime date, int views, int bookings, double revenue});
}

/// @nodoc
class _$DailyStatsCopyWithImpl<$Res, $Val extends DailyStats>
    implements $DailyStatsCopyWith<$Res> {
  _$DailyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? views = null,
    Object? bookings = null,
    Object? revenue = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      bookings: null == bookings
          ? _value.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as int,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyStatsImplCopyWith<$Res>
    implements $DailyStatsCopyWith<$Res> {
  factory _$$DailyStatsImplCopyWith(
          _$DailyStatsImpl value, $Res Function(_$DailyStatsImpl) then) =
      __$$DailyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int views, int bookings, double revenue});
}

/// @nodoc
class __$$DailyStatsImplCopyWithImpl<$Res>
    extends _$DailyStatsCopyWithImpl<$Res, _$DailyStatsImpl>
    implements _$$DailyStatsImplCopyWith<$Res> {
  __$$DailyStatsImplCopyWithImpl(
      _$DailyStatsImpl _value, $Res Function(_$DailyStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? views = null,
    Object? bookings = null,
    Object? revenue = null,
  }) {
    return _then(_$DailyStatsImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      bookings: null == bookings
          ? _value.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as int,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStatsImpl implements _DailyStats {
  const _$DailyStatsImpl(
      {required this.date,
      this.views = 0,
      this.bookings = 0,
      this.revenue = 0.0});

  factory _$DailyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStatsImplFromJson(json);

  @override
  final DateTime date;
  @override
  @JsonKey()
  final int views;
  @override
  @JsonKey()
  final int bookings;
  @override
  @JsonKey()
  final double revenue;

  @override
  String toString() {
    return 'DailyStats(date: $date, views: $views, bookings: $bookings, revenue: $revenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStatsImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.bookings, bookings) ||
                other.bookings == bookings) &&
            (identical(other.revenue, revenue) || other.revenue == revenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, views, bookings, revenue);

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStatsImplCopyWith<_$DailyStatsImpl> get copyWith =>
      __$$DailyStatsImplCopyWithImpl<_$DailyStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStatsImplToJson(
      this,
    );
  }
}

abstract class _DailyStats implements DailyStats {
  const factory _DailyStats(
      {required final DateTime date,
      final int views,
      final int bookings,
      final double revenue}) = _$DailyStatsImpl;

  factory _DailyStats.fromJson(Map<String, dynamic> json) =
      _$DailyStatsImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get views;
  @override
  int get bookings;
  @override
  double get revenue;

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStatsImplCopyWith<_$DailyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrganizerAnalytics _$OrganizerAnalyticsFromJson(Map<String, dynamic> json) {
  return _OrganizerAnalytics.fromJson(json);
}

/// @nodoc
mixin _$OrganizerAnalytics {
  String get organizerId => throw _privateConstructorUsedError;
  int get totalEvents => throw _privateConstructorUsedError;
  int get activeEvents => throw _privateConstructorUsedError;
  int get upcomingEvents => throw _privateConstructorUsedError;
  int get pastEvents => throw _privateConstructorUsedError;
  int get totalBookings => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;
  double get averageOccupancyRate => throw _privateConstructorUsedError;
  int get totalInterestedUsers => throw _privateConstructorUsedError;
  List<EventAnalytics> get topEvents => throw _privateConstructorUsedError;
  List<MonthlyStats> get monthlyStats => throw _privateConstructorUsedError;
  Map<String, int> get bookingsByStatus => throw _privateConstructorUsedError;
  Map<String, double> get revenueByEvent => throw _privateConstructorUsedError;

  /// Serializes this OrganizerAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizerAnalyticsCopyWith<OrganizerAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizerAnalyticsCopyWith<$Res> {
  factory $OrganizerAnalyticsCopyWith(
          OrganizerAnalytics value, $Res Function(OrganizerAnalytics) then) =
      _$OrganizerAnalyticsCopyWithImpl<$Res, OrganizerAnalytics>;
  @useResult
  $Res call(
      {String organizerId,
      int totalEvents,
      int activeEvents,
      int upcomingEvents,
      int pastEvents,
      int totalBookings,
      double totalRevenue,
      double averageOccupancyRate,
      int totalInterestedUsers,
      List<EventAnalytics> topEvents,
      List<MonthlyStats> monthlyStats,
      Map<String, int> bookingsByStatus,
      Map<String, double> revenueByEvent});
}

/// @nodoc
class _$OrganizerAnalyticsCopyWithImpl<$Res, $Val extends OrganizerAnalytics>
    implements $OrganizerAnalyticsCopyWith<$Res> {
  _$OrganizerAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizerId = null,
    Object? totalEvents = null,
    Object? activeEvents = null,
    Object? upcomingEvents = null,
    Object? pastEvents = null,
    Object? totalBookings = null,
    Object? totalRevenue = null,
    Object? averageOccupancyRate = null,
    Object? totalInterestedUsers = null,
    Object? topEvents = null,
    Object? monthlyStats = null,
    Object? bookingsByStatus = null,
    Object? revenueByEvent = null,
  }) {
    return _then(_value.copyWith(
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      totalEvents: null == totalEvents
          ? _value.totalEvents
          : totalEvents // ignore: cast_nullable_to_non_nullable
              as int,
      activeEvents: null == activeEvents
          ? _value.activeEvents
          : activeEvents // ignore: cast_nullable_to_non_nullable
              as int,
      upcomingEvents: null == upcomingEvents
          ? _value.upcomingEvents
          : upcomingEvents // ignore: cast_nullable_to_non_nullable
              as int,
      pastEvents: null == pastEvents
          ? _value.pastEvents
          : pastEvents // ignore: cast_nullable_to_non_nullable
              as int,
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      averageOccupancyRate: null == averageOccupancyRate
          ? _value.averageOccupancyRate
          : averageOccupancyRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalInterestedUsers: null == totalInterestedUsers
          ? _value.totalInterestedUsers
          : totalInterestedUsers // ignore: cast_nullable_to_non_nullable
              as int,
      topEvents: null == topEvents
          ? _value.topEvents
          : topEvents // ignore: cast_nullable_to_non_nullable
              as List<EventAnalytics>,
      monthlyStats: null == monthlyStats
          ? _value.monthlyStats
          : monthlyStats // ignore: cast_nullable_to_non_nullable
              as List<MonthlyStats>,
      bookingsByStatus: null == bookingsByStatus
          ? _value.bookingsByStatus
          : bookingsByStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      revenueByEvent: null == revenueByEvent
          ? _value.revenueByEvent
          : revenueByEvent // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrganizerAnalyticsImplCopyWith<$Res>
    implements $OrganizerAnalyticsCopyWith<$Res> {
  factory _$$OrganizerAnalyticsImplCopyWith(_$OrganizerAnalyticsImpl value,
          $Res Function(_$OrganizerAnalyticsImpl) then) =
      __$$OrganizerAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String organizerId,
      int totalEvents,
      int activeEvents,
      int upcomingEvents,
      int pastEvents,
      int totalBookings,
      double totalRevenue,
      double averageOccupancyRate,
      int totalInterestedUsers,
      List<EventAnalytics> topEvents,
      List<MonthlyStats> monthlyStats,
      Map<String, int> bookingsByStatus,
      Map<String, double> revenueByEvent});
}

/// @nodoc
class __$$OrganizerAnalyticsImplCopyWithImpl<$Res>
    extends _$OrganizerAnalyticsCopyWithImpl<$Res, _$OrganizerAnalyticsImpl>
    implements _$$OrganizerAnalyticsImplCopyWith<$Res> {
  __$$OrganizerAnalyticsImplCopyWithImpl(_$OrganizerAnalyticsImpl _value,
      $Res Function(_$OrganizerAnalyticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrganizerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizerId = null,
    Object? totalEvents = null,
    Object? activeEvents = null,
    Object? upcomingEvents = null,
    Object? pastEvents = null,
    Object? totalBookings = null,
    Object? totalRevenue = null,
    Object? averageOccupancyRate = null,
    Object? totalInterestedUsers = null,
    Object? topEvents = null,
    Object? monthlyStats = null,
    Object? bookingsByStatus = null,
    Object? revenueByEvent = null,
  }) {
    return _then(_$OrganizerAnalyticsImpl(
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      totalEvents: null == totalEvents
          ? _value.totalEvents
          : totalEvents // ignore: cast_nullable_to_non_nullable
              as int,
      activeEvents: null == activeEvents
          ? _value.activeEvents
          : activeEvents // ignore: cast_nullable_to_non_nullable
              as int,
      upcomingEvents: null == upcomingEvents
          ? _value.upcomingEvents
          : upcomingEvents // ignore: cast_nullable_to_non_nullable
              as int,
      pastEvents: null == pastEvents
          ? _value.pastEvents
          : pastEvents // ignore: cast_nullable_to_non_nullable
              as int,
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      averageOccupancyRate: null == averageOccupancyRate
          ? _value.averageOccupancyRate
          : averageOccupancyRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalInterestedUsers: null == totalInterestedUsers
          ? _value.totalInterestedUsers
          : totalInterestedUsers // ignore: cast_nullable_to_non_nullable
              as int,
      topEvents: null == topEvents
          ? _value._topEvents
          : topEvents // ignore: cast_nullable_to_non_nullable
              as List<EventAnalytics>,
      monthlyStats: null == monthlyStats
          ? _value._monthlyStats
          : monthlyStats // ignore: cast_nullable_to_non_nullable
              as List<MonthlyStats>,
      bookingsByStatus: null == bookingsByStatus
          ? _value._bookingsByStatus
          : bookingsByStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      revenueByEvent: null == revenueByEvent
          ? _value._revenueByEvent
          : revenueByEvent // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizerAnalyticsImpl implements _OrganizerAnalytics {
  const _$OrganizerAnalyticsImpl(
      {required this.organizerId,
      this.totalEvents = 0,
      this.activeEvents = 0,
      this.upcomingEvents = 0,
      this.pastEvents = 0,
      this.totalBookings = 0,
      this.totalRevenue = 0.0,
      this.averageOccupancyRate = 0.0,
      this.totalInterestedUsers = 0,
      final List<EventAnalytics> topEvents = const [],
      final List<MonthlyStats> monthlyStats = const [],
      final Map<String, int> bookingsByStatus = const {},
      final Map<String, double> revenueByEvent = const {}})
      : _topEvents = topEvents,
        _monthlyStats = monthlyStats,
        _bookingsByStatus = bookingsByStatus,
        _revenueByEvent = revenueByEvent;

  factory _$OrganizerAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizerAnalyticsImplFromJson(json);

  @override
  final String organizerId;
  @override
  @JsonKey()
  final int totalEvents;
  @override
  @JsonKey()
  final int activeEvents;
  @override
  @JsonKey()
  final int upcomingEvents;
  @override
  @JsonKey()
  final int pastEvents;
  @override
  @JsonKey()
  final int totalBookings;
  @override
  @JsonKey()
  final double totalRevenue;
  @override
  @JsonKey()
  final double averageOccupancyRate;
  @override
  @JsonKey()
  final int totalInterestedUsers;
  final List<EventAnalytics> _topEvents;
  @override
  @JsonKey()
  List<EventAnalytics> get topEvents {
    if (_topEvents is EqualUnmodifiableListView) return _topEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topEvents);
  }

  final List<MonthlyStats> _monthlyStats;
  @override
  @JsonKey()
  List<MonthlyStats> get monthlyStats {
    if (_monthlyStats is EqualUnmodifiableListView) return _monthlyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthlyStats);
  }

  final Map<String, int> _bookingsByStatus;
  @override
  @JsonKey()
  Map<String, int> get bookingsByStatus {
    if (_bookingsByStatus is EqualUnmodifiableMapView) return _bookingsByStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bookingsByStatus);
  }

  final Map<String, double> _revenueByEvent;
  @override
  @JsonKey()
  Map<String, double> get revenueByEvent {
    if (_revenueByEvent is EqualUnmodifiableMapView) return _revenueByEvent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_revenueByEvent);
  }

  @override
  String toString() {
    return 'OrganizerAnalytics(organizerId: $organizerId, totalEvents: $totalEvents, activeEvents: $activeEvents, upcomingEvents: $upcomingEvents, pastEvents: $pastEvents, totalBookings: $totalBookings, totalRevenue: $totalRevenue, averageOccupancyRate: $averageOccupancyRate, totalInterestedUsers: $totalInterestedUsers, topEvents: $topEvents, monthlyStats: $monthlyStats, bookingsByStatus: $bookingsByStatus, revenueByEvent: $revenueByEvent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizerAnalyticsImpl &&
            (identical(other.organizerId, organizerId) ||
                other.organizerId == organizerId) &&
            (identical(other.totalEvents, totalEvents) ||
                other.totalEvents == totalEvents) &&
            (identical(other.activeEvents, activeEvents) ||
                other.activeEvents == activeEvents) &&
            (identical(other.upcomingEvents, upcomingEvents) ||
                other.upcomingEvents == upcomingEvents) &&
            (identical(other.pastEvents, pastEvents) ||
                other.pastEvents == pastEvents) &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.averageOccupancyRate, averageOccupancyRate) ||
                other.averageOccupancyRate == averageOccupancyRate) &&
            (identical(other.totalInterestedUsers, totalInterestedUsers) ||
                other.totalInterestedUsers == totalInterestedUsers) &&
            const DeepCollectionEquality()
                .equals(other._topEvents, _topEvents) &&
            const DeepCollectionEquality()
                .equals(other._monthlyStats, _monthlyStats) &&
            const DeepCollectionEquality()
                .equals(other._bookingsByStatus, _bookingsByStatus) &&
            const DeepCollectionEquality()
                .equals(other._revenueByEvent, _revenueByEvent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      organizerId,
      totalEvents,
      activeEvents,
      upcomingEvents,
      pastEvents,
      totalBookings,
      totalRevenue,
      averageOccupancyRate,
      totalInterestedUsers,
      const DeepCollectionEquality().hash(_topEvents),
      const DeepCollectionEquality().hash(_monthlyStats),
      const DeepCollectionEquality().hash(_bookingsByStatus),
      const DeepCollectionEquality().hash(_revenueByEvent));

  /// Create a copy of OrganizerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizerAnalyticsImplCopyWith<_$OrganizerAnalyticsImpl> get copyWith =>
      __$$OrganizerAnalyticsImplCopyWithImpl<_$OrganizerAnalyticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizerAnalyticsImplToJson(
      this,
    );
  }
}

abstract class _OrganizerAnalytics implements OrganizerAnalytics {
  const factory _OrganizerAnalytics(
      {required final String organizerId,
      final int totalEvents,
      final int activeEvents,
      final int upcomingEvents,
      final int pastEvents,
      final int totalBookings,
      final double totalRevenue,
      final double averageOccupancyRate,
      final int totalInterestedUsers,
      final List<EventAnalytics> topEvents,
      final List<MonthlyStats> monthlyStats,
      final Map<String, int> bookingsByStatus,
      final Map<String, double> revenueByEvent}) = _$OrganizerAnalyticsImpl;

  factory _OrganizerAnalytics.fromJson(Map<String, dynamic> json) =
      _$OrganizerAnalyticsImpl.fromJson;

  @override
  String get organizerId;
  @override
  int get totalEvents;
  @override
  int get activeEvents;
  @override
  int get upcomingEvents;
  @override
  int get pastEvents;
  @override
  int get totalBookings;
  @override
  double get totalRevenue;
  @override
  double get averageOccupancyRate;
  @override
  int get totalInterestedUsers;
  @override
  List<EventAnalytics> get topEvents;
  @override
  List<MonthlyStats> get monthlyStats;
  @override
  Map<String, int> get bookingsByStatus;
  @override
  Map<String, double> get revenueByEvent;

  /// Create a copy of OrganizerAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizerAnalyticsImplCopyWith<_$OrganizerAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MonthlyStats _$MonthlyStatsFromJson(Map<String, dynamic> json) {
  return _MonthlyStats.fromJson(json);
}

/// @nodoc
mixin _$MonthlyStats {
  int get year => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  int get events => throw _privateConstructorUsedError;
  int get bookings => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;

  /// Serializes this MonthlyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyStatsCopyWith<MonthlyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyStatsCopyWith<$Res> {
  factory $MonthlyStatsCopyWith(
          MonthlyStats value, $Res Function(MonthlyStats) then) =
      _$MonthlyStatsCopyWithImpl<$Res, MonthlyStats>;
  @useResult
  $Res call({int year, int month, int events, int bookings, double revenue});
}

/// @nodoc
class _$MonthlyStatsCopyWithImpl<$Res, $Val extends MonthlyStats>
    implements $MonthlyStatsCopyWith<$Res> {
  _$MonthlyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? month = null,
    Object? events = null,
    Object? bookings = null,
    Object? revenue = null,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as int,
      bookings: null == bookings
          ? _value.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as int,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyStatsImplCopyWith<$Res>
    implements $MonthlyStatsCopyWith<$Res> {
  factory _$$MonthlyStatsImplCopyWith(
          _$MonthlyStatsImpl value, $Res Function(_$MonthlyStatsImpl) then) =
      __$$MonthlyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int year, int month, int events, int bookings, double revenue});
}

/// @nodoc
class __$$MonthlyStatsImplCopyWithImpl<$Res>
    extends _$MonthlyStatsCopyWithImpl<$Res, _$MonthlyStatsImpl>
    implements _$$MonthlyStatsImplCopyWith<$Res> {
  __$$MonthlyStatsImplCopyWithImpl(
      _$MonthlyStatsImpl _value, $Res Function(_$MonthlyStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? month = null,
    Object? events = null,
    Object? bookings = null,
    Object? revenue = null,
  }) {
    return _then(_$MonthlyStatsImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as int,
      bookings: null == bookings
          ? _value.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as int,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyStatsImpl implements _MonthlyStats {
  const _$MonthlyStatsImpl(
      {required this.year,
      required this.month,
      this.events = 0,
      this.bookings = 0,
      this.revenue = 0.0});

  factory _$MonthlyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyStatsImplFromJson(json);

  @override
  final int year;
  @override
  final int month;
  @override
  @JsonKey()
  final int events;
  @override
  @JsonKey()
  final int bookings;
  @override
  @JsonKey()
  final double revenue;

  @override
  String toString() {
    return 'MonthlyStats(year: $year, month: $month, events: $events, bookings: $bookings, revenue: $revenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyStatsImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.events, events) || other.events == events) &&
            (identical(other.bookings, bookings) ||
                other.bookings == bookings) &&
            (identical(other.revenue, revenue) || other.revenue == revenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, year, month, events, bookings, revenue);

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyStatsImplCopyWith<_$MonthlyStatsImpl> get copyWith =>
      __$$MonthlyStatsImplCopyWithImpl<_$MonthlyStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyStatsImplToJson(
      this,
    );
  }
}

abstract class _MonthlyStats implements MonthlyStats {
  const factory _MonthlyStats(
      {required final int year,
      required final int month,
      final int events,
      final int bookings,
      final double revenue}) = _$MonthlyStatsImpl;

  factory _MonthlyStats.fromJson(Map<String, dynamic> json) =
      _$MonthlyStatsImpl.fromJson;

  @override
  int get year;
  @override
  int get month;
  @override
  int get events;
  @override
  int get bookings;
  @override
  double get revenue;

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyStatsImplCopyWith<_$MonthlyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RealTimeEventStats _$RealTimeEventStatsFromJson(Map<String, dynamic> json) {
  return _RealTimeEventStats.fromJson(json);
}

/// @nodoc
mixin _$RealTimeEventStats {
  String get eventId => throw _privateConstructorUsedError;
  int get currentVisitors => throw _privateConstructorUsedError;
  int get todayViews => throw _privateConstructorUsedError;
  int get todayBookings => throw _privateConstructorUsedError;
  double get todayRevenue => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this RealTimeEventStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RealTimeEventStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RealTimeEventStatsCopyWith<RealTimeEventStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RealTimeEventStatsCopyWith<$Res> {
  factory $RealTimeEventStatsCopyWith(
          RealTimeEventStats value, $Res Function(RealTimeEventStats) then) =
      _$RealTimeEventStatsCopyWithImpl<$Res, RealTimeEventStats>;
  @useResult
  $Res call(
      {String eventId,
      int currentVisitors,
      int todayViews,
      int todayBookings,
      double todayRevenue,
      DateTime? lastUpdated});
}

/// @nodoc
class _$RealTimeEventStatsCopyWithImpl<$Res, $Val extends RealTimeEventStats>
    implements $RealTimeEventStatsCopyWith<$Res> {
  _$RealTimeEventStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RealTimeEventStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? currentVisitors = null,
    Object? todayViews = null,
    Object? todayBookings = null,
    Object? todayRevenue = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      currentVisitors: null == currentVisitors
          ? _value.currentVisitors
          : currentVisitors // ignore: cast_nullable_to_non_nullable
              as int,
      todayViews: null == todayViews
          ? _value.todayViews
          : todayViews // ignore: cast_nullable_to_non_nullable
              as int,
      todayBookings: null == todayBookings
          ? _value.todayBookings
          : todayBookings // ignore: cast_nullable_to_non_nullable
              as int,
      todayRevenue: null == todayRevenue
          ? _value.todayRevenue
          : todayRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RealTimeEventStatsImplCopyWith<$Res>
    implements $RealTimeEventStatsCopyWith<$Res> {
  factory _$$RealTimeEventStatsImplCopyWith(_$RealTimeEventStatsImpl value,
          $Res Function(_$RealTimeEventStatsImpl) then) =
      __$$RealTimeEventStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String eventId,
      int currentVisitors,
      int todayViews,
      int todayBookings,
      double todayRevenue,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$RealTimeEventStatsImplCopyWithImpl<$Res>
    extends _$RealTimeEventStatsCopyWithImpl<$Res, _$RealTimeEventStatsImpl>
    implements _$$RealTimeEventStatsImplCopyWith<$Res> {
  __$$RealTimeEventStatsImplCopyWithImpl(_$RealTimeEventStatsImpl _value,
      $Res Function(_$RealTimeEventStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RealTimeEventStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? currentVisitors = null,
    Object? todayViews = null,
    Object? todayBookings = null,
    Object? todayRevenue = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$RealTimeEventStatsImpl(
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      currentVisitors: null == currentVisitors
          ? _value.currentVisitors
          : currentVisitors // ignore: cast_nullable_to_non_nullable
              as int,
      todayViews: null == todayViews
          ? _value.todayViews
          : todayViews // ignore: cast_nullable_to_non_nullable
              as int,
      todayBookings: null == todayBookings
          ? _value.todayBookings
          : todayBookings // ignore: cast_nullable_to_non_nullable
              as int,
      todayRevenue: null == todayRevenue
          ? _value.todayRevenue
          : todayRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RealTimeEventStatsImpl implements _RealTimeEventStats {
  const _$RealTimeEventStatsImpl(
      {required this.eventId,
      this.currentVisitors = 0,
      this.todayViews = 0,
      this.todayBookings = 0,
      this.todayRevenue = 0.0,
      this.lastUpdated});

  factory _$RealTimeEventStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RealTimeEventStatsImplFromJson(json);

  @override
  final String eventId;
  @override
  @JsonKey()
  final int currentVisitors;
  @override
  @JsonKey()
  final int todayViews;
  @override
  @JsonKey()
  final int todayBookings;
  @override
  @JsonKey()
  final double todayRevenue;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'RealTimeEventStats(eventId: $eventId, currentVisitors: $currentVisitors, todayViews: $todayViews, todayBookings: $todayBookings, todayRevenue: $todayRevenue, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RealTimeEventStatsImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.currentVisitors, currentVisitors) ||
                other.currentVisitors == currentVisitors) &&
            (identical(other.todayViews, todayViews) ||
                other.todayViews == todayViews) &&
            (identical(other.todayBookings, todayBookings) ||
                other.todayBookings == todayBookings) &&
            (identical(other.todayRevenue, todayRevenue) ||
                other.todayRevenue == todayRevenue) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, eventId, currentVisitors,
      todayViews, todayBookings, todayRevenue, lastUpdated);

  /// Create a copy of RealTimeEventStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RealTimeEventStatsImplCopyWith<_$RealTimeEventStatsImpl> get copyWith =>
      __$$RealTimeEventStatsImplCopyWithImpl<_$RealTimeEventStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RealTimeEventStatsImplToJson(
      this,
    );
  }
}

abstract class _RealTimeEventStats implements RealTimeEventStats {
  const factory _RealTimeEventStats(
      {required final String eventId,
      final int currentVisitors,
      final int todayViews,
      final int todayBookings,
      final double todayRevenue,
      final DateTime? lastUpdated}) = _$RealTimeEventStatsImpl;

  factory _RealTimeEventStats.fromJson(Map<String, dynamic> json) =
      _$RealTimeEventStatsImpl.fromJson;

  @override
  String get eventId;
  @override
  int get currentVisitors;
  @override
  int get todayViews;
  @override
  int get todayBookings;
  @override
  double get todayRevenue;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of RealTimeEventStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RealTimeEventStatsImplCopyWith<_$RealTimeEventStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AnalyticsFilter _$AnalyticsFilterFromJson(Map<String, dynamic> json) {
  return _AnalyticsFilter.fromJson(json);
}

/// @nodoc
mixin _$AnalyticsFilter {
  AnalyticsDateRange get dateRange => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String? get eventId => throw _privateConstructorUsedError;

  /// Serializes this AnalyticsFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalyticsFilterCopyWith<AnalyticsFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsFilterCopyWith<$Res> {
  factory $AnalyticsFilterCopyWith(
          AnalyticsFilter value, $Res Function(AnalyticsFilter) then) =
      _$AnalyticsFilterCopyWithImpl<$Res, AnalyticsFilter>;
  @useResult
  $Res call(
      {AnalyticsDateRange dateRange,
      DateTime? startDate,
      DateTime? endDate,
      String? eventId});
}

/// @nodoc
class _$AnalyticsFilterCopyWithImpl<$Res, $Val extends AnalyticsFilter>
    implements $AnalyticsFilterCopyWith<$Res> {
  _$AnalyticsFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateRange = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? eventId = freezed,
  }) {
    return _then(_value.copyWith(
      dateRange: null == dateRange
          ? _value.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as AnalyticsDateRange,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnalyticsFilterImplCopyWith<$Res>
    implements $AnalyticsFilterCopyWith<$Res> {
  factory _$$AnalyticsFilterImplCopyWith(_$AnalyticsFilterImpl value,
          $Res Function(_$AnalyticsFilterImpl) then) =
      __$$AnalyticsFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AnalyticsDateRange dateRange,
      DateTime? startDate,
      DateTime? endDate,
      String? eventId});
}

/// @nodoc
class __$$AnalyticsFilterImplCopyWithImpl<$Res>
    extends _$AnalyticsFilterCopyWithImpl<$Res, _$AnalyticsFilterImpl>
    implements _$$AnalyticsFilterImplCopyWith<$Res> {
  __$$AnalyticsFilterImplCopyWithImpl(
      _$AnalyticsFilterImpl _value, $Res Function(_$AnalyticsFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateRange = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? eventId = freezed,
  }) {
    return _then(_$AnalyticsFilterImpl(
      dateRange: null == dateRange
          ? _value.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as AnalyticsDateRange,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyticsFilterImpl implements _AnalyticsFilter {
  const _$AnalyticsFilterImpl(
      {this.dateRange = AnalyticsDateRange.last30Days,
      this.startDate,
      this.endDate,
      this.eventId});

  factory _$AnalyticsFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyticsFilterImplFromJson(json);

  @override
  @JsonKey()
  final AnalyticsDateRange dateRange;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final String? eventId;

  @override
  String toString() {
    return 'AnalyticsFilter(dateRange: $dateRange, startDate: $startDate, endDate: $endDate, eventId: $eventId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsFilterImpl &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.eventId, eventId) || other.eventId == eventId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, dateRange, startDate, endDate, eventId);

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsFilterImplCopyWith<_$AnalyticsFilterImpl> get copyWith =>
      __$$AnalyticsFilterImplCopyWithImpl<_$AnalyticsFilterImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyticsFilterImplToJson(
      this,
    );
  }
}

abstract class _AnalyticsFilter implements AnalyticsFilter {
  const factory _AnalyticsFilter(
      {final AnalyticsDateRange dateRange,
      final DateTime? startDate,
      final DateTime? endDate,
      final String? eventId}) = _$AnalyticsFilterImpl;

  factory _AnalyticsFilter.fromJson(Map<String, dynamic> json) =
      _$AnalyticsFilterImpl.fromJson;

  @override
  AnalyticsDateRange get dateRange;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  String? get eventId;

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalyticsFilterImplCopyWith<_$AnalyticsFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
