import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../../core/constants/enums.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/models/booking_model.dart';

class BookingRequestCard extends StatelessWidget {
  final BookingRequest booking;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onViewDetails;
  final bool isLoading;

  const BookingRequestCard({
    super.key,
    required this.booking,
    this.onApprove,
    this.onReject,
    this.onViewDetails,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: exhibitor info and status
              Row(
                children: [
                  // Exhibitor avatar
                  CircleAvatar(
                    backgroundColor: AppColors.organizerColor.withOpacity(0.1),
                    child: Text(
                      (booking.exhibitorName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.organizerColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Exhibitor name and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.exhibitorName ?? 'Unknown',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeago.format(booking.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.status.name.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Booth and price info
              Row(
                children: [
                  Icon(
                    Icons.storefront,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Booth ${booking.boothNumber ?? booking.boothId}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  if (booking.totalPrice != null)
                    Text(
                      'KD ${booking.totalPrice!.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
              // Message preview
              if (booking.message != null && booking.message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  booking.message!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
              // Actions for pending requests
              if (booking.isPending) ...[
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : onReject,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : onApprove,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              // View details for non-pending requests
              if (!booking.isPending) ...[
                const Divider(height: 20),
                TextButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('View Details'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.statusPending;
      case BookingStatus.approved:
        return AppColors.statusApproved;
      case BookingStatus.rejected:
        return AppColors.statusRejected;
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }
}
