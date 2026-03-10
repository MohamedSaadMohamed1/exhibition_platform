import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/widgets/role_dashboard_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OrganizerDashboardScreen extends ConsumerStatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  ConsumerState<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends ConsumerState<OrganizerDashboardScreen> {
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
      const NavItem(icon: Icons.event_rounded, label: 'Events'),
      const NavItem(icon: Icons.bookmark_rounded, label: 'Bookings'),
      const NavItem(icon: Icons.chat_rounded, label: 'Messages'),
      const NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return RoleDashboardShell(
      currentIndex: _currentIndex,
      navItems: navItems,
      onNavTap: _onNavTap,
      accentColor: AppColors.organizerColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(currentUser: currentUser),
          const _EventsTab(),
          const _BookingsTab(),
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
                    AppColors.organizerColor,
                    AppColors.organizerColor.withOpacity(0.7),
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
                                : 'O',
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
                          currentUser?.name ?? 'Organizer',
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
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'New Event',
                    color: AppColors.organizerColor,
                    onTap: () => context.push(AppRoutes.organizerCreateExhibition),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan Entry',
                    color: AppColors.secondary,
                    onTap: () {},
                  ),
                ),
              ],
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
                  title: 'Active Events',
                  value: '3',
                  icon: Icons.event,
                  color: AppColors.organizerColor,
                ),
                _StatCard(
                  title: 'Total Booths',
                  value: '156',
                  icon: Icons.grid_view,
                  color: AppColors.info,
                ),
                _StatCard(
                  title: 'Bookings',
                  value: '89',
                  icon: Icons.bookmark,
                  color: AppColors.success,
                ),
                _StatCard(
                  title: 'Revenue',
                  value: '\$45k',
                  icon: Icons.trending_up,
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Upcoming Events
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
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
            _EventItem(
              title: 'Tech Summit Kuwait 2026',
              date: 'Mar 15-18, 2026',
              booths: '45/150 booked',
              progress: 0.3,
            ),
            _EventItem(
              title: 'Food & Beverage Expo',
              date: 'Apr 5-8, 2026',
              booths: '120/200 booked',
              progress: 0.6,
            ),
            const SizedBox(height: 100), // Space for nav
          ],
        ),
      ),
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
                fontWeight: FontWeight.w600,
              ),
            ),
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

class _EventItem extends StatelessWidget {
  final String title;
  final String date;
  final String booths;
  final double progress;

  const _EventItem({
    required this.title,
    required this.date,
    required this.booths,
    required this.progress,
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
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey600),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.grey800,
                    valueColor: AlwaysStoppedAnimation(
                      progress > 0.7 ? AppColors.success : AppColors.organizerColor,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                booths,
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

// Events Tab
class _EventsTab extends StatelessWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Events Management - Coming Soon',
        style: TextStyle(color: AppColors.textSecondaryDark),
      ),
    );
  }
}

// Bookings Tab
class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Bookings Management - Coming Soon',
        style: TextStyle(color: AppColors.textSecondaryDark),
      ),
    );
  }
}

// Messages Tab
class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
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
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.organizerColor.withOpacity(0.2),
              backgroundImage: currentUser?.profileImage != null
                  ? NetworkImage(currentUser!.profileImage!)
                  : null,
              child: currentUser?.profileImage == null
                  ? Text(
                      currentUser?.name.isNotEmpty == true
                          ? currentUser!.name[0].toUpperCase()
                          : 'O',
                      style: const TextStyle(
                        color: AppColors.organizerColor,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              currentUser?.name ?? 'Organizer',
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
                color: AppColors.organizerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ORGANIZER',
                style: TextStyle(
                  color: AppColors.organizerColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _ProfileMenuItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            _ProfileMenuItem(
              icon: Icons.business,
              title: 'Organization Settings',
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
