// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventAnalyticsImpl _$$EventAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$EventAnalyticsImpl(
      eventId: json['eventId'] as String,
      eventTitle: json['eventTitle'] as String,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      uniqueVisitors: (json['uniqueVisitors'] as num?)?.toInt() ?? 0,
      interestedCount: (json['interestedCount'] as num?)?.toInt() ?? 0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      confirmedBookings: (json['confirmedBookings'] as num?)?.toInt() ?? 0,
      pendingBookings: (json['pendingBookings'] as num?)?.toInt() ?? 0,
      cancelledBookings: (json['cancelledBookings'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalBooths: (json['totalBooths'] as num?)?.toInt() ?? 0,
      bookedBooths: (json['bookedBooths'] as num?)?.toInt() ?? 0,
      availableBooths: (json['availableBooths'] as num?)?.toInt() ?? 0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
      dailyStats: (json['dailyStats'] as List<dynamic>?)
              ?.map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      boothTypeBreakdown:
          (json['boothTypeBreakdown'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      revenueByBoothType:
          (json['revenueByBoothType'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toDouble()),
              ) ??
              const {},
    );

Map<String, dynamic> _$$EventAnalyticsImplToJson(
        _$EventAnalyticsImpl instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'eventTitle': instance.eventTitle,
      'totalViews': instance.totalViews,
      'uniqueVisitors': instance.uniqueVisitors,
      'interestedCount': instance.interestedCount,
      'totalBookings': instance.totalBookings,
      'confirmedBookings': instance.confirmedBookings,
      'pendingBookings': instance.pendingBookings,
      'cancelledBookings': instance.cancelledBookings,
      'totalRevenue': instance.totalRevenue,
      'totalBooths': instance.totalBooths,
      'bookedBooths': instance.bookedBooths,
      'availableBooths': instance.availableBooths,
      'occupancyRate': instance.occupancyRate,
      'dailyStats': instance.dailyStats,
      'boothTypeBreakdown': instance.boothTypeBreakdown,
      'revenueByBoothType': instance.revenueByBoothType,
    };

_$DailyStatsImpl _$$DailyStatsImplFromJson(Map<String, dynamic> json) =>
    _$DailyStatsImpl(
      date: DateTime.parse(json['date'] as String),
      views: (json['views'] as num?)?.toInt() ?? 0,
      bookings: (json['bookings'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$DailyStatsImplToJson(_$DailyStatsImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'views': instance.views,
      'bookings': instance.bookings,
      'revenue': instance.revenue,
    };

_$OrganizerAnalyticsImpl _$$OrganizerAnalyticsImplFromJson(
        Map<String, dynamic> json) =>
    _$OrganizerAnalyticsImpl(
      organizerId: json['organizerId'] as String,
      totalEvents: (json['totalEvents'] as num?)?.toInt() ?? 0,
      activeEvents: (json['activeEvents'] as num?)?.toInt() ?? 0,
      upcomingEvents: (json['upcomingEvents'] as num?)?.toInt() ?? 0,
      pastEvents: (json['pastEvents'] as num?)?.toInt() ?? 0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      averageOccupancyRate:
          (json['averageOccupancyRate'] as num?)?.toDouble() ?? 0.0,
      totalInterestedUsers:
          (json['totalInterestedUsers'] as num?)?.toInt() ?? 0,
      topEvents: (json['topEvents'] as List<dynamic>?)
              ?.map((e) => EventAnalytics.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      monthlyStats: (json['monthlyStats'] as List<dynamic>?)
              ?.map((e) => MonthlyStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bookingsByStatus:
          (json['bookingsByStatus'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      revenueByEvent: (json['revenueByEvent'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$OrganizerAnalyticsImplToJson(
        _$OrganizerAnalyticsImpl instance) =>
    <String, dynamic>{
      'organizerId': instance.organizerId,
      'totalEvents': instance.totalEvents,
      'activeEvents': instance.activeEvents,
      'upcomingEvents': instance.upcomingEvents,
      'pastEvents': instance.pastEvents,
      'totalBookings': instance.totalBookings,
      'totalRevenue': instance.totalRevenue,
      'averageOccupancyRate': instance.averageOccupancyRate,
      'totalInterestedUsers': instance.totalInterestedUsers,
      'topEvents': instance.topEvents,
      'monthlyStats': instance.monthlyStats,
      'bookingsByStatus': instance.bookingsByStatus,
      'revenueByEvent': instance.revenueByEvent,
    };

_$MonthlyStatsImpl _$$MonthlyStatsImplFromJson(Map<String, dynamic> json) =>
    _$MonthlyStatsImpl(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      events: (json['events'] as num?)?.toInt() ?? 0,
      bookings: (json['bookings'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$MonthlyStatsImplToJson(_$MonthlyStatsImpl instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'events': instance.events,
      'bookings': instance.bookings,
      'revenue': instance.revenue,
    };

_$RealTimeEventStatsImpl _$$RealTimeEventStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$RealTimeEventStatsImpl(
      eventId: json['eventId'] as String,
      currentVisitors: (json['currentVisitors'] as num?)?.toInt() ?? 0,
      todayViews: (json['todayViews'] as num?)?.toInt() ?? 0,
      todayBookings: (json['todayBookings'] as num?)?.toInt() ?? 0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$RealTimeEventStatsImplToJson(
        _$RealTimeEventStatsImpl instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'currentVisitors': instance.currentVisitors,
      'todayViews': instance.todayViews,
      'todayBookings': instance.todayBookings,
      'todayRevenue': instance.todayRevenue,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_$AnalyticsFilterImpl _$$AnalyticsFilterImplFromJson(
        Map<String, dynamic> json) =>
    _$AnalyticsFilterImpl(
      dateRange:
          $enumDecodeNullable(_$AnalyticsDateRangeEnumMap, json['dateRange']) ??
              AnalyticsDateRange.last30Days,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      eventId: json['eventId'] as String?,
    );

Map<String, dynamic> _$$AnalyticsFilterImplToJson(
        _$AnalyticsFilterImpl instance) =>
    <String, dynamic>{
      'dateRange': _$AnalyticsDateRangeEnumMap[instance.dateRange]!,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'eventId': instance.eventId,
    };

const _$AnalyticsDateRangeEnumMap = {
  AnalyticsDateRange.today: 'today',
  AnalyticsDateRange.yesterday: 'yesterday',
  AnalyticsDateRange.last7Days: 'last7Days',
  AnalyticsDateRange.last30Days: 'last30Days',
  AnalyticsDateRange.thisMonth: 'thisMonth',
  AnalyticsDateRange.lastMonth: 'lastMonth',
  AnalyticsDateRange.thisYear: 'thisYear',
  AnalyticsDateRange.custom: 'custom',
};
