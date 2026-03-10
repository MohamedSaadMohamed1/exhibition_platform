import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_model.freezed.dart';
part 'analytics_model.g.dart';

/// Event analytics model
@freezed
class EventAnalytics with _$EventAnalytics {
  const factory EventAnalytics({
    required String eventId,
    required String eventTitle,
    @Default(0) int totalViews,
    @Default(0) int uniqueVisitors,
    @Default(0) int interestedCount,
    @Default(0) int totalBookings,
    @Default(0) int confirmedBookings,
    @Default(0) int pendingBookings,
    @Default(0) int cancelledBookings,
    @Default(0.0) double totalRevenue,
    @Default(0) int totalBooths,
    @Default(0) int bookedBooths,
    @Default(0) int availableBooths,
    @Default(0.0) double occupancyRate,
    @Default([]) List<DailyStats> dailyStats,
    @Default({}) Map<String, int> boothTypeBreakdown,
    @Default({}) Map<String, double> revenueByBoothType,
  }) = _EventAnalytics;

  factory EventAnalytics.fromJson(Map<String, dynamic> json) =>
      _$EventAnalyticsFromJson(json);
}

/// Daily statistics
@freezed
class DailyStats with _$DailyStats {
  const factory DailyStats({
    required DateTime date,
    @Default(0) int views,
    @Default(0) int bookings,
    @Default(0.0) double revenue,
  }) = _DailyStats;

  factory DailyStats.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsFromJson(json);
}

/// Organizer dashboard analytics
@freezed
class OrganizerAnalytics with _$OrganizerAnalytics {
  const factory OrganizerAnalytics({
    required String organizerId,
    @Default(0) int totalEvents,
    @Default(0) int activeEvents,
    @Default(0) int upcomingEvents,
    @Default(0) int pastEvents,
    @Default(0) int totalBookings,
    @Default(0.0) double totalRevenue,
    @Default(0.0) double averageOccupancyRate,
    @Default(0) int totalInterestedUsers,
    @Default([]) List<EventAnalytics> topEvents,
    @Default([]) List<MonthlyStats> monthlyStats,
    @Default({}) Map<String, int> bookingsByStatus,
    @Default({}) Map<String, double> revenueByEvent,
  }) = _OrganizerAnalytics;

  factory OrganizerAnalytics.fromJson(Map<String, dynamic> json) =>
      _$OrganizerAnalyticsFromJson(json);
}

/// Monthly statistics
@freezed
class MonthlyStats with _$MonthlyStats {
  const factory MonthlyStats({
    required int year,
    required int month,
    @Default(0) int events,
    @Default(0) int bookings,
    @Default(0.0) double revenue,
  }) = _MonthlyStats;

  factory MonthlyStats.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatsFromJson(json);
}

/// Real-time event stats
@freezed
class RealTimeEventStats with _$RealTimeEventStats {
  const factory RealTimeEventStats({
    required String eventId,
    @Default(0) int currentVisitors,
    @Default(0) int todayViews,
    @Default(0) int todayBookings,
    @Default(0.0) double todayRevenue,
    DateTime? lastUpdated,
  }) = _RealTimeEventStats;

  factory RealTimeEventStats.fromJson(Map<String, dynamic> json) =>
      _$RealTimeEventStatsFromJson(json);
}

/// Analytics date range
enum AnalyticsDateRange {
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

/// Analytics filter
@freezed
class AnalyticsFilter with _$AnalyticsFilter {
  const factory AnalyticsFilter({
    @Default(AnalyticsDateRange.last30Days) AnalyticsDateRange dateRange,
    DateTime? startDate,
    DateTime? endDate,
    String? eventId,
  }) = _AnalyticsFilter;

  factory AnalyticsFilter.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsFilterFromJson(json);
}
