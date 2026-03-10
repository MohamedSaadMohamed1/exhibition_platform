import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/providers/providers.dart';
import '../../data/models/analytics_model.dart';
import '../providers/analytics_provider.dart';

class OrganizerAnalyticsScreen extends ConsumerWidget {
  const OrganizerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        body: Center(
          child: Text(
            'Please login to view analytics',
            style: TextStyle(color: AppColors.textPrimaryDark),
          ),
        ),
      );
    }

    final analyticsState = ref.watch(organizerAnalyticsProvider(currentUser.uid));

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Analytics',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        actions: [
          PopupMenuButton<AnalyticsDateRange>(
            icon: const Icon(Icons.date_range, color: AppColors.textPrimaryDark),
            color: AppColors.surfaceDark,
            onSelected: (range) {
              ref.read(organizerAnalyticsProvider(currentUser.uid).notifier)
                  .updateFilter(AnalyticsFilter(dateRange: range));
            },
            itemBuilder: (context) => [
              _buildDateRangeItem('Today', AnalyticsDateRange.today),
              _buildDateRangeItem('Last 7 Days', AnalyticsDateRange.last7Days),
              _buildDateRangeItem('Last 30 Days', AnalyticsDateRange.last30Days),
              _buildDateRangeItem('This Month', AnalyticsDateRange.thisMonth),
              _buildDateRangeItem('This Year', AnalyticsDateRange.thisYear),
            ],
          ),
        ],
      ),
      body: _buildBody(analyticsState, currentUser.uid, ref),
    );
  }

  PopupMenuItem<AnalyticsDateRange> _buildDateRangeItem(
    String label,
    AnalyticsDateRange range,
  ) {
    return PopupMenuItem(
      value: range,
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimaryDark),
      ),
    );
  }

  Widget _buildBody(AnalyticsState state, String userId, WidgetRef ref) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(organizerAnalyticsProvider(userId).notifier).refresh(),
      );
    }

    final analytics = state.analytics;
    if (analytics == null) {
      return const EmptyStateWidget(
        title: 'No analytics data',
        subtitle: 'Create events to see your analytics',
        icon: Icons.analytics,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(organizerAnalyticsProvider(userId).notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildOverviewSection(analytics),
            const SizedBox(height: 24),

            // Events Breakdown
            _buildEventsSection(analytics),
            const SizedBox(height: 24),

            // Bookings Section
            _buildBookingsSection(analytics),
            const SizedBox(height: 24),

            // Top Events
            if (analytics.topEvents.isNotEmpty) ...[
              _buildTopEventsSection(analytics),
              const SizedBox(height: 24),
            ],

            // Revenue Chart Placeholder
            _buildRevenueSection(analytics),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(OrganizerAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Revenue',
                value: '\$${analytics.totalRevenue.toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Total Bookings',
                value: analytics.totalBookings.toString(),
                icon: Icons.confirmation_number,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Avg. Occupancy',
                value: '${analytics.averageOccupancyRate.toStringAsFixed(1)}%',
                icon: Icons.pie_chart,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Interested Users',
                value: analytics.totalInterestedUsers.toString(),
                icon: Icons.favorite,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventsSection(OrganizerAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Events',
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _EventStatItem(
                label: 'Total',
                value: analytics.totalEvents,
                color: AppColors.textPrimaryDark,
              ),
              _EventStatItem(
                label: 'Active',
                value: analytics.activeEvents,
                color: AppColors.success,
              ),
              _EventStatItem(
                label: 'Upcoming',
                value: analytics.upcomingEvents,
                color: AppColors.primary,
              ),
              _EventStatItem(
                label: 'Past',
                value: analytics.pastEvents,
                color: AppColors.textMutedDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsSection(OrganizerAnalytics analytics) {
    final bookingsByStatus = analytics.bookingsByStatus;
    final confirmed = bookingsByStatus['confirmed'] ?? 0;
    final pending = bookingsByStatus['pending'] ?? 0;
    final cancelled = bookingsByStatus['cancelled'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bookings Breakdown',
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _BookingStatusBar(
            confirmed: confirmed,
            pending: pending,
            cancelled: cancelled,
            total: analytics.totalBookings,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BookingStatusItem(
                label: 'Confirmed',
                value: confirmed,
                color: AppColors.success,
              ),
              _BookingStatusItem(
                label: 'Pending',
                value: pending,
                color: AppColors.warning,
              ),
              _BookingStatusItem(
                label: 'Cancelled',
                value: cancelled,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopEventsSection(OrganizerAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Events',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...analytics.topEvents.take(5).map((event) => _TopEventItem(event: event)),
      ],
    );
  }

  Widget _buildRevenueSection(OrganizerAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Revenue Trend',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${analytics.totalRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Placeholder for chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Revenue Chart\n(Coming Soon)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMutedDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventStatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _EventStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingStatusBar extends StatelessWidget {
  final int confirmed;
  final int pending;
  final int cancelled;
  final int total;

  const _BookingStatusBar({
    required this.confirmed,
    required this.pending,
    required this.cancelled,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.grey600,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          if (confirmed > 0)
            Expanded(
              flex: confirmed,
              child: Container(color: AppColors.success),
            ),
          if (pending > 0)
            Expanded(
              flex: pending,
              child: Container(color: AppColors.warning),
            ),
          if (cancelled > 0)
            Expanded(
              flex: cancelled,
              child: Container(color: AppColors.error),
            ),
        ],
      ),
    );
  }
}

class _BookingStatusItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _BookingStatusItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value.toString(),
              style: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _TopEventItem extends StatelessWidget {
  final EventAnalytics event;

  const _TopEventItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      '${event.interestedCount} interested',
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.confirmation_number, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${event.totalBookings} bookings',
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMutedDark),
        ],
      ),
    );
  }
}
