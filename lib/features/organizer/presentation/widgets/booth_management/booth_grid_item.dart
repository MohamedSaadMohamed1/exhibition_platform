import 'package:flutter/material.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/models/booth_model.dart';

class BoothGridItem extends StatelessWidget {
  final BoothModel booth;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BoothGridItem({
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
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: _color.withOpacity(0.2),
          border: Border.all(color: _color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              booth.boothNumber,
              style: TextStyle(
                color: _color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'KD ${booth.price.toStringAsFixed(0)}',
              style: TextStyle(
                color: _color.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Booth'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            if (!booth.isBooked)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Delete Booth'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
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
          ],
        ),
      ),
    );
  }
}
