import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/models/booth_model.dart';
import '../providers/organizer_booth_provider.dart';
import '../widgets/booth_management/booth_grid_item.dart';
import '../widgets/booth_management/booth_list_item.dart';
import '../widgets/booth_management/booth_stats_card.dart';
import '../widgets/booth_management/booth_filter_sheet.dart';
import '../widgets/booth_management/batch_create_dialog.dart';
import '../widgets/booth_management/booth_detail_sheet.dart';
import '../../../../shared/providers/providers.dart';

class ManageBoothsScreen extends ConsumerStatefulWidget {
  final String eventId;

  const ManageBoothsScreen({super.key, required this.eventId});

  @override
  ConsumerState<ManageBoothsScreen> createState() => _ManageBoothsScreenState();
}

class _ManageBoothsScreenState extends ConsumerState<ManageBoothsScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizerBoothsProvider(widget.eventId));
    final notifier = ref.read(organizerBoothsProvider(widget.eventId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Booths'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(notifier),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context, notifier),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: Column(
          children: [
            // Stats card
            if (state.stats != null)
              BoothStatsCard(stats: state.stats!),

            // Filter chips
            if (state.filter.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Filters: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (state.filter.status != null)
                              _FilterChip(
                                label: state.filter.status!.value,
                                onRemove: () {
                                  notifier.applyFilter(
                                    state.filter.copyWith(status: null),
                                  );
                                },
                              ),
                            if (state.filter.size != null)
                              _FilterChip(
                                label: state.filter.size!.displayName,
                                onRemove: () {
                                  notifier.applyFilter(
                                    state.filter.copyWith(size: null),
                                  );
                                },
                              ),
                            if (state.filter.minPrice != null || state.filter.maxPrice != null)
                              _FilterChip(
                                label: 'Price: KD ${state.filter.minPrice?.toStringAsFixed(0) ?? '0'} - KD ${state.filter.maxPrice?.toStringAsFixed(0) ?? '∞'}',
                                onRemove: () {
                                  notifier.applyFilter(
                                    state.filter.copyWith(
                                      minPrice: null,
                                      maxPrice: null,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => notifier.clearFilter(),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),

            // Booths list/grid
            Expanded(
              child: _buildBoothsView(state, notifier),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/organizer/events/${widget.eventId}/booths/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create Booth'),
        backgroundColor: AppColors.organizerColor,
      ),
    );
  }

  Widget _buildBoothsView(OrganizerBoothsState state, OrganizerBoothsNotifier notifier) {
    if (state.isLoading && state.booths.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null && state.booths.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => notifier.refresh(),
      );
    }

    if (state.booths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_off, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No booths found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              state.filter.isActive
                  ? 'Try adjusting your filters'
                  : 'Create your first booth to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/organizer/events/${widget.eventId}/booths/create'),
              icon: const Icon(Icons.add),
              label: const Text('Create Booth'),
            ),
          ],
        ),
      );
    }

    return _isGridView
        ? _buildGridView(state.booths, notifier)
        : _buildListView(state.booths, notifier);
  }

  Widget _buildGridView(List<BoothModel> booths, OrganizerBoothsNotifier notifier) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: booths.length,
      itemBuilder: (context, index) {
        final booth = booths[index];
        return BoothGridItem(
          booth: booth,
          onTap: () => _showBoothDetails(booth),
          onEdit: () => context.push(
            '/organizer/events/${widget.eventId}/booths/${booth.id}/edit',
          ),
          onDelete: () => _confirmDelete(booth, notifier),
        );
      },
    );
  }

  Widget _buildListView(List<BoothModel> booths, OrganizerBoothsNotifier notifier) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: booths.length,
      itemBuilder: (context, index) {
        final booth = booths[index];
        return BoothListItem(
          booth: booth,
          onTap: () => _showBoothDetails(booth),
          onEdit: () => context.push(
            '/organizer/events/${widget.eventId}/booths/${booth.id}/edit',
          ),
          onDelete: () => _confirmDelete(booth, notifier),
        );
      },
    );
  }

  void _showFilterSheet(OrganizerBoothsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BoothFilterSheet(
        currentFilter: ref.read(organizerBoothsProvider(widget.eventId)).filter,
        onApply: (filter) {
          notifier.applyFilter(filter);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, OrganizerBoothsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_box, color: AppColors.primary),
              title: const Text('Batch Create Booths'),
              onTap: () {
                Navigator.pop(context);
                _showBatchCreateDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: AppColors.info),
              title: const Text('Refresh'),
              onTap: () {
                Navigator.pop(context);
                notifier.refresh();
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showBatchCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => BatchCreateDialog(
        eventId: widget.eventId,
      ),
    );
  }

  void _showBoothDetails(BoothModel booth) {
    final organizerId =
        ref.read(currentUserProvider).valueOrNull?.id ?? '';
    final notifier =
        ref.read(organizerBoothsProvider(widget.eventId).notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BoothDetailSheet(
        booth: booth,
        organizerId: organizerId,
        eventId: widget.eventId,
        onStatusChanged: () => notifier.refresh(),
      ),
    );
  }

  void _confirmDelete(BoothModel booth, OrganizerBoothsNotifier notifier) {
    if (booth.isBooked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete a booked booth'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booth'),
        content: Text(
          'Are you sure you want to delete booth ${booth.boothNumber}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await notifier.deleteBooth(booth.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Booth deleted successfully'
                          : 'Failed to delete booth',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.organizerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.organizerColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.organizerColor,
            ),
          ),
        ],
      ),
    );
  }
}
