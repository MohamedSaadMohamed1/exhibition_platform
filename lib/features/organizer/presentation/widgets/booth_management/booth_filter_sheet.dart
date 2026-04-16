import 'package:flutter/material.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../shared/models/booth_model.dart';

class BoothFilterSheet extends StatefulWidget {
  final BoothFilter currentFilter;
  final Function(BoothFilter) onApply;

  const BoothFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<BoothFilterSheet> createState() => _BoothFilterSheetState();
}

class _BoothFilterSheetState extends State<BoothFilterSheet> {
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
      child: SingleChildScrollView(
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
            // Status filter (Organizer-specific)
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BoothStatus.values.map((status) {
                return ChoiceChip(
                  label: Text(status.value),
                  selected: _filter.status == status,
                  onSelected: (selected) {
                    setState(() {
                      _filter = _filter.copyWith(
                        status: selected ? status : null,
                      );
                    });
                  },
                  selectedColor: _getStatusColor(status).withOpacity(0.3),
                  checkmarkColor: _getStatusColor(status),
                );
              }).toList(),
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
              runSpacing: 8,
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
            const SizedBox(height: 16),
            // Price range filter
            Text(
              'Price Range',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Min Price',
                      prefixText: 'KD ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _filter.minPrice?.toStringAsFixed(0) ?? '',
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value);
                      setState(() {
                        _filter = _filter.copyWith(minPrice: price);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max Price',
                      prefixText: 'KD ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _filter.maxPrice?.toStringAsFixed(0) ?? '',
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value);
                      setState(() {
                        _filter = _filter.copyWith(maxPrice: price);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filter = const BoothFilter();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Apply Filters',
                    onPressed: () => widget.onApply(_filter),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
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
