import 'package:flutter/material.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/models/booth_model.dart';

class BoothListItem extends StatelessWidget {
  final BoothModel booth;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BoothListItem({
    super.key,
    required this.booth,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color get _color {
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
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Booth number badge
              Container(
                width: 56,
                height: 56,
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
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Booth details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booth ${booth.boothNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booth.sizeDisplayText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (booth.category != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        booth.category!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              // Price and status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'KD ${booth.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.organizerColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booth.status.value,
                      style: TextStyle(
                        color: _color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              // Actions menu
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Booth ${booth.boothNumber}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Booth'),
              enabled: !booth.isBooked,
              onTap: () {
                Navigator.pop(context);
                if (booth.isBooked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot edit a booked booth'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else {
                  onEdit?.call();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Booth'),
              enabled: !booth.isBooked,
              onTap: () {
                Navigator.pop(context);
                if (booth.isBooked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot delete a booked booth'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else {
                  onDelete?.call();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.info),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                onTap.call();
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
