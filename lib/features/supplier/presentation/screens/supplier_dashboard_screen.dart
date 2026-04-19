import 'dart:io';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../router/routes.dart';
import '../../../../shared/models/business_request_model.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/chat_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/widgets/role_dashboard_shell.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart' show userChatsStreamProvider;
import '../providers/supplier_dashboard_provider.dart';

class SupplierDashboardScreen extends ConsumerStatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  ConsumerState<SupplierDashboardScreen> createState() =>
      _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState
    extends ConsumerState<SupplierDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull
        ?? ref.watch(authNotifierProvider).user;

    final navItems = [
      const NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      const NavItem(icon: Icons.inventory_2_rounded, label: 'Services'),
      const NavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
      const NavItem(icon: Icons.chat_rounded, label: 'Messages'),
      const NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return RoleDashboardShell(
      currentIndex: _currentIndex,
      navItems: navItems,
      onNavTap: _onNavTap,
      accentColor: AppColors.supplierColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          Widget child;
          switch (_currentIndex) {
            case 0:
              child = _DashboardTab(currentUser: currentUser);
              break;
            case 1:
              child = const _ServicesTab();
              break;
            case 2:
              child = const _OrdersTab();
              break;
            case 3:
              child = const _MessagesTab();
              break;
            case 4:
              child = const _ProfileTab();
              break;
            default:
              child = _DashboardTab(currentUser: currentUser);
          }
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: child,
          );
        },
      ),
    );
  }
}

// ============================================================================
// DASHBOARD TAB
// ============================================================================
class _DashboardTab extends ConsumerWidget {
  final dynamic currentUser;

  const _DashboardTab({this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(supplierStatsProvider);
    final recentOrdersAsync = ref.watch(recentOrdersProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(supplierStatsProvider);
          ref.invalidate(recentOrdersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Profiles Dropdown Switcher
              const _BusinessSwitcherHeader(),
              const SizedBox(height: 16),

              // Welcome Card
              _WelcomeCard(currentUser: currentUser),
              const SizedBox(height: 24),

              // Stats Grid
              const Text(
                'Overview',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              statsAsync.when(
                data: (stats) => _StatsGrid(stats: stats),
                loading: () => const _StatsGridSkeleton(),
                error: (_, __) => const _StatsGrid(
                  stats: SupplierDashboardStats(),
                ),
              ),
              const SizedBox(height: 28),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const _QuickActions(),
              const SizedBox(height: 28),

              // Recent Orders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to orders tab
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              recentOrdersAsync.when(
                data: (orders) => orders.isEmpty
                    ? _buildEmptyOrders()
                    : Column(
                        children: orders.map((order) {
                          return _OrderCard(order: order);
                        }).toList(),
                      ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => _buildEmptyOrders(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: AppColors.grey600),
          const SizedBox(height: 12),
          const Text(
            'No orders yet',
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessSwitcherHeader extends ConsumerWidget {
  const _BusinessSwitcherHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(userSuppliersProvider);
    final selectedId = ref.watch(selectedSupplierIdProvider);

    return suppliersAsync.when(
      data: (suppliers) {
        if (suppliers.isEmpty) return const SizedBox.shrink();

        final currentSupplier = selectedId != null
            ? suppliers.firstWhere(
                (s) => s.id == selectedId,
                orElse: () => suppliers.first,
              )
            : suppliers.first;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.supplierColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.storefront_rounded, color: AppColors.supplierColor),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentSupplier.id,
                    dropdownColor: AppColors.surfaceDark,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.supplierColor),
                    isDense: true,
                    isExpanded: true,
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (newId) async {
                      if (newId == 'create_new') {
                        _showCreateBusinessDialog(context, ref);
                      } else if (newId != null) {
                        ref.read(selectedSupplierIdProvider.notifier).state = newId;
                        ref.invalidate(myServicesProvider);
                        ref.invalidate(recentOrdersProvider);
                        ref.invalidate(supplierStatsProvider);
                        ref.invalidate(currentSupplierProvider);
                      }
                    },
                    items: [
                      ...suppliers.map(
                        (s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            s.businessName.isEmpty ? 'My Business' : s.businessName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: 'create_new',
                        child: Row(
                          children: [
                            Icon(Icons.add, color: AppColors.supplierColor, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Request New Business',
                              style: TextStyle(color: AppColors.supplierColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showCreateBusinessDialog(BuildContext context, WidgetRef ref) {
    // Direct creation is no longer allowed — route to the request flow.
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Request New Business',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'To add a new business, go to Profile → "Request New Business" and fill in the details. An admin will review and approve your request.',
          style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.supplierColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final dynamic currentUser;

  const _WelcomeCard({this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.supplierColor,
            AppColors.supplierColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.supplierColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: currentUser?.profileImage != null
                  ? NetworkImage(currentUser.profileImage)
                  : null,
              child: currentUser?.profileImage == null
                  ? Text(
                      currentUser?.name?.isNotEmpty == true
                          ? currentUser.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.name ?? 'Supplier',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified,
                          size: 14, color: Colors.white.withOpacity(0.9)),
                      const SizedBox(width: 4),
                      Text(
                        'Verified Supplier',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 28),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final SupplierDashboardStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          title: 'Active Services',
          value: '${stats.activeServices}',
          icon: Icons.inventory_2_rounded,
          color: AppColors.supplierColor,
          trend: '+2 this week',
          trendUp: true,
        ),
        _StatCard(
          title: 'Pending Orders',
          value: '${stats.pendingOrders}',
          icon: Icons.pending_actions_rounded,
          color: AppColors.warning,
          trend: 'Needs attention',
          trendUp: null,
        ),
        _StatCard(
          title: 'Completed',
          value: '${stats.completedOrders}',
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          trend: 'All time',
          trendUp: true,
        ),
        _StatCard(
          title: 'This Month',
          value: 'KD ${_formatMoney(stats.monthlyRevenue)}',
          icon: Icons.trending_up_rounded,
          color: AppColors.info,
          trend: 'Revenue',
          trendUp: true,
        ),
      ],
    );
  }

  String _formatMoney(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (trend != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trendUp != null)
                      Icon(
                        trendUp! ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: trendUp! ? AppColors.success : AppColors.error,
                      ),
                    const SizedBox(width: 2),
                    Text(
                      trend!,
                      style: TextStyle(
                        color: AppColors.textMutedDark,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  void _showAddServiceDialog(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ServiceFormSheet(),
    ).then((success) {
      if (success == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'Add Service',
            color: AppColors.supplierColor,
            onTap: () => _showAddServiceDialog(context),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: _getStatusColor(order.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.serviceName ?? 'Service Order',
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName ?? 'Customer',
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusDisplayText,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.formattedPrice,
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
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

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.accepted:
        return Icons.thumb_up;
      case OrderStatus.inProgress:
        return Icons.sync;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.rejected:
        return Icons.cancel;
      case OrderStatus.cancelled:
        return Icons.block;
    }
  }
}

// ============================================================================
// SERVICES TAB
// ============================================================================
class _ServicesTab extends ConsumerWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(myServicesProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'My Services',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddServiceDialog(context, ref),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.supplierColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child: servicesAsync.when(
              data: (services) {
                if (services.isEmpty) {
                  return _buildEmptyServices(context, ref);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(myServicesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return _ServiceCard(
                        service: services[index],
                        onToggle: () {
                          ref
                              .read(serviceManagementProvider.notifier)
                              .toggleServiceStatus(
                                services[index].id,
                                !services[index].isActive,
                              );
                        },
                        onEdit: () =>
                            _showEditServiceDialog(context, ref, services[index]),
                        onDelete: () =>
                            _showDeleteConfirmation(context, ref, services[index]),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (_, __) => const Center(
                child: Text(
                  'Failed to load services',
                  style: TextStyle(color: AppColors.textSecondaryDark),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyServices(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.supplierColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.supplierColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No services yet',
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start adding services to showcase your offerings',
            style: TextStyle(color: AppColors.textSecondaryDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddServiceDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.supplierColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ServiceFormSheet(),
    ).then((success) {
      if (success == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _showEditServiceDialog(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ServiceFormSheet(service: service),
    ).then((success) {
      if (success == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Delete Service',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${service.title}"?',
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(serviceManagementProvider.notifier).deleteService(service.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: service.isActive
              ? AppColors.supplierColor.withOpacity(0.3)
              : AppColors.grey800,
        ),
      ),
      child: Column(
        children: [
          // Service Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: service.images.isNotEmpty
                  ? Image.network(
                      service.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          // Service Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.title,
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: service.isActive,
                      onChanged: (_) => onToggle(),
                      activeColor: AppColors.supplierColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  service.category,
                  style: const TextStyle(
                    color: AppColors.supplierColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      service.formattedPrice,
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          service.ratingDisplay,
                          style: const TextStyle(color: AppColors.textPrimaryDark),
                        ),
                        Text(
                          ' (${service.reviewsCount})',
                          style:
                              const TextStyle(color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.supplierColor,
                          side: const BorderSide(color: AppColors.supplierColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.grey800,
      child: const Center(
        child: Icon(Icons.inventory_2, size: 48, color: AppColors.grey600),
      ),
    );
  }
}

// Service Form Sheet
class _ServiceFormSheet extends ConsumerStatefulWidget {
  final ServiceModel? service;

  const _ServiceFormSheet({this.service});

  @override
  ConsumerState<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<_ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  String _selectedCategory = ServiceCategories.all.first;
  String _selectedPriceUnit = PriceUnits.perEvent;
  List<String> _existingImages = [];
  List<XFile> _newImages = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.service?.description ?? '');
    _priceController =
        TextEditingController(text: widget.service?.price?.toString() ?? '');
    if (widget.service != null) {
      _selectedCategory = widget.service!.category;
      _selectedPriceUnit = widget.service!.priceUnit ?? PriceUnits.perEvent;
      _existingImages = List.from(widget.service!.images);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 80, maxWidth: 1920);
    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not authenticated. Please log in again.';
      });
      return;
    }
    
    // Upload images conceptually tied to supplier
    final uploadService = ref.read(imageUploadServiceProvider);
    List<String> finalUrls = [..._existingImages];
    
    try {
      for (final file in _newImages) {
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          final result = await uploadService.uploadImageFromBytes(
            bytes: bytes,
            storagePath: '${StoragePaths.supplierImages}/$userId',
            fileName: file.name,
          );
          finalUrls.add(result.url);
        } else {
          final result = await uploadService.uploadSupplierImage(
            file: File(file.path),
            supplierId: userId,
          );
          finalUrls.add(result.url);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to upload images: $e';
      });
      return;
    }

    final service = ServiceModel(
      id: widget.service?.id ?? '',
      supplierId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      price: double.tryParse(_priceController.text) ?? 0,
      priceUnit: _selectedPriceUnit,
      createdAt: widget.service?.createdAt ?? DateTime.now(),
      images: finalUrls,
    );

    bool success;
    if (widget.service != null) {
      success = await ref
          .read(serviceManagementProvider.notifier)
          .updateService(service);
    } else {
      success = await ref
          .read(serviceManagementProvider.notifier)
          .createService(service);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (success && mounted) {
      Navigator.pop(context, true); // pass true = success
    } else if (mounted) {
      final errorState = ref.read(serviceManagementProvider);
      final error = errorState.error;
      String msg;
      if (error is FirebaseException) {
        msg = 'Firestore error (${error.code}): ${error.message ?? error.code}';
      } else if (error != null) {
        msg = error.toString();
      } else {
        msg = 'Failed to save service. Please try again.';
      }
      setState(() => _errorMessage = msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.service != null ? 'Edit Service' : 'Add Service',
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.grey700, height: 1),
          // We wrap Expanded with a conditional loading shield if you want, or just disable buttons.
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.supplierColor))
              : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Images Picker UI ---
                    const Text('Service Images (Optional)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Add Button
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDark,
                                border: Border.all(color: AppColors.supplierColor.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, color: AppColors.supplierColor),
                                  SizedBox(height: 4),
                                  Text('Add Photo', style: TextStyle(color: AppColors.supplierColor, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          // Existing URLs
                          ..._existingImages.asMap().entries.map((entry) {
                             return Stack(
                               children: [
                                 Container(
                                   width: 100,
                                   margin: const EdgeInsets.only(right: 12),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(12),
                                     image: DecorationImage(image: NetworkImage(entry.value), fit: BoxFit.cover),
                                   ),
                                 ),
                                 Positioned(
                                   top: 4, right: 16,
                                   child: GestureDetector(
                                     onTap: () => setState(() => _existingImages.removeAt(entry.key)),
                                     child: Container(
                                       padding: const EdgeInsets.all(4),
                                       decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                       child: const Icon(Icons.close, color: Colors.white, size: 14),
                                     ),
                                   ),
                                 ),
                               ],
                             );
                          }),
                          // New Local Files
                          ..._newImages.asMap().entries.map((entry) {
                             return Stack(
                               children: [
                                 Container(
                                   width: 100,
                                   margin: const EdgeInsets.only(right: 12),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(12),
                                     image: DecorationImage(
                                       image: kIsWeb 
                                           ? NetworkImage(entry.value.path) 
                                           : FileImage(File(entry.value.path)) as ImageProvider, 
                                       fit: BoxFit.cover
                                     ),
                                   ),
                                 ),
                                 Positioned(
                                   top: 4, right: 16,
                                   child: GestureDetector(
                                     onTap: () => setState(() => _newImages.removeAt(entry.key)),
                                     child: Container(
                                       padding: const EdgeInsets.all(4),
                                       decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                       child: const Icon(Icons.close, color: Colors.white, size: 14),
                                     ),
                                   ),
                                 ),
                               ],
                             );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Service Title'),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Enter service title',
                      validator: (v) =>
                          v?.isEmpty == true ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Category'),
                    _buildDropdown(
                      value: _selectedCategory,
                      items: ServiceCategories.all,
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Description'),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Describe your service',
                      maxLines: 4,
                      validator: (v) =>
                          v?.isEmpty == true ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Price'),
                              _buildTextField(
                                controller: _priceController,
                                hint: '0.00',
                                keyboardType: TextInputType.number,
                                suffixText: 'KD',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Price Unit'),
                              _buildDropdown(
                                value: _selectedPriceUnit,
                                items: PriceUnits.all,
                                onChanged: (v) =>
                                    setState(() => _selectedPriceUnit = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.supplierColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                widget.service != null
                                    ? 'Update Service'
                                    : 'Create Service',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimaryDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMutedDark),
        suffixText: suffixText,
        suffixStyle: const TextStyle(
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.supplierColor),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.cardDark,
          style: const TextStyle(color: AppColors.textPrimaryDark),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ============================================================================
// ORDERS TAB
// ============================================================================
class _OrdersTab extends ConsumerStatefulWidget {
  const _OrdersTab();

  @override
  ConsumerState<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<_OrdersTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final ordersAsync = ref.watch(myOrdersAsSupplierProvider);

    return RepaintBoundary(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Orders',
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.supplierColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondaryDark,
                labelStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                padding: EdgeInsets.zero,
                tabAlignment: TabAlignment.fill,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Active'),
                  Tab(text: 'Done'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Orders List
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _OrdersList(orders: orders),
                      _OrdersList(
                        orders: orders
                            .where((o) => o.status == OrderStatus.pending)
                            .toList(),
                      ),
                      _OrdersList(
                        orders: orders
                            .where((o) =>
                                o.status == OrderStatus.accepted ||
                                o.status == OrderStatus.inProgress)
                            .toList(),
                      ),
                      _OrdersList(
                        orders: orders
                            .where((o) =>
                                o.status == OrderStatus.completed ||
                                o.status == OrderStatus.cancelled)
                            .toList(),
                      ),
                    ],
                  );
                },
                loading: () => const LoadingWidget(),
                error: (_, __) => const Center(
                  child: Text('Failed to load orders',
                      style: TextStyle(color: AppColors.textSecondaryDark)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final List<OrderModel> orders;

  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myOrdersAsSupplierProvider);
      },
      child: orders.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: AppColors.grey600),
                        const SizedBox(height: 16),
                        const Text(
                          'No orders found',
                          style: TextStyle(
                              color: AppColors.textSecondaryDark, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _OrderDetailCard(
                  order: orders[index],
                  onStatusChange: (status, {String? reason}) {
                    ref.read(orderManagementProvider.notifier).updateOrderStatus(
                          orders[index].id,
                          status,
                          reason: reason,
                        );
                  },
                );
              },
            ),
    );
  }
}

class _OrderDetailCard extends StatelessWidget {
  final OrderModel order;
  final void Function(OrderStatus status, {String? reason}) onStatusChange;

  const _OrderDetailCard({
    required this.order,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey800),
      ),
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
                      order.serviceName ?? 'Service Order',
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer: ${order.customerName ?? "N/A"}',
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusDisplayText,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.grey800, height: 24),
          Row(
            children: [
              _InfoChip(
                icon: Icons.attach_money,
                label: order.formattedPrice,
              ),
              const SizedBox(width: 12),
              if (order.serviceDate != null)
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: _formatDate(order.serviceDate!),
                ),
            ],
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Notes: ${order.notes}',
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 13,
              ),
            ),
          ],
          if (order.canBeAccepted || order.canStartProgress || order.canBeCompleted) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (order.canBeAccepted) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onStatusChange(OrderStatus.rejected),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusChange(OrderStatus.accepted),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
                if (order.canStartProgress)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusChange(OrderStatus.inProgress),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Start Work'),
                    ),
                  ),
                if (order.canBeCompleted)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusChange(OrderStatus.completed),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Mark Complete'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MESSAGES TAB
// ============================================================================
class _MessagesTab extends ConsumerWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final chatsAsync = ref.watch(userChatsStreamProvider(currentUserId ?? ''));

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.search, color: AppColors.textSecondaryDark),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: chatsAsync.when(
              data: (chats) {
                if (chats.isEmpty) {
                  return _buildEmptyMessages();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return _ChatItem(
                      chat: chat,
                      currentUserId: currentUserId ?? '',
                      onTap: () => context.push(
                        AppRoutes.chat.replaceFirst(':chatId', chat.id),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (_, __) => _buildEmptyMessages(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline,
                size: 64, color: AppColors.grey600),
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Messages from customers will appear here',
            style: TextStyle(color: AppColors.textSecondaryDark),
          ),
        ],
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final ChatModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const _ChatItem({
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  String _getOtherUserName() {
    // Find the other participant's name
    for (final participantId in chat.participants) {
      if (participantId != currentUserId) {
        return chat.participantNames[participantId] ?? 'Customer';
      }
    }
    return 'Customer';
  }

  int _getUnreadCount() {
    return chat.unreadCount[currentUserId] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final otherUserName = _getOtherUserName();
    final unreadCount = _getUnreadCount();

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.supplierColor.withOpacity(0.2),
        child: Text(
          otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'C',
          style: const TextStyle(
            color: AppColors.supplierColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        otherUserName,
        style: const TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        chat.lastMessage ?? 'Start a conversation',
        style: const TextStyle(color: AppColors.textSecondaryDark),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(chat.lastMessageAt),
            style: const TextStyle(
              color: AppColors.textMutedDark,
              fontSize: 12,
            ),
          ),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.supplierColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}

// ============================================================================
// PROFILE TAB
// ============================================================================
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.supplierColor.withOpacity(0.2),
                    AppColors.supplierColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.supplierColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.supplierColor, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.supplierColor.withOpacity(0.2),
                      backgroundImage: currentUser?.profileImage != null
                          ? NetworkImage(currentUser!.profileImage!)
                          : null,
                      child: currentUser?.profileImage == null
                          ? Text(
                              currentUser?.name?.isNotEmpty == true
                                  ? currentUser!.name[0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                color: AppColors.supplierColor,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser?.name ?? 'Supplier',
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.supplierColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'VERIFIED SUPPLIER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Menu Items
            _ProfileMenuItem(
              icon: Icons.edit_rounded,
              title: 'Edit Profile',
              subtitle: 'Update your information',
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            _ProfileMenuItem(
              icon: Icons.store_rounded,
              title: 'Business Settings',
              subtitle: 'Manage your business details',
              onTap: () => context.push(AppRoutes.supplierBusinessSettings),
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () => context.push(AppRoutes.notifications),
            ),
            _ProfileMenuItem(
              icon: Icons.help_rounded,
              title: 'Help & Support',
              subtitle: 'Get help or contact us',
              onTap: () => context.push(AppRoutes.helpSupport),
            ),
            _ProfileMenuItem(
              icon: Icons.add_business_rounded,
              title: 'Request New Business',
              subtitle: 'Submit a new business for admin approval',
              onTap: () => _showNewBusinessRequestSheet(context, ref),
            ),
            const SizedBox(height: 8),
            _ProfileMenuItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              iconColor: AppColors.error,
              titleColor: AppColors.error,
              onTap: () => _showLogoutDialog(context, ref),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showNewBusinessRequestSheet(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _NewBusinessRequestSheet(
        currentUser: currentUser,
        nameCtrl: nameCtrl,
        descCtrl: descCtrl,
        emailCtrl: emailCtrl,
        addressCtrl: addressCtrl,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request submitted! Awaiting admin approval.'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      descCtrl.dispose();
      emailCtrl.dispose();
      addressCtrl.dispose();
    });
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// NEW BUSINESS REQUEST SHEET
// ============================================================================
class _NewBusinessRequestSheet extends StatefulWidget {
  final dynamic currentUser;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;
  final VoidCallback onSuccess;

  const _NewBusinessRequestSheet({
    required this.currentUser,
    required this.nameCtrl,
    required this.descCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
    required this.onSuccess,
  });

  @override
  State<_NewBusinessRequestSheet> createState() =>
      _NewBusinessRequestSheetState();
}

class _NewBusinessRequestSheetState extends State<_NewBusinessRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _completePhone; // full E.164 phone e.g. +96512345678
  bool _submitting = false;
  String? _errorMsg;

  Future<void> _submit() async {
    setState(() => _errorMsg = null);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() => _errorMsg = 'Please select a category.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final doc = FirebaseFirestore.instance
          .collection(FirestoreCollections.businessRequests)
          .doc();
      final request = BusinessRequestModel(
        id: doc.id,
        supplierId: widget.currentUser.id as String,
        supplierName: widget.currentUser.name as String,
        businessName: widget.nameCtrl.text.trim(),
        description: widget.descCtrl.text.trim(),
        category: _selectedCategory,
        contactEmail: widget.emailCtrl.text.trim().isEmpty
            ? null
            : widget.emailCtrl.text.trim(),
        contactPhone: _completePhone,
        address: widget.addressCtrl.text.trim().isEmpty
            ? null
            : widget.addressCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await doc.set(request.toFirestore());
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _errorMsg = 'Failed to submit: $e';
        });
      }
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMutedDark),
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.supplierColor),
      ),
      errorStyle: const TextStyle(color: AppColors.error),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const Text(
                'Request New Business',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your request will be reviewed by an admin.',
                style:
                    TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
              ),
              const SizedBox(height: 20),
              _label('Business Name'),
              TextFormField(
                controller: widget.nameCtrl,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: _inputDecoration('Enter business name'),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _label('Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.cardDark,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: _inputDecoration('Select category'),
                items: SupplierCategories.all
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 16),
              _label('Description'),
              TextFormField(
                controller: widget.descCtrl,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                maxLines: 3,
                decoration: _inputDecoration('Describe your business'),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _label('Contact Email (optional)'),
              TextFormField(
                controller: widget.emailCtrl,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('business@example.com'),
              ),
              const SizedBox(height: 16),
              _label('Contact Phone (optional)'),
              IntlPhoneField(
                initialCountryCode: 'KW',
                style: const TextStyle(color: AppColors.textPrimaryDark),
                dropdownTextStyle:
                    const TextStyle(color: AppColors.textPrimaryDark),
                dropdownIcon: const Icon(Icons.arrow_drop_down,
                    color: AppColors.textSecondaryDark),
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  hintStyle:
                      const TextStyle(color: AppColors.textMutedDark),
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.supplierColor),
                  ),
                ),
                onChanged: (phone) {
                  _completePhone =
                      phone.number.isEmpty ? null : phone.completeNumber;
                },
                invalidNumberMessage: null, // optional field — skip validation
              ),
              const SizedBox(height: 16),
              _label('Address (optional)'),
              TextFormField(
                controller: widget.addressCtrl,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: _inputDecoration('City, Country'),
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.supplierColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey800),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.supplierColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.supplierColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: iconColor ?? AppColors.grey600,
        ),
      ),
    );
  }
}
