import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../router/routes.dart';
import '../providers/events_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const AppErrorWidget(message: 'Event not found');
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                backgroundColor: AppColors.surfaceDark,
                expandedHeight: 250,
                pinned: true,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: event.coverImage != null
                      ? Image.network(
                          event.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.grey800,
                            child: const Icon(
                              Icons.event,
                              size: 64,
                              color: AppColors.grey600,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.grey800,
                          child: const Icon(
                            Icons.event,
                            size: 64,
                            color: AppColors.grey600,
                          ),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Share event
                    },
                  ),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Status
                      Row(
                        children: [
                          if (event.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                event.category!,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${event.interestedCount} interested',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryDark,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        event.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 16),
                      // Date & Location
                      _InfoRow(
                        icon: Icons.calendar_today,
                        title: 'Date',
                        value: DateTimeX.formatEventDateRange(
                          event.startDate,
                          event.endDate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.location_on,
                        title: 'Location',
                        value: event.address ?? event.location,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.grid_view,
                        title: 'Available Booths',
                        value: '${event.boothCount} booths',
                      ),
                      const SizedBox(height: 24),
                      // Tags
                      if (event.tags.isNotEmpty) ...[
                        Text(
                          'Tags',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.tags
                              .map((tag) => Chip(
                                    label: Text(
                                      tag,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: AppColors.surfaceDark,
                                    side: const BorderSide(color: AppColors.grey700),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Description
                      Text(
                        'About Event',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryDark,
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, _) => AppErrorWidget(message: error.toString()),
      ),
      bottomNavigationBar: eventAsync.whenOrNull(
        data: (event) {
          if (event == null) return null;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Interest Button
                  Expanded(
                    child: AppButton(
                      text: 'Interested',
                      style: AppButtonStyle.outline,
                      icon: Icons.favorite_border,
                      onPressed: () async {
                        final userId = ref.read(currentUserIdProvider);
                        if (userId != null) {
                          await ref
                              .read(eventRepositoryProvider)
                              .toggleInterest(
                                eventId: eventId,
                                userId: userId,
                              );
                          ref.invalidate(eventDetailProvider(eventId));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // View Booths Button
                  Expanded(
                    child: AppButton(
                      text: 'View Booths',
                      icon: Icons.grid_view,
                      onPressed: () => context.push(
                        AppRoutes.eventBooths.replaceFirst(':eventId', eventId),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
