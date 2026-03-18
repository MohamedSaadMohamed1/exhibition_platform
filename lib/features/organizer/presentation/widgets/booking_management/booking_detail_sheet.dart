import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../shared/models/booking_model.dart';
import '../../providers/organizer_booking_provider.dart';

class BookingDetailSheet extends ConsumerStatefulWidget {
  final BookingRequest booking;
  final String organizerId;

  const BookingDetailSheet({
    super.key,
    required this.booking,
    required this.organizerId,
  });

  @override
  ConsumerState<BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends ConsumerState<BookingDetailSheet> {
  final _rejectionReasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizerBookingProvider(widget.organizerId));

    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking Request',
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

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.booking.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(widget.booking.status),
                    color: _getStatusColor(widget.booking.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.booking.statusDisplayText,
                    style: TextStyle(
                      color: _getStatusColor(widget.booking.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Exhibitor Information
            _SectionTitle(title: 'Exhibitor Information'),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Name',
              value: widget.booking.exhibitorName ?? 'N/A',
              icon: Icons.person,
            ),
            if (widget.booking.exhibitorPhone != null)
              _InfoRow(
                label: 'Phone',
                value: widget.booking.exhibitorPhone!,
                icon: Icons.phone,
              ),
            const SizedBox(height: 24),

            // Booth Information
            _SectionTitle(title: 'Booth Information'),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Booth Number',
              value: widget.booking.boothNumber ?? widget.booking.boothId,
              icon: Icons.storefront,
            ),
            if (widget.booking.eventTitle != null)
              _InfoRow(
                label: 'Event',
                value: widget.booking.eventTitle!,
                icon: Icons.event,
              ),
            if (widget.booking.totalPrice != null)
              _InfoRow(
                label: 'Price',
                value: '\$${widget.booking.totalPrice!.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                valueColor: AppColors.success,
              ),
            const SizedBox(height: 24),

            // Request Details
            _SectionTitle(title: 'Request Details'),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Requested',
              value: DateFormat('MMM dd, yyyy • hh:mm a').format(widget.booking.createdAt),
              icon: Icons.access_time,
            ),
            if (widget.booking.approvedAt != null)
              _InfoRow(
                label: 'Approved',
                value: DateFormat('MMM dd, yyyy • hh:mm a').format(widget.booking.approvedAt!),
                icon: Icons.check_circle,
              ),
            if (widget.booking.rejectedAt != null)
              _InfoRow(
                label: 'Rejected',
                value: DateFormat('MMM dd, yyyy • hh:mm a').format(widget.booking.rejectedAt!),
                icon: Icons.cancel,
              ),

            // Exhibitor Message
            if (widget.booking.message != null && widget.booking.message!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionTitle(title: 'Message from Exhibitor'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.booking.message!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],

            // Rejection Reason
            if (widget.booking.rejectionReason != null) ...[
              const SizedBox(height: 24),
              _SectionTitle(title: 'Rejection Reason'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  widget.booking.rejectionReason!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ),
            ],

            // Actions for pending requests
            if (widget.booking.isPending) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isRejecting ? null : () => _showRejectDialog(),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: state.isApproving ? 'Approving...' : 'Approve',
                      onPressed: state.isApproving || state.isRejecting
                          ? null
                          : _approveBooking,
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _approveBooking() async {
    final notifier = ref.read(organizerBookingProvider(widget.organizerId).notifier);
    final success = await notifier.approveBooking(widget.booking.id);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking approved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(organizerBookingProvider(widget.organizerId)).actionError ??
                  'Failed to approve booking',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject this booking request?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                hintText: 'Provide a reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectBooking();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectBooking() async {
    final notifier = ref.read(organizerBookingProvider(widget.organizerId).notifier);
    final success = await notifier.rejectBooking(
      widget.booking.id,
      reason: _rejectionReasonController.text.trim().isEmpty
          ? null
          : _rejectionReasonController.text.trim(),
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking rejected'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(organizerBookingProvider(widget.organizerId)).actionError ??
                  'Failed to reject booking',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.approved:
        return Icons.check_circle;
      case BookingStatus.rejected:
        return Icons.cancel;
      case BookingStatus.confirmed:
        return Icons.verified;
      case BookingStatus.cancelled:
        return Icons.close;
    }
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
