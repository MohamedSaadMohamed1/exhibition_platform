import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../shared/models/booking_model.dart';
import '../../../../../shared/models/booth_model.dart';
import '../../../../../shared/providers/providers.dart';
import '../../providers/organizer_booking_provider.dart';
import '../../providers/organizer_booth_provider.dart';

/// Provider to fetch the active booking for a given booth
final _boothActiveBookingProvider = FutureProvider.autoDispose
    .family<BookingRequest?, String>((ref, boothId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final result = await repo.getActiveBookingByBoothId(boothId);
  return result.fold((_) => null, (booking) => booking);
});

/// Bottom sheet that shows booth details + booking request management actions
class BoothDetailSheet extends ConsumerStatefulWidget {
  final BoothModel booth;
  final String organizerId;
  final String eventId;
  final VoidCallback? onStatusChanged;

  const BoothDetailSheet({
    super.key,
    required this.booth,
    required this.organizerId,
    required this.eventId,
    this.onStatusChanged,
  });

  @override
  ConsumerState<BoothDetailSheet> createState() => _BoothDetailSheetState();
}

class _BoothDetailSheetState extends ConsumerState<BoothDetailSheet> {
  final _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(
      _boothActiveBookingProvider(widget.booth.id),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booth header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.booth.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.storefront,
                    color: _getStatusColor(widget.booth.status),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booth ${widget.booth.boothNumber}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        widget.booth.sizeDisplayText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(widget.booth.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.booth.status.value.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(widget.booth.status),
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
                  'KD ${widget.booth.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.organizerColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),

            if (widget.booth.category != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Category'),
                  Text(widget.booth.category!),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Change Status button
            OutlinedButton.icon(
              onPressed: () => _showChangeStatusDialog(context),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Change Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.organizerColor,
                side: const BorderSide(color: AppColors.organizerColor),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),

            const Divider(height: 32),

            // Amenities
            if (widget.booth.amenities.isNotEmpty) ...[
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
                children: widget.booth.amenities
                    .map((a) => Chip(
                          label: Text(a, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppColors.grey800,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Description
            if (widget.booth.description != null) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(widget.booth.description!),
              const SizedBox(height: 16),
            ],

            // Booking request section — only for reserved/booked booths
            if (widget.booth.status == BoothStatus.reserved ||
                widget.booth.status == BoothStatus.booked) ...[
              const Divider(height: 32),
              Text(
                'Booking Request',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              bookingAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const Text(
                  'Failed to load booking details',
                  style: TextStyle(color: AppColors.error),
                ),
                data: (booking) {
                  if (booking == null) {
                    return Text(
                      'No active booking found for this booth.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    );
                  }
                  return _BookingSection(
                    booking: booking,
                    organizerId: widget.organizerId,
                    onStatusChanged: () {
                      // Invalidate provider so booking info refreshes
                      ref.invalidate(
                        _boothActiveBookingProvider(widget.booth.id),
                      );
                      widget.onStatusChanged?.call();
                    },
                  );
                },
              ),
            ],

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Change Booth Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(),
            ...BoothStatus.values.map((status) {
              final isCurrent = status == widget.booth.status;
              return ListTile(
                leading: CircleAvatar(
                  radius: 10,
                  backgroundColor: _getStatusColor(status),
                ),
                title: Text(
                  status.value[0].toUpperCase() + status.value.substring(1),
                  style: TextStyle(
                    fontWeight:
                        isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? _getStatusColor(status) : null,
                  ),
                ),
                trailing: isCurrent
                    ? Icon(Icons.check, color: _getStatusColor(status))
                    : null,
                onTap: isCurrent
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        _applyStatusChange(context, status);
                      },
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _applyStatusChange(
      BuildContext context, BoothStatus newStatus) async {
    final notifier =
        ref.read(organizerBoothsProvider(widget.eventId).notifier);
    final success =
        await notifier.updateBoothStatus(widget.booth.id, newStatus);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Booth status changed to ${newStatus.value}'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
      widget.onStatusChanged?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to change booth status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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

/// Inner widget that shows booking info and action buttons
class _BookingSection extends ConsumerStatefulWidget {
  final BookingRequest booking;
  final String organizerId;
  final VoidCallback? onStatusChanged;

  const _BookingSection({
    required this.booking,
    required this.organizerId,
    this.onStatusChanged,
  });

  @override
  ConsumerState<_BookingSection> createState() => _BookingSectionState();
}

class _BookingSectionState extends ConsumerState<_BookingSection> {
  final _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(organizerBookingProvider(widget.organizerId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getBookingStatusColor(widget.booking.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getBookingStatusIcon(widget.booking.status),
                color: _getBookingStatusColor(widget.booking.status),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.booking.statusDisplayText,
                style: TextStyle(
                  color: _getBookingStatusColor(widget.booking.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Exhibitor info
        _InfoRow(
          icon: Icons.person,
          label: 'Exhibitor',
          value: widget.booking.exhibitorName ?? 'N/A',
        ),
        if (widget.booking.exhibitorPhone != null)
          _InfoRow(
            icon: Icons.phone,
            label: 'Phone',
            value: widget.booking.exhibitorPhone!,
          ),
        if (widget.booking.totalPrice != null)
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Total Price',
            value: 'KD ${widget.booking.totalPrice!.toStringAsFixed(2)}',
            valueColor: AppColors.success,
          ),
        _InfoRow(
          icon: Icons.access_time,
          label: 'Requested',
          value: DateFormat('MMM dd, yyyy • hh:mm a')
              .format(widget.booking.createdAt),
        ),
        if (widget.booking.approvedAt != null)
          _InfoRow(
            icon: Icons.check_circle,
            label: 'Approved',
            value: DateFormat('MMM dd, yyyy • hh:mm a')
                .format(widget.booking.approvedAt!),
          ),
        if (widget.booking.confirmedAt != null)
          _InfoRow(
            icon: Icons.verified,
            label: 'Confirmed',
            value: DateFormat('MMM dd, yyyy • hh:mm a')
                .format(widget.booking.confirmedAt!),
          ),

        // Exhibitor message
        if (widget.booking.message != null &&
            widget.booking.message!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Message',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
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

        // Rejection reason
        if (widget.booking.rejectionReason != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error),
            ),
            child: Text(
              'Rejected: ${widget.booking.rejectionReason}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],

        // Action buttons — pending
        if (widget.booking.isPending) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: bookingState.isRejecting
                      ? null
                      : () => _showRejectDialog(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: bookingState.isApproving ? 'Approving...' : 'Approve',
                  onPressed: bookingState.isApproving || bookingState.isRejecting
                      ? null
                      : () => _approveBooking(context),
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ],

        // Action buttons — approved (awaiting confirmation)
        if (widget.booking.isApproved) ...[
          const SizedBox(height: 20),
          AppButton(
            text: 'Confirm Booking',
            onPressed: () => _confirmBooking(context),
            icon: Icons.verified,
          ),
        ],
      ],
    );
  }

  Future<void> _approveBooking(BuildContext context) async {
    final notifier =
        ref.read(organizerBookingProvider(widget.organizerId).notifier);
    final success = await notifier.approveBooking(widget.booking.id);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking approved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
      widget.onStatusChanged?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref
                    .read(organizerBookingProvider(widget.organizerId))
                    .actionError ??
                'Failed to approve booking',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmBooking(BuildContext context) async {
    final notifier =
        ref.read(organizerBookingProvider(widget.organizerId).notifier);
    final success = await notifier.confirmBooking(widget.booking.id);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
      widget.onStatusChanged?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref
                    .read(organizerBookingProvider(widget.organizerId))
                    .actionError ??
                'Failed to confirm booking',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context) {
    _rejectionReasonController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _rejectBooking(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectBooking(BuildContext context) async {
    final notifier =
        ref.read(organizerBookingProvider(widget.organizerId).notifier);
    final reason = _rejectionReasonController.text.trim();
    final success = await notifier.rejectBooking(
      widget.booking.id,
      reason: reason.isEmpty ? null : reason,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking rejected'),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pop(context);
      widget.onStatusChanged?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref
                    .read(organizerBookingProvider(widget.organizerId))
                    .actionError ??
                'Failed to reject booking',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _getBookingStatusColor(BookingStatus status) {
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

  IconData _getBookingStatusIcon(BookingStatus status) {
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
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
