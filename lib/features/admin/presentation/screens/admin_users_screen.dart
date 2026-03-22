import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/models/user_model.dart';
import '../providers/admin_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  void _onTabChanged(int index) {
    final role = [null, UserRole.organizer, UserRole.supplier, UserRole.exhibitor][index];
    ref.read(adminUsersNotifierProvider.notifier).filterByRole(role);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Organizers'),
            Tab(text: 'Suppliers'),
            Tab(text: 'Exhibitors'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(adminUsersNotifierProvider.notifier).refresh();
        },
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(AdminUsersState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null && state.users.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(adminUsersNotifierProvider.notifier).refresh(),
      );
    }

    if (state.users.isEmpty) {
      return const EmptyStateWidget(
        title: 'No users found',
        icon: Icons.people_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.users.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.users.length) {
          // Trigger load more when reaching the end
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(adminUsersNotifierProvider.notifier).loadMore();
          });
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.users[index];
        return _UserCard(
          user: user,
          onActivate: () => _activateUser(user.id),
          onDeactivate: () => _deactivateUser(user.id),
        );
      },
    );
  }

  Future<void> _activateUser(String userId) async {
    await ref.read(adminUsersNotifierProvider.notifier).activateUser(userId);
  }

  Future<void> _deactivateUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: const Text('Are you sure you want to deactivate this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(adminUsersNotifierProvider.notifier).deactivateUser(userId);
    }
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  const _UserCard({
    required this.user,
    required this.onActivate,
    required this.onDeactivate,
  });

  Color get _roleColor {
    switch (user.role) {
      case UserRole.admin:
        return AppColors.adminColor;
      case UserRole.owner:
        return AppColors.ownerColor;
      case UserRole.organizer:
        return AppColors.organizerColor;
      case UserRole.supplier:
        return AppColors.supplierColor;
      case UserRole.exhibitor:
        return AppColors.exhibitorColor;
      case UserRole.visitor:
        return AppColors.visitorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _roleColor.withOpacity(0.2),
              backgroundImage: user.profileImage != null
                  ? NetworkImage(user.profileImage!)
                  : null,
              child: user.profileImage == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: _roleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name.isNotEmpty ? user.name : 'No name',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.value.toUpperCase(),
                          style: TextStyle(
                            color: _roleColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  if (user.email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.email!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            // Status & Actions
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? AppColors.successLight
                        : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: user.isActive ? AppColors.success : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (user.role != UserRole.admin)
                  IconButton(
                    icon: Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      color: user.isActive ? AppColors.error : AppColors.success,
                      size: 20,
                    ),
                    onPressed: user.isActive ? onDeactivate : onActivate,
                    tooltip: user.isActive ? 'Deactivate' : 'Activate',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
