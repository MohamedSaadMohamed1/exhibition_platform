import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/job_model.dart';
import '../../../../router/routes.dart';
import '../../../events/presentation/providers/events_provider.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';
import '../../../jobs/presentation/providers/job_provider.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/event_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_tabs.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentNavIndex = 0;
  String _selectedLocation = 'Kuwait';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Set status bar style for dark theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        // Home - already here
        break;
      case 1:
        // Favorites/Interested
        context.push(AppRoutes.interestedEvents);
        break;
      case 2:
        // Search
        _showSearchSheet();
        break;
      case 3:
        // Profile
        context.push(AppRoutes.profile);
        break;
    }
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _SearchSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Status bar padding
              SizedBox(height: MediaQuery.of(context).padding.top),

              // Header with location and icons
              HomeHeader(
                location: _selectedLocation,
                onLocationTap: () => _showLocationPicker(),
                onSearchTap: _showSearchSheet,
                onNotificationTap: () => context.push(AppRoutes.notifications),
              ),

              // Tab Bar
              HomeTabs(
                controller: _tabController,
                onTabChanged: (index) {
                  // Handle tab changes
                },
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    // Exhibitions Tab
                    _ExhibitionsTab(),
                    // Suppliers Tab
                    _SuppliersTab(),
                    // Event Jobs Tab
                    _EventJobsTab(),
                  ],
                ),
              ),
            ],
          ),

          // Floating Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNav(
              currentIndex: _currentNavIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Location',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...['Kuwait', 'Dubai', 'Riyadh', 'Doha', 'All Locations'].map(
              (location) => ListTile(
                title: Text(
                  location,
                  style: TextStyle(
                    color: _selectedLocation == location
                        ? AppColors.primary
                        : AppColors.textPrimaryDark,
                  ),
                ),
                trailing: _selectedLocation == location
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLocation = location);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Exhibitions Tab Content - Using Real Data
class _ExhibitionsTab extends ConsumerWidget {
  const _ExhibitionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingEventsAsync = ref.watch(upcomingEventsProvider);
    final eventsState = ref.watch(eventsNotifierProvider);

    return upcomingEventsAsync.when(
      data: (upcomingEvents) {
        if (upcomingEvents.isEmpty && eventsState.events.isEmpty) {
          return const EmptyStateWidget(
            title: 'No exhibitions found',
            subtitle: 'Check back later for upcoming events',
            icon: Icons.event,
          );
        }

        final displayEvents = upcomingEvents.isNotEmpty
            ? upcomingEvents
            : eventsState.events;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(upcomingEventsProvider);
            await ref.read(eventsNotifierProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Exhibitions',
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.events),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Date indicator
                if (displayEvents.isNotEmpty)
                  _DateIndicator(date: displayEvents.first.startDate),
                const SizedBox(height: 16),
                // Events List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayEvents.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        event: displayEvents[index],
                        onTap: () => context.push(
                          AppRoutes.eventDetail.replaceFirst(
                            ':eventId',
                            displayEvents[index].id,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, _) => AppErrorWidget(
        message: 'Failed to load exhibitions',
        onRetry: () => ref.invalidate(upcomingEventsProvider),
      ),
    );
  }
}

// Date Indicator Widget
class _DateIndicator extends StatelessWidget {
  final DateTime date;

  const _DateIndicator({required this.date});

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = _getDayOfWeek(date.weekday);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${date.day} ${_getMonth(date.month)} ',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: dayOfWeek,
            style: const TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayOfWeek(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}

// Suppliers Tab - Using Real Data
class _SuppliersTab extends ConsumerWidget {
  const _SuppliersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersState = ref.watch(suppliersNotifierProvider);
    final featuredSuppliersAsync = ref.watch(featuredSuppliersProvider);

    return featuredSuppliersAsync.when(
      data: (featuredSuppliers) {
        final displaySuppliers = featuredSuppliers.isNotEmpty
            ? featuredSuppliers
            : suppliersState.suppliers;

        if (displaySuppliers.isEmpty && !suppliersState.isLoading) {
          return EmptyStateWidget(
            title: 'No suppliers found',
            subtitle: 'Check back later for suppliers',
            icon: Icons.store,
            action: TextButton(
              onPressed: () => context.push(AppRoutes.suppliers),
              child: const Text('Browse All Suppliers'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(featuredSuppliersProvider);
            await ref.read(suppliersNotifierProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Suppliers',
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.suppliers),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displaySuppliers.take(5).length,
                  itemBuilder: (context, index) {
                    final supplier = displaySuppliers[index];
                    return _SupplierCard(
                      supplier: supplier,
                      onTap: () => context.push('/suppliers/${supplier.id}'),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, _) => AppErrorWidget(
        message: 'Failed to load suppliers',
        onRetry: () => ref.invalidate(featuredSuppliersProvider),
      ),
    );
  }
}

// Supplier Card Widget
class _SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final VoidCallback onTap;

  const _SupplierCard({
    required this.supplier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Supplier Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.grey700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: supplier.coverImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        supplier.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.store,
                          color: AppColors.grey500,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.store,
                      color: AppColors.grey500,
                    ),
            ),
            const SizedBox(width: 16),
            // Supplier Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          supplier.name,
                          style: const TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (supplier.isVerified)
                        const Icon(
                          Icons.verified,
                          color: AppColors.success,
                          size: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (supplier.services.isNotEmpty)
                    Text(
                      supplier.services.take(2).join(' • '),
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        supplier.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${supplier.reviewCount})',
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
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

// Event Jobs Tab - Using Real Data
class _EventJobsTab extends ConsumerWidget {
  const _EventJobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsState = ref.watch(jobsNotifierProvider);

    if (jobsState.isLoading && jobsState.jobs.isEmpty) {
      return const LoadingWidget();
    }

    if (jobsState.errorMessage != null && jobsState.jobs.isEmpty) {
      return AppErrorWidget(
        message: jobsState.errorMessage!,
        onRetry: () => ref.read(jobsNotifierProvider.notifier).refresh(),
      );
    }

    if (jobsState.jobs.isEmpty) {
      return EmptyStateWidget(
        title: 'No jobs available',
        subtitle: 'Check back later for new opportunities',
        icon: Icons.work_outline,
        action: TextButton(
          onPressed: () => context.push(AppRoutes.jobs),
          child: const Text('Browse All Jobs'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(jobsNotifierProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Event Jobs',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.jobs),
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jobsState.jobs.take(5).length,
              itemBuilder: (context, index) {
                final job = jobsState.jobs[index];
                return _JobCard(
                  job: job,
                  onTap: () => context.push('/jobs/${job.id}'),
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

// Job Card Widget
class _JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (job.eventTitle != null)
                        Text(
                          job.eventTitle!,
                          style: const TextStyle(
                            color: AppColors.textSecondaryDark,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: job.isAcceptingApplications
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.grey600.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.isAcceptingApplications ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: job.isAcceptingApplications
                          ? AppColors.success
                          : AppColors.textMutedDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (job.jobType != null) ...[
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.textSecondaryDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.jobType!,
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (job.location != null) ...[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textSecondaryDark,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.location!,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (job.salary != null) ...[
              const SizedBox(height: 8),
              Text(
                job.salary!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${job.applicationsCount} applicants',
                  style: const TextStyle(
                    color: AppColors.textMutedDark,
                    fontSize: 12,
                  ),
                ),
                if (job.isAcceptingApplications)
                  Text(
                    '${job.daysUntilDeadline} days left',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Search Sheet
class _SearchSheet extends StatelessWidget {
  const _SearchSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Search field
              TextField(
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'Search exhibitions, suppliers...',
                  hintStyle: const TextStyle(color: AppColors.textMutedDark),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMutedDark),
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (query) {
                  Navigator.pop(context);
                  if (query.isNotEmpty) {
                    context.push('${AppRoutes.events}?search=$query');
                  }
                },
              ),
              const SizedBox(height: 24),
              // Quick Links
              const Text(
                'Quick Links',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickLinkChip(
                    label: 'Events',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.events);
                    },
                  ),
                  _QuickLinkChip(
                    label: 'Suppliers',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.suppliers);
                    },
                  ),
                  _QuickLinkChip(
                    label: 'Services',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.services);
                    },
                  ),
                  _QuickLinkChip(
                    label: 'Jobs',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.jobs);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Searches',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              // Recent searches placeholder
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: const [
                    _SearchHistoryItem(query: 'Tech Summit'),
                    _SearchHistoryItem(query: 'Food Exhibition'),
                    _SearchHistoryItem(query: 'Art Gallery'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickLinkChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickLinkChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SearchHistoryItem extends StatelessWidget {
  final String query;

  const _SearchHistoryItem({required this.query});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history, color: AppColors.textMutedDark),
      title: Text(
        query,
        style: const TextStyle(color: AppColors.textPrimaryDark),
      ),
      trailing: const Icon(Icons.north_west, color: AppColors.textMutedDark, size: 16),
      onTap: () {
        Navigator.pop(context);
        context.push('${AppRoutes.events}?search=$query');
      },
    );
  }
}
