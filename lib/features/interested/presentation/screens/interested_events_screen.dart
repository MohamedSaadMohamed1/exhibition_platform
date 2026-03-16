import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../router/routes.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../home/presentation/widgets/event_card.dart';
import '../../../events/presentation/providers/events_provider.dart';

/// Provider for fetching interested events
final interestedEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(eventRepositoryProvider);
  final result = await repository.getInterestedEvents(userId);
  return result.fold((l) => [], (r) => r);
});

class InterestedEventsScreen extends ConsumerWidget {
  const InterestedEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final interestedEventsAsync = ref.watch(interestedEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Interested Events',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: userId == null
          ? _buildLoginRequired()
          : interestedEventsAsync.when(
              data: (interestedEvents) {
                if (interestedEvents.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(interestedEventsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: interestedEvents.length,
                    itemBuilder: (context, index) {
                      final event = interestedEvents[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EventCard(
                          event: event,
                          onTap: () => context.push(
                            AppRoutes.eventDetail.replaceFirst(
                              ':eventId',
                              event.id,
                            ),
                          ),
                          onInterestTap: () async {
                            // Remove from interested
                            await ref.read(eventRepositoryProvider).toggleInterest(
                              eventId: event.id,
                              userId: userId,
                            );
                            // Refresh all related providers for cross-screen sync
                            ref.invalidate(interestedEventsProvider);
                            ref.invalidate(upcomingEventsProvider);
                            ref.invalidate(isUserInterestedProvider((eventId: event.id, userId: userId)));
                            ref.invalidate(eventDetailProvider(event.id));
                            // For NotifierProvider, call refresh explicitly
                            ref.read(eventsNotifierProvider.notifier).refresh();
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, _) => AppErrorWidget(
                message: 'Failed to load interested events',
                onRetry: () => ref.invalidate(interestedEventsProvider),
              ),
            ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 48,
              color: AppColors.textMutedDark,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Please login to view interested events',
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 48,
              color: AppColors.textMutedDark,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No interested events yet',
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse exhibitions and mark the ones you\'re interested in',
            style: TextStyle(
              color: AppColors.textMutedDark,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
