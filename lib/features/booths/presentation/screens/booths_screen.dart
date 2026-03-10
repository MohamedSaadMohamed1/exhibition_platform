import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/models/booth_model.dart';
import '../../../../shared/providers/providers.dart';

class BoothsScreen extends ConsumerStatefulWidget {
  final String eventId;

  const BoothsScreen({super.key, required this.eventId});

  @override
  ConsumerState<BoothsScreen> createState() => _BoothsScreenState();
}

class _BoothsScreenState extends ConsumerState<BoothsScreen> {
  BoothFilter _filter = const BoothFilter();
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final boothsStream = ref.watch(boothsStreamProvider(widget.eventId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Booth'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_filter.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Filters: '),
                  const SizedBox(width: 8),
                  if (_filter.showOnlyAvailable)
                    _FilterChip(
                      label: 'Available',
                      onRemove: () {
                        setState(() {
                          _filter = _filter.copyWith(showOnlyAvailable: false);
                        });
                      },
                    ),
                  if (_filter.size != null)
                    _FilterChip(
                      label: _filter.size!.displayName,
                      onRemove: () {
                        setState(() {
                          _filter = BoothFilter(
                            showOnlyAvailable: _filter.showOnlyAvailable,
                          );
                        });
                      },
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() => _filter = const BoothFilter());
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          // Legend
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(
                  color: AppColors.boothAvailable,
                  label: 'Available',
                ),
                _LegendItem(
                  color: AppColors.boothReserved,
                  label: 'Reserved',
                ),
                _LegendItem(
                  color: AppColors.boothBooked,
                  label: 'Booked',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Booths list/grid
          Expanded(
            child: boothsStream.when(
              data: (booths) {
                final filteredBooths = booths
                    .where((booth) => _filter.matches(booth))
                    .toList();

                if (filteredBooths.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'No booths found',
                    subtitle: 'Try adjusting your filters',
                    icon: Icons.grid_off,
                  );
                }

                return _isGridView
                    ? _buildGridView(filteredBooths, currentUser?.id)
                    : _buildListView(filteredBooths, currentUser?.id);
              },
              loading: () => const LoadingWidget(),
              error: (error, _) => AppErrorWidget(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<BoothModel> booths, String? userId) {
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
        return _BoothGridItem(
          booth: booth,
          isOwn: booth.reservedBy == userId || booth.bookedBy == userId,
          onTap: () => _showBoothDetails(booth),
        );
      },
    );
  }

  Widget _buildListView(List<BoothModel> booths, String? userId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: booths.length,
      itemBuilder: (context, index) {
        final booth = booths[index];
        return _BoothListItem(
          booth: booth,
          isOwn: booth.reservedBy == userId || booth.bookedBy == userId,
          onTap: () => _showBoothDetails(booth),
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(
        currentFilter: _filter,
        onApply: (filter) {
          setState(() => _filter = filter);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showBoothDetails(BoothModel booth) {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final canBook = currentUser?.canBookBooths ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booth.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.storefront,
                    color: _getStatusColor(booth.status),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booth ${booth.boothNumber}',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        booth.sizeDisplayText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booth.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booth.status.value.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(booth.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price'),
                Text(
                  '\$${booth.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 32),
            // Amenities
            if (booth.amenities.isNotEmpty) ...[
              Text(
                'Amenities',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: booth.amenities
                    .map((a) => Chip(
                          label: Text(a, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppColors.grey100,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            // Book Button
            if (booth.isAvailable && canBook)
              AppButton(
                text: 'Book This Booth',
                onPressed: () => _bookBooth(booth),
              )
            else if (booth.isReserved && booth.reservedBy == currentUser?.id)
              AppButton(
                text: 'Complete Booking',
                onPressed: () {
                  // Navigate to booking completion
                },
              )
            else if (!booth.isAvailable)
              AppButton(
                text: 'Not Available',
                style: AppButtonStyle.outline,
                onPressed: null,
              ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _bookBooth(BoothModel booth) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    Navigator.pop(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ref.read(bookingRepositoryProvider).createBookingRequest(
          eventId: widget.eventId,
          boothId: booth.id,
          exhibitorId: currentUser.id,
          organizerId: '', // Will be fetched from event
          totalPrice: booth.price,
        );

    Navigator.pop(context); // Close loading

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (booking) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  Color _getStatusColor(BoothStatus status) {
    switch (status) {
      case BoothStatus.available:
        return AppColors.boothAvailable;
      case BoothStatus.reserved:
        return AppColors.boothReserved;
      case BoothStatus.booked:
      case BoothStatus.occupied:
        return AppColors.boothBooked;
    }
  }
}

// Provider for booths stream
final boothsStreamProvider =
    StreamProvider.family<List<BoothModel>, String>((ref, eventId) {
  final repository = ref.watch(boothRepositoryProvider);
  return repository.watchBooths(eventId);
});

class _BoothGridItem extends StatelessWidget {
  final BoothModel booth;
  final bool isOwn;
  final VoidCallback onTap;

  const _BoothGridItem({
    required this.booth,
    required this.isOwn,
    required this.onTap,
  });

  Color get _color {
    if (isOwn) return AppColors.primary;
    switch (booth.status) {
      case BoothStatus.available:
        return AppColors.boothAvailable;
      case BoothStatus.reserved:
        return AppColors.boothReserved;
      case BoothStatus.booked:
      case BoothStatus.occupied:
        return AppColors.boothBooked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _color.withOpacity(0.2),
          border: Border.all(color: _color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            booth.boothNumber,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _BoothListItem extends StatelessWidget {
  final BoothModel booth;
  final bool isOwn;
  final VoidCallback onTap;

  const _BoothListItem({
    required this.booth,
    required this.isOwn,
    required this.onTap,
  });

  Color get _color {
    if (isOwn) return AppColors.primary;
    switch (booth.status) {
      case BoothStatus.available:
        return AppColors.boothAvailable;
      case BoothStatus.reserved:
        return AppColors.boothReserved;
      case BoothStatus.booked:
      case BoothStatus.occupied:
        return AppColors.boothBooked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              booth.boothNumber,
              style: TextStyle(
                color: _color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text('Booth ${booth.boothNumber}'),
        subtitle: Text(booth.sizeDisplayText),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${booth.price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                booth.status.value,
                style: TextStyle(
                  color: _color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
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
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final BoothFilter currentFilter;
  final Function(BoothFilter) onApply;

  const _FilterSheet({
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late BoothFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Booths',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          // Show only available
          SwitchListTile(
            title: const Text('Show only available'),
            value: _filter.showOnlyAvailable,
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(showOnlyAvailable: value);
              });
            },
          ),
          const SizedBox(height: 16),
          // Size filter
          Text(
            'Size',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: BoothSize.values.map((size) {
              return ChoiceChip(
                label: Text(size.displayName),
                selected: _filter.size == size,
                onSelected: (selected) {
                  setState(() {
                    _filter = _filter.copyWith(
                      size: selected ? size : null,
                    );
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Apply Filters',
            onPressed: () => widget.onApply(_filter),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
