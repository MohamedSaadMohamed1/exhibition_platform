import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/admin_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatsAsync = ref.watch(userStatsProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: AppColors.surfaceDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.adminColor,
                        child: Text(
                          currentUser?.name.isNotEmpty == true
                              ? currentUser!.name[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
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
                                color: AppColors.textSecondaryDark,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              currentUser?.name ?? 'Admin',
                              style: TextStyle(
                                color: AppColors.textPrimaryDark,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.adminColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
                            color: AppColors.adminColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Stats
              const Text(
                'User Statistics',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              userStatsAsync.when(
                data: (stats) => GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                      title: 'Total Users',
                      value: stats.totalUsers.toString(),
                      icon: Icons.people,
                      color: AppColors.primary,
                    ),
                    _StatCard(
                      title: 'Organizers',
                      value: stats.totalOrganizers.toString(),
                      icon: Icons.business,
                      color: AppColors.organizerColor,
                    ),
                    _StatCard(
                      title: 'Suppliers',
                      value: stats.totalSuppliers.toString(),
                      icon: Icons.store,
                      color: AppColors.supplierColor,
                    ),
                    _StatCard(
                      title: 'Visitors',
                      value: stats.totalVisitors.toString(),
                      icon: Icons.person,
                      color: AppColors.visitorColor,
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Text('Error: $error'),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'Create Organizer',
                subtitle: 'Add a new event organizer account',
                icon: Icons.person_add,
                color: AppColors.organizerColor,
                onTap: () => context.push(AppRoutes.adminCreateOrganizer),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'Create Supplier',
                subtitle: 'Add a new supplier account',
                icon: Icons.store,
                color: AppColors.supplierColor,
                onTap: () => context.push(AppRoutes.adminCreateSupplier),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'Manage Users',
                subtitle: 'View and manage all users',
                icon: Icons.people,
                color: AppColors.primary,
                onTap: () => context.push(AppRoutes.adminUsers),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'Account Requests',
                subtitle: 'Approve or reject organizer and supplier requests',
                icon: Icons.assignment_ind,
                color: AppColors.warning,
                onTap: () => context.push(AppRoutes.adminAccountRequests),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'View Events',
                subtitle: 'Browse all events',
                icon: Icons.event,
                color: AppColors.secondary,
                onTap: () => context.push(AppRoutes.events),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'All Orders',
                subtitle: 'Monitor all service orders on the platform',
                icon: Icons.receipt_long,
                color: AppColors.primary,
                onTap: () => context.push(AppRoutes.adminOrders),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'All Bookings',
                subtitle: 'View all booth booking requests',
                icon: Icons.bookmark_outlined,
                color: AppColors.organizerColor,
                onTap: () => context.push(AppRoutes.adminBookings),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'All Events',
                subtitle: 'View all events including drafts',
                icon: Icons.event_note,
                color: AppColors.supplierColor,
                onTap: () => context.push(AppRoutes.adminEvents),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'Jobs Management',
                subtitle: 'Post new jobs & review applications',
                icon: Icons.work_outline,
                color: AppColors.visitorColor,
                onTap: () => context.push(AppRoutes.adminJobs),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'Support Tickets',
                subtitle: 'View and respond to user support messages',
                icon: Icons.support_agent,
                color: AppColors.error,
                onTap: () => context.push(AppRoutes.adminSupportTickets),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'Business Requests',
                subtitle: 'Review new supplier business creation requests',
                icon: Icons.business_center_outlined,
                color: AppColors.supplierColor,
                onTap: () => context.push(AppRoutes.adminBusinessRequests),
              ),
            ],
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceDark,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.grey600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
