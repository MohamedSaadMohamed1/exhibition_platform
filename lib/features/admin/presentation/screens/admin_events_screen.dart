import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/routes.dart';
import '../../../../shared/models/event_model.dart';
import '../providers/admin_events_provider.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'All Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(
            selected: state.statusFilter,
            onSelected: (status) =>
                ref.read(adminEventsProvider.notifier).filterByStatus(status),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? _ErrorView(
                        message: state.errorMessage!,
                        onRetry: () =>
                            ref.read(adminEventsProvider.notifier).refresh(),
                      )
                    : state.events.isEmpty
                        ? const _EmptyView(message: 'No events found')
                        : RefreshIndicator(
                            onRefresh: () =>
                                ref.read(adminEventsProvider.notifier).refresh(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.events.length,
                              itemBuilder: (context, index) => _EventCard(
                                event: state.events[index],
                                screenContext: context,
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final EventStatus? selected;
  final void Function(EventStatus?) onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      null,
      EventStatus.published,
      EventStatus.draft,
      EventStatus.cancelled,
      EventStatus.completed,
    ];

    final labels = {
      null: 'All',
      EventStatus.published: 'Published',
      EventStatus.draft: 'Draft',
      EventStatus.cancelled: 'Cancelled',
      EventStatus.completed: 'Completed',
    };

    return Container(
      color: AppColors.surfaceDark,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: statuses.length,
        itemBuilder: (context, i) {
          final status = statuses[i];
          final label = labels[status]!;
          final isSelected = selected == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelected(status),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.backgroundDark,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final BuildContext screenContext;

  const _EventCard({required this.event, required this.screenContext});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(event.status);

    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(event.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.adminColor, size: 20),
                  tooltip: 'Edit Event',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    screenContext.push(
                      AppRoutes.adminEditEvent.replaceFirst(
                        ':eventId',
                        event.id,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: event.location,
            ),
            if (event.organizerName != null)
              _InfoRow(
                icon: Icons.business_outlined,
                label: 'Organizer',
                value: event.organizerName!,
              ),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Start',
              value:
                  '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
            ),
            _InfoRow(
              icon: Icons.store_mall_directory_outlined,
              label: 'Booths',
              value: event.boothCount.toString(),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(EventStatus status) {
    switch (status) {
      case EventStatus.published:
        return 'Published';
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.completed:
        return 'Completed';
    }
  }

  Color _statusColor(EventStatus status) {
    switch (status) {
      case EventStatus.published:
        return Colors.green;
      case EventStatus.draft:
        return Colors.orange;
      case EventStatus.cancelled:
        return Colors.red;
      case EventStatus.completed:
        return Colors.blue;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryDark),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 64, color: AppColors.grey600),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style:
                TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
