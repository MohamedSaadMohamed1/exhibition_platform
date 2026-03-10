import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
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
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Events'),
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
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == state.events.length) {
                if (state.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return null;
              }

              return _EventListItem(
                event: state.events[index],
                onTap: () => context.push(
                  AppRoutes.eventDetail.replaceFirst(
                    ':eventId',
                    state.events[index].id,
                  ),
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
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(16),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.category!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.startDate.toShortDate(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
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
