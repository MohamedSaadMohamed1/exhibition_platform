import 'package:flutter/material.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/theme/app_colors.dart';

class BookingFilterChips extends StatelessWidget {
  final BookingStatus? selectedStatus;
  final Function(BookingStatus?) onStatusChanged;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;

  const BookingFilterChips({
    super.key,
    this.selectedStatus,
    required this.onStatusChanged,
    this.pendingCount = 0,
    this.approvedCount = 0,
    this.rejectedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 16),
          // All
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('All'),
                if (selectedStatus == null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ],
              ],
            ),
            selected: selectedStatus == null,
            onSelected: (selected) {
              onStatusChanged(null);
            },
            selectedColor: AppColors.primary.withOpacity(0.2),
            checkmarkColor: Colors.transparent,
          ),
          const SizedBox(width: 8),
          // Pending
          _StatusChip(
            label: 'Pending',
            count: pendingCount,
            status: BookingStatus.pending,
            selectedStatus: selectedStatus,
            onSelected: onStatusChanged,
            color: AppColors.statusPending,
          ),
          const SizedBox(width: 8),
          // Approved
          _StatusChip(
            label: 'Approved',
            count: approvedCount,
            status: BookingStatus.approved,
            selectedStatus: selectedStatus,
            onSelected: onStatusChanged,
            color: AppColors.statusApproved,
          ),
          const SizedBox(width: 8),
          // Rejected
          _StatusChip(
            label: 'Rejected',
            count: rejectedCount,
            status: BookingStatus.rejected,
            selectedStatus: selectedStatus,
            onSelected: onStatusChanged,
            color: AppColors.statusRejected,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final BookingStatus status;
  final BookingStatus? selectedStatus;
  final Function(BookingStatus?) onSelected;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.status,
    required this.selectedStatus,
    required this.onSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedStatus == status;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(selected ? status : null);
      },
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
    );
  }
}
