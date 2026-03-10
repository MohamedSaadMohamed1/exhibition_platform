import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/routes.dart';
import '../../../../shared/models/event_model.dart';
import '../../../home/presentation/widgets/event_card.dart';

class InterestedEventsScreen extends ConsumerWidget {
  const InterestedEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual interested events provider
    final List<EventModel> interestedEvents = [];

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
      body: interestedEvents.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: interestedEvents.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: EventCard(
                    event: interestedEvents[index],
                    onTap: () => context.push(
                      AppRoutes.eventDetail.replaceFirst(
                        ':eventId',
                        interestedEvents[index].id,
                      ),
                    ),
                  ),
                );
              },
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
