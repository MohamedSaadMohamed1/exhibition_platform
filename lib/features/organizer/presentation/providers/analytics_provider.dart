import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analytics_model.dart';
import '../../../../shared/providers/providers.dart';

/// Analytics state
class AnalyticsState {
  final OrganizerAnalytics? analytics;
  final bool isLoading;
  final String? errorMessage;
  final AnalyticsFilter filter;

  const AnalyticsState({
    this.analytics,
    this.isLoading = false,
    this.errorMessage,
    this.filter = const AnalyticsFilter(),
  });

  AnalyticsState copyWith({
    OrganizerAnalytics? analytics,
    bool? isLoading,
    String? errorMessage,
    AnalyticsFilter? filter,
  }) {
    return AnalyticsState(
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

/// Analytics notifier for organizer dashboard
class OrganizerAnalyticsNotifier extends FamilyNotifier<AnalyticsState, String> {
  late final FirebaseFirestore _firestore;

  @override
  AnalyticsState build(String organizerId) {
    _firestore = ref.watch(firestoreProvider);
    Future.microtask(() => _loadAnalytics(organizerId));
    return const AnalyticsState(isLoading: true);
  }

  Future<void> _loadAnalytics(String organizerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final analytics = await _fetchOrganizerAnalytics(organizerId);
      state = state.copyWith(
        analytics: analytics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load analytics: $e',
        isLoading: false,
      );
    }
  }

  Future<OrganizerAnalytics> _fetchOrganizerAnalytics(String organizerId) async {
    // Get date range
    final dateRange = _getDateRange(state.filter.dateRange);

    // Fetch events
    final eventsQuery = await _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .get();

    final events = eventsQuery.docs;
    final eventIds = events.map((e) => e.id).toList();

    // Calculate event stats
    int totalEvents = events.length;
    int activeEvents = 0;
    int upcomingEvents = 0;
    int pastEvents = 0;
    int totalInterestedUsers = 0;

    final now = DateTime.now();
    for (final event in events) {
      final data = event.data();
      final startDate = (data['startDate'] as Timestamp).toDate();
      final endDate = (data['endDate'] as Timestamp).toDate();

      if (now.isBefore(startDate)) {
        upcomingEvents++;
      } else if (now.isAfter(endDate)) {
        pastEvents++;
      } else {
        activeEvents++;
      }

      totalInterestedUsers += (data['interestedCount'] as int?) ?? 0;
    }

    // Fetch bookings
    int totalBookings = 0;
    double totalRevenue = 0.0;
    Map<String, int> bookingsByStatus = {};

    if (eventIds.isNotEmpty) {
      // Firestore limits whereIn to 10 items, so we need to batch
      for (var i = 0; i < eventIds.length; i += 10) {
        final batchIds = eventIds.sublist(
          i,
          i + 10 > eventIds.length ? eventIds.length : i + 10,
        );

        final bookingsQuery = await _firestore
            .collection('bookings')
            .where('eventId', whereIn: batchIds)
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end))
            .get();

        for (final booking in bookingsQuery.docs) {
          final data = booking.data();
          totalBookings++;
          totalRevenue += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

          final status = data['status'] as String? ?? 'unknown';
          bookingsByStatus[status] = (bookingsByStatus[status] ?? 0) + 1;
        }
      }
    }

    // Calculate average occupancy
    double totalOccupancy = 0.0;
    int eventsWithBooths = 0;

    for (final event in events) {
      final data = event.data();
      final totalBooths = (data['boothCount'] as int?) ?? 0;

      if (totalBooths > 0) {
        final bookedBooths = await _getBookedBoothsCount(event.id);
        totalOccupancy += bookedBooths / totalBooths;
        eventsWithBooths++;
      }
    }

    final averageOccupancyRate = eventsWithBooths > 0
        ? (totalOccupancy / eventsWithBooths) * 100
        : 0.0;

    // Get monthly stats
    final monthlyStats = await _getMonthlyStats(organizerId, dateRange);

    // Get top events
    final topEvents = await _getTopEvents(organizerId, 5);

    return OrganizerAnalytics(
      organizerId: organizerId,
      totalEvents: totalEvents,
      activeEvents: activeEvents,
      upcomingEvents: upcomingEvents,
      pastEvents: pastEvents,
      totalBookings: totalBookings,
      totalRevenue: totalRevenue,
      averageOccupancyRate: averageOccupancyRate,
      totalInterestedUsers: totalInterestedUsers,
      topEvents: topEvents,
      monthlyStats: monthlyStats,
      bookingsByStatus: bookingsByStatus,
    );
  }

  Future<int> _getBookedBoothsCount(String eventId) async {
    final query = await _firestore
        .collection('bookings')
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'confirmed')
        .count()
        .get();

    return query.count ?? 0;
  }

  Future<List<MonthlyStats>> _getMonthlyStats(
    String organizerId,
    DateTimeRange dateRange,
  ) async {
    // Simplified - in production, use aggregation queries
    final stats = <MonthlyStats>[];

    var current = DateTime(dateRange.start.year, dateRange.start.month);
    final end = DateTime(dateRange.end.year, dateRange.end.month);

    while (!current.isAfter(end)) {
      stats.add(MonthlyStats(
        year: current.year,
        month: current.month,
        events: 0,
        bookings: 0,
        revenue: 0.0,
      ));
      current = DateTime(current.year, current.month + 1);
    }

    return stats;
  }

  Future<List<EventAnalytics>> _getTopEvents(
    String organizerId,
    int limit,
  ) async {
    final eventsQuery = await _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('interestedCount', descending: true)
        .limit(limit)
        .get();

    final topEvents = <EventAnalytics>[];

    for (final event in eventsQuery.docs) {
      final data = event.data();

      // Get bookings count
      final bookingsCount = await _firestore
          .collection('bookings')
          .where('eventId', isEqualTo: event.id)
          .count()
          .get();

      topEvents.add(EventAnalytics(
        eventId: event.id,
        eventTitle: data['title'] as String? ?? 'Unknown',
        interestedCount: (data['interestedCount'] as int?) ?? 0,
        totalBookings: bookingsCount.count ?? 0,
        totalBooths: (data['boothCount'] as int?) ?? 0,
      ));
    }

    return topEvents;
  }

  DateTimeRange _getDateRange(AnalyticsDateRange range) {
    final now = DateTime.now();

    switch (range) {
      case AnalyticsDateRange.today:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case AnalyticsDateRange.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: DateTime(yesterday.year, yesterday.month, yesterday.day),
          end: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        );
      case AnalyticsDateRange.last7Days:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      case AnalyticsDateRange.last30Days:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
      case AnalyticsDateRange.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case AnalyticsDateRange.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return DateTimeRange(
          start: lastMonth,
          end: DateTime(now.year, now.month, 0),
        );
      case AnalyticsDateRange.thisYear:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
      case AnalyticsDateRange.custom:
        return DateTimeRange(
          start: state.filter.startDate ?? now.subtract(const Duration(days: 30)),
          end: state.filter.endDate ?? now,
        );
    }
  }

  Future<void> refresh() async {
    await _loadAnalytics(arg);
  }

  void updateFilter(AnalyticsFilter filter) {
    state = state.copyWith(filter: filter);
    _loadAnalytics(arg);
  }
}

/// Organizer analytics provider
final organizerAnalyticsProvider = NotifierProvider.family<
    OrganizerAnalyticsNotifier, AnalyticsState, String>(() {
  return OrganizerAnalyticsNotifier();
});

/// Event analytics provider
final eventAnalyticsProvider =
    FutureProvider.family<EventAnalytics?, String>((ref, eventId) async {
  final firestore = ref.watch(firestoreProvider);

  final eventDoc = await firestore.collection('events').doc(eventId).get();
  if (!eventDoc.exists) return null;

  final data = eventDoc.data()!;

  // Get bookings
  final bookingsQuery = await firestore
      .collection('bookings')
      .where('eventId', isEqualTo: eventId)
      .get();

  int confirmedBookings = 0;
  int pendingBookings = 0;
  int cancelledBookings = 0;
  double totalRevenue = 0.0;

  for (final booking in bookingsQuery.docs) {
    final bookingData = booking.data();
    final status = bookingData['status'] as String?;
    final amount = (bookingData['totalAmount'] as num?)?.toDouble() ?? 0.0;

    switch (status) {
      case 'confirmed':
        confirmedBookings++;
        totalRevenue += amount;
        break;
      case 'pending':
        pendingBookings++;
        break;
      case 'cancelled':
        cancelledBookings++;
        break;
    }
  }

  final totalBooths = (data['boothCount'] as int?) ?? 0;
  final bookedBooths = confirmedBookings;
  final availableBooths = totalBooths - bookedBooths;
  final occupancyRate = totalBooths > 0 ? (bookedBooths / totalBooths) * 100 : 0.0;

  return EventAnalytics(
    eventId: eventId,
    eventTitle: data['title'] as String? ?? 'Unknown',
    interestedCount: (data['interestedCount'] as int?) ?? 0,
    totalBookings: bookingsQuery.docs.length,
    confirmedBookings: confirmedBookings,
    pendingBookings: pendingBookings,
    cancelledBookings: cancelledBookings,
    totalRevenue: totalRevenue,
    totalBooths: totalBooths,
    bookedBooths: bookedBooths,
    availableBooths: availableBooths,
    occupancyRate: occupancyRate,
  );
});

/// DateTimeRange helper class
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}
