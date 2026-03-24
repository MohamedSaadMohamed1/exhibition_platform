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
import '../../../../shared/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    switch (index) {
      case 0:
        // Home - already here, just ensure index is 0
        setState(() => _currentNavIndex = 0);
        break;
      case 1:
        // Favorites/Interested - navigate without changing index
        context.push(AppRoutes.interestedEvents);
        break;
      case 2:
        // Search - show sheet without changing index
        _showSearchSheet();
        break;
      case 3:
        // Profile - navigate without changing index
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
class _ExhibitionsTab extends ConsumerStatefulWidget {
  const _ExhibitionsTab();

  @override
  ConsumerState<_ExhibitionsTab> createState() => _ExhibitionsTabState();
}

class _ExhibitionsTabState extends ConsumerState<_ExhibitionsTab> {
  final Set<String> _bookmarkedEvents = {};

  Future<void> _toggleInterest(String eventId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to mark interest'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final result = await ref.read(eventRepositoryProvider).toggleInterest(
      eventId: eventId,
      userId: userId,
    );

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (isInterested) {
        // Refresh the events to show updated count
        ref.invalidate(upcomingEventsProvider);
        // For NotifierProvider, we need to call refresh() method
        ref.read(eventsNotifierProvider.notifier).refresh();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isInterested ? 'Added to interested' : 'Removed from interested',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  void _toggleBookmark(String eventId) {
    setState(() {
      if (_bookmarkedEvents.contains(eventId)) {
        _bookmarkedEvents.remove(eventId);
      } else {
        _bookmarkedEvents.add(eventId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    final event = displayEvents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        event: event,
                        isBookmarked: _bookmarkedEvents.contains(event.id),
                        onTap: () => context.push(
                          AppRoutes.eventDetail.replaceFirst(
                            ':eventId',
                            event.id,
                          ),
                        ),
                        onInterestTap: () => _toggleInterest(event.id),
                        onBookmarkTap: () => _toggleBookmark(event.id),
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
class _SuppliersTab extends ConsumerStatefulWidget {
  const _SuppliersTab();

  @override
  ConsumerState<_SuppliersTab> createState() => _SuppliersTabState();
}

class _SuppliersTabState extends ConsumerState<_SuppliersTab> {
  String _selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  final List<String> _categories = [
    'All',
    'Booth Design',
    'Catering',
    'Lighting',
    'Printing',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(suppliersNotifierProvider.notifier).loadMore();
    }
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    
    setState(() {
      _selectedCategory = category;
    });

    if (category == 'All') {
      ref.read(suppliersNotifierProvider.notifier).clearFilter();
    } else {
      ref.read(suppliersNotifierProvider.notifier).applyFilter(
            SupplierFilter(category: category),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersState = ref.watch(suppliersNotifierProvider);
    final displaySuppliers = suppliersState.suppliers;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(suppliersNotifierProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Title
            const Text(
              'Explore Suppliers',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Category Filter Tabs with underline
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: GestureDetector(
                      onTap: () => _onCategorySelected(category),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textSecondaryDark,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Underline indicator
                          Container(
                            height: 2,
                            width: isSelected ? 24 : 0,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimaryDark,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Suppliers List
            if (displaySuppliers.isEmpty && !suppliersState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No suppliers found in this category',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displaySuppliers.length,
                itemBuilder: (context, index) {
                  final supplier = displaySuppliers[index];
                  return _SupplierCard(
                    supplier: supplier,
                    onTap: () => context.push('/suppliers/${supplier.id}'),
                  );
                },
              ),
            if (suppliersState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// Supplier Card Widget - New Vertical Design
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
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Logo Overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Image with top rounded corners
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: AppColors.grey800,
                    child: supplier.coverImage != null
                        ? Image.network(
                            supplier.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.store,
                                size: 48,
                                color: AppColors.grey600,
                              ),
                            ),
                          )
                        : supplier.images.isNotEmpty
                            ? Image.network(
                                supplier.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.store,
                                    size: 48,
                                    color: AppColors.grey600,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.store,
                                  size: 48,
                                  color: AppColors.grey600,
                                ),
                              ),
                  ),
                ),
                // Logo Overlay - positioned at bottom-left, overlapping edge
                Positioned(
                  left: 16,
                  bottom: -35,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: supplier.images.length > 1
                          ? Image.network(
                              supplier.images[1],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  supplier.name.isNotEmpty
                                      ? supplier.name[0].toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                supplier.name.isNotEmpty
                                    ? supplier.name[0].toUpperCase()
                                    : 'S',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            // Supplier Info - with top padding to account for logo overlap
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 45, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    supplier.name,
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Rating and Reviews
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFE91E63), // Pink color like in design
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${supplier.reviewCount} reviews)',
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Description/Category
                  if (supplier.description != null &&
                      supplier.description!.isNotEmpty)
                    Text(
                      supplier.description!,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (supplier.category != null)
                    Text(
                      supplier.category!,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),
                  // Service Tags
                  if (supplier.services.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: supplier.services.take(2).map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.grey600,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            service,
                            style: const TextStyle(
                              color: AppColors.textPrimaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Event Jobs Tab - New Promotional Design
class _EventJobsTab extends StatelessWidget {
  const _EventJobsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Promotional Job Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Image with "We are Hiring" text
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.cardDark,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern or image placeholder
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topRight,
                              radius: 1.2,
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // "We are Hiring" text
                      Positioned(
                        left: 24,
                        top: 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'We',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              'are',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [AppColors.primary, Color(0xFF9C27B0)],
                              ).createShader(bounds),
                              child: const Text(
                                'Hiring',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Megaphone icon placeholder
                      Positioned(
                        right: -20,
                        top: 20,
                        child: Icon(
                          Icons.campaign,
                          size: 180,
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
                // Job Info Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Job Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.work_outline,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Job Title and Description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'January Jobs',
                                      style: TextStyle(
                                        color: AppColors.textPrimaryDark,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardDark,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '12 Jobs',
                                        style: TextStyle(
                                          color: AppColors.textPrimaryDark,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Various job opportunities at this month's exhibition",
                                  style: TextStyle(
                                    color: AppColors.textSecondaryDark,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Deadline
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.primary.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Deadline: January 15, 2026',
                            style: TextStyle(
                              color: AppColors.primary.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Apply Now Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showJobApplicationForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Apply Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showJobApplicationForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _JobApplicationFormSheet(),
    );
  }
}

// Job Application Form Sheet
class _JobApplicationFormSheet extends ConsumerStatefulWidget {
  const _JobApplicationFormSheet();

  @override
  ConsumerState<_JobApplicationFormSheet> createState() =>
      _JobApplicationFormSheetState();
}

class _JobApplicationFormSheetState
    extends ConsumerState<_JobApplicationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Save directly to Firestore job_applications collection
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('job_applications').doc();

      await docRef.set({
        'id': docRef.id,
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'position': _positionController.text.trim(),
        'coverLetter': _commentController.text.trim(),
        'status': 'pending',
        'source': 'event_jobs_tab',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Job Application',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.grey700, height: 1),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Position
                    _buildTextField(
                      controller: _positionController,
                      label: 'Position Applied For',
                      hint: 'Enter the position you are applying for',
                      icon: Icons.work_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the position';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Comment / Cover Letter
                    _buildTextField(
                      controller: _commentController,
                      label: 'Cover Letter / Comments',
                      hint: 'Tell us about yourself and why you are interested',
                      icon: Icons.message_outlined,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 32),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.5),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Submit Application',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimaryDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMutedDark),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: AppColors.textSecondaryDark)
                : null,
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 0,
            ),
          ),
          validator: validator,
        ),
      ],
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
