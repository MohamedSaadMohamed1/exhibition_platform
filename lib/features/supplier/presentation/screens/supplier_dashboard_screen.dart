import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/widgets/role_dashboard_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SupplierDashboardScreen extends ConsumerStatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  ConsumerState<SupplierDashboardScreen> createState() => _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends ConsumerState<SupplierDashboardScreen> {
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
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(currentUser: currentUser),
          const _ServicesTab(),
          const _OrdersTab(),
          const _MessagesTab(),
          const _ProfileTab(),
        ],
      ),
    );
  }
}

// Dashboard Tab
class _DashboardTab extends ConsumerWidget {
  final dynamic currentUser;

  const _DashboardTab({this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.supplierColor,
                    AppColors.supplierColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: currentUser?.profileImage != null
                        ? NetworkImage(currentUser.profileImage)
                        : null,
                    child: currentUser?.profileImage == null
                        ? Text(
                            currentUser?.name.isNotEmpty == true
                                ? currentUser.name[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
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
                        Text(
                          currentUser?.name ?? 'Supplier',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats Grid
            const Text(
              'Overview',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _StatCard(
                  title: 'Active Services',
                  value: '12',
                  icon: Icons.inventory_2,
                  color: AppColors.supplierColor,
                ),
                _StatCard(
                  title: 'Pending Orders',
                  value: '5',
                  icon: Icons.pending_actions,
                  color: AppColors.warning,
                ),
                _StatCard(
                  title: 'Completed',
                  value: '48',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
                _StatCard(
                  title: 'This Month',
                  value: '\$2.4k',
                  icon: Icons.trending_up,
                  color: AppColors.info,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _OrderItem(
              orderId: 'ORD-001',
              serviceName: 'Premium Booth Setup',
              customerName: 'Tech Summit 2026',
              status: 'Pending',
              statusColor: AppColors.warning,
            ),
            _OrderItem(
              orderId: 'ORD-002',
              serviceName: 'Audio Equipment',
              customerName: 'Food Expo Kuwait',
              status: 'Confirmed',
              statusColor: AppColors.success,
            ),
            const SizedBox(height: 100), // Space for nav
          ],
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final String orderId;
  final String serviceName;
  final String customerName;
  final String status;
  final Color statusColor;

  const _OrderItem({
    required this.orderId,
    required this.serviceName,
    required this.customerName,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey800),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$customerName - $orderId',
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Services Tab
class _ServicesTab extends StatelessWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Services - Coming Soon',
        style: TextStyle(color: AppColors.textSecondaryDark),
      ),
    );
  }
}

// Orders Tab
class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Orders - Coming Soon',
        style: TextStyle(color: AppColors.textSecondaryDark),
      ),
    );
  }
}

// Messages Tab
class _MessagesTab extends ConsumerWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  icon: const Icon(Icons.search, color: AppColors.textSecondaryDark),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No messages yet',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Tab
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
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.supplierColor.withOpacity(0.2),
              backgroundImage: currentUser?.profileImage != null
                  ? NetworkImage(currentUser!.profileImage!)
                  : null,
              child: currentUser?.profileImage == null
                  ? Text(
                      currentUser?.name.isNotEmpty == true
                          ? currentUser!.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: AppColors.supplierColor,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
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
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.supplierColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'SUPPLIER',
                style: TextStyle(
                  color: AppColors.supplierColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Menu Items
            _ProfileMenuItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            _ProfileMenuItem(
              icon: Icons.store,
              title: 'Business Settings',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: AppColors.error,
              titleColor: AppColors.error,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surfaceDark,
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
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(authNotifierProvider.notifier).signOut();
                        },
                        child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey800),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.textSecondaryDark),
        title: Text(
          title,
          style: TextStyle(color: titleColor ?? AppColors.textPrimaryDark),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey600),
        onTap: onTap,
      ),
    );
  }
}
