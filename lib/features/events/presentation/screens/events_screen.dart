import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../router/routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/events_provider.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(eventsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull
        ?? ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
                onTap: () => context.push(AppRoutes.profile),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.chat),
                    SizedBox(width: 8),
                    Text('Chats'),
                  ],
                ),
                onTap: () => context.push(AppRoutes.chats),
              ),
              if (currentUser?.canBookBooths ?? false)
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.bookmark),
                      SizedBox(width: 8),
                      Text('My Bookings'),
                    ],
                  ),
                  onTap: () => context.push(AppRoutes.myBookings),
                ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: AppColors.error)),
                  ],
                ),
                onTap: () {
                  ref.read(authNotifierProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(eventsNotifierProvider.notifier).refresh(),
        child: _buildBody(eventsState),
      ),
    );
  }

  Widget _buildBody(EventsState state) {
    if (state.isLoading && state.events.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null && state.events.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(eventsNotifierProvider.notifier).refresh(),
      );
    }

    if (state.events.isEmpty) {
      return const EmptyStateWidget(
        title: 'No events found',
        subtitle: 'Check back later for upcoming events',
        icon: Icons.event_busy,
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Featured Events (First 3)
        if (state.events.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Featured Events',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg.w),
                itemCount: state.events.take(3).length,
                itemBuilder: (context, index) {
                  return _FeaturedEventCard(
                    event: state.events[index],
                    onTap: () => context.push(
                      AppRoutes.eventDetail.replaceFirst(
                        ':eventId',
                        state.events[index].id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        // All Events
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'All Events',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        if (context.isTablet)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppDimensions.gridColumnsTablet,
                crossAxisSpacing: AppDimensions.gridSpacing,
                mainAxisSpacing: AppDimensions.gridSpacing,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _EventListItem(
                  event: state.events[index],
                  onTap: () => context.push(
                    AppRoutes.eventDetail.replaceFirst(':eventId', state.events[index].id),
                  ),
                ),
                childCount: state.events.length,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == state.events.length) {
                  if (state.hasMore) {
                    return Padding(
                      padding: EdgeInsets.all(AppDimensions.spacingLg.r),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  return null;
                }

                return _EventListItem(
                  event: state.events[index],
                  onTap: () => context.push(
                    AppRoutes.eventDetail.replaceFirst(':eventId', state.events[index].id),
                  ),
                );
              },
              childCount: state.events.length + (state.hasMore ? 1 : 0),
            ),
          ),
      ],
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _FeaturedEventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width >= 600 ? 360.w : 280.w,
        margin: EdgeInsets.only(right: AppDimensions.spacingLg.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: event.coverImage != null
              ? DecorationImage(
                  image: NetworkImage(event.coverImage!),
                  fit: BoxFit.cover,
                )
              : null,
          color: AppColors.grey200,
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(AppDimensions.spacingLg.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.category != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        event.category!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  SizedBox(height: AppDimensions.spacingSm.h),
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14.r, color: Colors.white70),
                      SizedBox(width: 4.w),
                      Text(
                        event.startDate.toShortDate(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.location_on, size: 14.r, color: Colors.white70),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          event.location,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _EventListItem({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg.w, vertical: 6.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 80.r,
                  height: 80.r,
                  color: AppColors.grey200,
                  child: event.coverImage != null
                      ? Image.network(
                          event.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.event,
                            color: AppColors.grey400,
                          ),
                        )
                      : const Icon(
                          Icons.event,
                          color: AppColors.grey400,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.category != null) ...[
                      Text(
                        event.category!,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.startDate.toShortDate(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Interested count
              Column(
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppColors.error,
                    size: 20,
                  ),
                  Text(
                    '${event.interestedCount}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
