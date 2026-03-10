import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/order_provider.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view orders')),
      );
    }

    final ordersState = ref.watch(customerOrdersProvider(currentUser.id));

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'My Orders',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryDark,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
          onTap: (index) {
            OrderStatus? status;
            switch (index) {
              case 1:
                status = OrderStatus.pending;
                break;
              case 2:
                status = OrderStatus.inProgress;
                break;
              case 3:
                status = OrderStatus.completed;
                break;
            }
            ref
                .read(customerOrdersProvider(currentUser.id).notifier)
                .filterByStatus(status);
          },
        ),
      ),
      body: _buildBody(ordersState, currentUser.id),
    );
  }

  Widget _buildBody(OrdersState state, String userId) {
    if (state.isLoading && state.orders.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null && state.orders.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(customerOrdersProvider(userId).notifier).refresh(),
      );
    }

    if (state.orders.isEmpty) {
      return const EmptyStateWidget(
        title: 'No orders yet',
        subtitle: 'Browse services and make your first order',
        icon: Icons.shopping_bag_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(customerOrdersProvider(userId).notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          return _OrderCard(
            order: state.orders[index],
            onTap: () => _showOrderDetails(state.orders[index], userId),
          );
        },
      ),
    );
  }

  void _showOrderDetails(OrderModel order, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Details',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 20),
              // Service info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceName ?? 'Service',
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.store,
                          color: AppColors.textSecondaryDark,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.supplierName ?? 'Supplier',
                          style: const TextStyle(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Order info
              _InfoRow(
                label: 'Order ID',
                value: '#${order.id.substring(0, 8)}',
              ),
              _InfoRow(
                label: 'Total Price',
                value: order.formattedPrice,
                valueColor: AppColors.primary,
              ),
              if (order.serviceDate != null)
                _InfoRow(
                  label: 'Service Date',
                  value: _formatDate(order.serviceDate!),
                ),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.notes!,
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ],
              if (order.rejectionReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rejection reason: ${order.rejectionReason}',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Action buttons
              if (order.canBeCancelled)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _cancelOrder(order, userId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel Order'),
                  ),
                ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _cancelOrder(OrderModel order, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'Cancel Order',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: const Text(
          'Are you sure you want to cancel this order?',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    Navigator.pop(context);

    final success = await ref
        .read(customerOrdersProvider(userId).notifier)
        .cancelOrder(order.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel order'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.serviceName ?? 'Service',
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.supplierName ?? 'Supplier',
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.formattedPrice,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.accepted:
        return AppColors.info;
      case OrderStatus.inProgress:
        return AppColors.primary;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String get _text {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _text,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondaryDark,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
