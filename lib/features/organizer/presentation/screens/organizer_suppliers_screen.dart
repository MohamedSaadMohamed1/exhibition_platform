import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/routes.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/providers/repository_providers.dart';

/// Direct provider to avoid the isLoading guard bug in customerOrdersProvider
final organizerSupplierBookingsProvider =
    FutureProvider.autoDispose.family<List<OrderModel>, String>(
  (ref, organizerId) async {
    final repo = ref.watch(orderRepositoryProvider);
    final result = await repo.getCustomerOrders(organizerId);
    return result.fold(
      (l) => throw Exception(l.message),
      (r) => r.where((o) => o.eventId != null).toList(),
    );
  },
);

class OrganizerSuppliersScreen extends ConsumerWidget {
  const OrganizerSuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Bookings'),
      ),
      body: Column(
        children: [
          // Find Suppliers button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.suppliers),
              icon: const Icon(Icons.search),
              label: const Text('Browse & Book Suppliers'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.organizerColor),
                foregroundColor: AppColors.organizerColor,
              ),
            ),
          ),
          const Divider(height: 1),
          // Bookings list
          Expanded(
            child: currentUserId == null
                ? const Center(child: Text('Not authenticated'))
                : _SupplierBookingsList(organizerId: currentUserId),
          ),
        ],
      ),
    );
  }
}

class _SupplierBookingsList extends ConsumerWidget {
  final String organizerId;

  const _SupplierBookingsList({required this.organizerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync =
        ref.watch(organizerSupplierBookingsProvider(organizerId));

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(err.toString(),
                style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(
                  organizerSupplierBookingsProvider(organizerId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.handshake_outlined,
                      size: 64,
                      color: AppColors.textSecondaryDark.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No supplier bookings yet',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Browse suppliers and book them for your events',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(
              organizerSupplierBookingsProvider(organizerId)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _SupplierBookingCard(order: bookings[index]);
            },
          ),
        );
      },
    );
  }
}

class _SupplierBookingCard extends StatelessWidget {
  final OrderModel order;

  const _SupplierBookingCard({required this.order});

  Color _statusColor() {
    return Color(
      int.parse(order.statusColorHex.replaceFirst('#', '0xFF')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = order.serviceDate != null
        ? DateFormat('MMM d, yyyy').format(order.serviceDate!)
        : 'Date not set';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey700),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.supplierName ?? 'Supplier',
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.serviceName != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.event, size: 12,
                              color: AppColors.organizerColor),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              order.serviceName!,
                              style: const TextStyle(
                                color: AppColors.organizerColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusDisplayText,
                  style: TextStyle(
                    color: _statusColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.textSecondaryDark),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style: const TextStyle(
                    color: AppColors.textSecondaryDark, fontSize: 13),
              ),
              if (order.totalPrice > 0) ...[
                const SizedBox(width: 16),
                const Icon(Icons.attach_money,
                    size: 14, color: AppColors.textSecondaryDark),
                Text(
                  order.formattedPrice,
                  style: const TextStyle(
                      color: AppColors.textSecondaryDark, fontSize: 13),
                ),
              ],
            ],
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              order.notes!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textSecondaryDark, fontSize: 13),
            ),
          ],
          if (order.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Reason: ${order.rejectionReason}',
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
