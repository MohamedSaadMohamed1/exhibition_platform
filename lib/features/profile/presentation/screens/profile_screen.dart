import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,

      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        actionsIconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push(AppRoutes.editProfile);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Profile Card
            Card(
              color: AppColors.surfaceDark,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      backgroundImage: currentUser.profileImage != null
                          ? NetworkImage(currentUser.profileImage!)
                          : null,
                      child: currentUser.profileImage == null
                          ? Text(
                              currentUser.name.isNotEmpty
                                  ? currentUser.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      currentUser.name,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(currentUser.role).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentUser.role.value.toUpperCase(),
                        style: TextStyle(
                          color: _getRoleColor(currentUser.role),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Info Card
            Card(
              color: AppColors.surfaceDark,
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.phone,
                    title: 'Phone',
                    value: currentUser.phone,
                  ),
                  if (currentUser.email != null)
                    _InfoTile(
                      icon: Icons.email,
                      title: 'Email',
                      value: currentUser.email!,
                    ),
                  _InfoTile(
                    icon: Icons.calendar_today,
                    title: 'Member Since',
                    value: _formatDate(currentUser.createdAt),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Menu
            Card(
              color: AppColors.surfaceDark,
              child: Column(
                children: [
                  if (currentUser.canBookBooths)
                    _MenuTile(
                      icon: Icons.bookmark,
                      title: 'My Bookings',
                      onTap: () => context.push(AppRoutes.myBookings),
                    ),
                  if (currentUser.canBookBooths)
                    _MenuTile(
                      icon: Icons.favorite,
                      title: 'Interested Events',
                      onTap: () {},
                    ),
                  _MenuTile(
                    icon: Icons.chat,
                    title: 'Messages',
                    onTap: () => context.push(AppRoutes.chats),
                  ),
                  _MenuTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {},
                  ),
                  _MenuTile(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Logout
            Card(
              color: AppColors.surfaceDark,
              child: _MenuTile(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: AppColors.surfaceDark,
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(color: AppColors.textSecondaryDark),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final authState = ref.watch(authNotifierProvider);
                            return TextButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () async {
                                      await ref.read(authNotifierProvider.notifier).signOut();
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                                      ),
                                    )
                                  : const Text('Logout'),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(dynamic role) {
    switch (role.value) {
      case 'admin':
        return AppColors.adminColor;
      case 'owner':
        return AppColors.ownerColor;
      case 'organizer':
        return AppColors.organizerColor;
      case 'supplier':
        return AppColors.supplierColor;
      case 'visitor':
      default:
        return AppColors.visitorColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white60),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white70),
      title: Text(
        title,
        style: TextStyle(color: titleColor ?? Colors.white),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white54,
      ),
      onTap: onTap,
    );
  }
}