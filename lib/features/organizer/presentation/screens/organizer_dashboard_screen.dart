import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/widgets/role_dashboard_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/presentation/providers/events_provider.dart';
import '../../../../shared/models/event_model.dart';
import '../providers/organizer_booking_provider.dart';
import '../providers/analytics_provider.dart';
import '../../../chat/presentation/screens/chats_screen.dart';
import '../widgets/booking_management/booking_request_card.dart';
import '../widgets/booking_management/booking_detail_sheet.dart';
import '../widgets/booking_management/booking_filter_chips.dart';

class OrganizerDashboardScreen extends ConsumerStatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  ConsumerState<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends ConsumerState<OrganizerDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    final navItems = [
      const NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      const NavItem(icon: Icons.event_rounded, label: 'Events'),
      const NavItem(icon: Icons.bookmark_rounded, label: 'Bookings'),
      const NavItem(icon: Icons.chat_rounded, label: 'Messages'),
      const NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return RoleDashboardShell(
      currentIndex: _currentIndex,
      navItems: navItems,
      onNavTap: _onNavTap,
      accentColor: AppColors.organizerColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(currentUser: currentUser),
          const _EventsTab(),
          const _BookingsTab(),
          const _MessagesTab(),
          const _ProfileTab(),
        ],
      ),
    );
  }
}

// Dashboard Tab
class _DashboardTab extends ConsumerWidget {
  final dynamic currentUser;

  const _DashboardTab({this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = currentUser?.id ?? '';
    final analyticsState = userId.isNotEmpty
        ? ref.watch(organizerAnalyticsProvider(userId))
        : const AnalyticsState();
    final eventsAsync = userId.isNotEmpty
        ? ref.watch(organizerEventsProvider(userId))
        : const AsyncValue<List<EventModel>>.data([]);

    final analytics = analyticsState.analytics;
    final events = eventsAsync.valueOrNull ?? <EventModel>[];
    final totalBooths = events.fold<int>(0, (sum, e) => sum + e.boothCount);

    final upcomingEvents = events
        .where((e) => e.isUpcoming)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    String _formatRevenue(double revenue) {
      if (revenue >= 1000000) return '\$${(revenue / 1000000).toStringAsFixed(1)}M';
      if (revenue >= 1000) return '\$${(revenue / 1000).toStringAsFixed(0)}k';
      return '\$${revenue.toStringAsFixed(0)}';
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.organizerColor,
                    AppColors.organizerColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: currentUser?.profileImage != null
                        ? NetworkImage(currentUser.profileImage)
                        : null,
                    child: currentUser?.profileImage == null
                        ? Text(
                            currentUser?.name.isNotEmpty == true
                                ? currentUser.name[0].toUpperCase()
                                : 'O',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          currentUser?.name ?? 'Organizer',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'New Event',
                    color: AppColors.organizerColor,
                    onTap: () => context.push(AppRoutes.organizerCreateExhibition),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan Entry',
                    color: AppColors.secondary,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.handshake_outlined,
                    label: 'Suppliers',
                    color: AppColors.info,
                    onTap: () => context.push(AppRoutes.organizerSuppliers),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Stats Grid
            const Text(
              'Overview',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            analyticsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _StatCard(
                        title: 'Active Events',
                        value: '${analytics?.activeEvents ?? 0}',
                        icon: Icons.event,
                        color: AppColors.organizerColor,
                      ),
                      _StatCard(
                        title: 'Total Booths',
                        value: '$totalBooths',
                        icon: Icons.grid_view,
                        color: AppColors.info,
                      ),
                      _StatCard(
                        title: 'Bookings',
                        value: '${analytics?.totalBookings ?? 0}',
                        icon: Icons.bookmark,
                        color: AppColors.success,
                      ),
                      _StatCard(
                        title: 'Revenue',
                        value: _formatRevenue(analytics?.totalRevenue ?? 0),
                        icon: Icons.trending_up,
                        color: AppColors.warning,
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            // Upcoming Events
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (eventsAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (upcomingEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No upcoming events',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                ),
              )
            else
              ...upcomingEvents.take(3).map((e) {
                final dateStr =
                    '${DateFormat('MMM d').format(e.startDate)} – ${DateFormat('MMM d, yyyy').format(e.endDate)}';
                return _EventItem(
                  title: e.title,
                  date: dateStr,
                  booths: '${e.boothCount} booths',
                  progress: 0,
                );
              }),
            const SizedBox(height: 100), // Space for nav
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventItem extends StatelessWidget {
  final String title;
  final String date;
  final String booths;
  final double progress;

  const _EventItem({
    required this.title,
    required this.date,
    required this.booths,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey600),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.grey800,
                    valueColor: AlwaysStoppedAnimation(
                      progress > 0.7 ? AppColors.success : AppColors.organizerColor,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                booths,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Events Tab
class _EventsTab extends ConsumerWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    if (currentUser == null) {
      return const Center(child: LoadingWidget());
    }

    final eventsAsync = ref.watch(organizerEventsProvider(currentUser.id));

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'My Events',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.organizerCreateExhibition),
                  icon: const Icon(Icons.add),
                  label: const Text('New Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.organizerColor,
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ],
            ),
          ),

          // Events list
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 64,
                          color: AppColors.textSecondaryDark.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No events yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first event to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.push(AppRoutes.organizerCreateExhibition),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Event'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.organizerColor,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(organizerEventsProvider(currentUser.id));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _OrganizerEventCard(event: event);
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(organizerEventsProvider(currentUser.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bookings Tab
class _BookingsTab extends ConsumerWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    if (currentUser == null) {
      return const Center(child: LoadingWidget());
    }

    // Debug log
    print('📱 Bookings Tab - User ID: ${currentUser.id}, Role: ${currentUser.role.name}');

    final state = ref.watch(organizerBookingProvider(currentUser.id));
    final notifier = ref.read(organizerBookingProvider(currentUser.id).notifier);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Booking Requests',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textSecondaryDark),
                  onPressed: () => notifier.refresh(),
                ),
              ],
            ),
          ),

          // Filter chips
          BookingFilterChips(
            selectedStatus: state.statusFilter,
            onStatusChanged: (status) => notifier.filterByStatus(status),
            pendingCount: state.pendingCount,
            approvedCount: state.approvedCount,
            rejectedCount: state.rejectedCount,
          ),

          const SizedBox(height: 16),

          // Bookings list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              child: _buildBookingsList(context, state, notifier, currentUser.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(
    BuildContext context,
    OrganizerBookingState state,
    OrganizerBookingNotifier notifier,
    String organizerId,
  ) {
    if (state.isLoading && state.bookings.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null && state.bookings.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => notifier.refresh(),
      );
    }

    if (state.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondaryDark.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              state.statusFilter != null
                  ? 'No ${state.statusFilter!.name} booking requests'
                  : 'No booking requests yet',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Booking requests will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMutedDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.bookings.length,
      itemBuilder: (context, index) {
        final booking = state.bookings[index];
        return BookingRequestCard(
          booking: booking,
          isLoading: state.isApproving || state.isRejecting,
          onApprove: () async {
            final success = await notifier.approveBooking(booking.id);
            if (context.mounted && success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking approved successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          onReject: () => _showRejectDialog(context, booking, notifier),
          onViewDetails: () => _showBookingDetails(context, booking, organizerId),
        );
      },
    );
  }

  void _showRejectDialog(
    BuildContext context,
    booking,
    OrganizerBookingNotifier notifier,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this booking request?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                hintText: 'Provide a reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await notifier.rejectBooking(
                booking.id,
                reason: reasonController.text.trim().isEmpty
                    ? null
                    : reasonController.text.trim(),
              );
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking rejected'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(
    BuildContext context,
    booking,
    String organizerId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BookingDetailSheet(
        booking: booking,
        organizerId: organizerId,
      ),
    );
  }
}

// Messages Tab
class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return const ChatsScreen();
  }
}

// Profile Tab
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.organizerColor.withOpacity(0.2),
              backgroundImage: currentUser?.profileImage != null
                  ? NetworkImage(currentUser!.profileImage!)
                  : null,
              child: currentUser?.profileImage == null
                  ? Text(
                      currentUser?.name.isNotEmpty == true
                          ? currentUser!.name[0].toUpperCase()
                          : 'O',
                      style: const TextStyle(
                        color: AppColors.organizerColor,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              currentUser?.name ?? 'Organizer',
              style: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.organizerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ORGANIZER',
                style: TextStyle(
                  color: AppColors.organizerColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _ProfileMenuItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            _ProfileMenuItem(
              icon: Icons.business,
              title: 'Organization Settings',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: AppColors.error,
              titleColor: AppColors.error,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: AppColors.surfaceDark,
                    title: const Text('Logout', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(color: AppColors.textSecondaryDark),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(authNotifierProvider);
                          return TextButton(
                            onPressed: authState.isLoading
                                ? null
                                : () async {
                                    await ref.read(authNotifierProvider.notifier).signOut();
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                  },
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                                    ),
                                  )
                                : const Text('Logout', style: TextStyle(color: AppColors.error)),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey800),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.textSecondaryDark),
        title: Text(
          title,
          style: TextStyle(color: titleColor ?? AppColors.textPrimaryDark),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey600),
        onTap: onTap,
      ),
    );
  }
}

// Organizer Event Card
class _OrganizerEventCard extends StatelessWidget {
  final dynamic event;

  const _OrganizerEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final startDate = dateFormat.format(event.startDate);
    final endDate = dateFormat.format(event.endDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image or placeholder
          if (event.images != null && event.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                event.images.first,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              ),
            )
          else
            _buildImagePlaceholder(),

          // Event details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  event.title,
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Date range
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondaryDark),
                    const SizedBox(width: 8),
                    Text(
                      '$startDate - $endDate',
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.textSecondaryDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.storefront,
                      label: '${event.boothCount} Booths',
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.favorite,
                      label: '${event.interestedCount} Interested',
                      color: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push('/events/${event.id}');
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondaryDark,
                          side: const BorderSide(color: AppColors.grey700),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/organizer/events/${event.id}/manage-booths');
                        },
                        icon: const Icon(Icons.grid_view, size: 18),
                        label: const Text('Manage Booths'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.organizerColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.grey800,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Icon(
          Icons.event,
          size: 64,
          color: AppColors.grey600,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
