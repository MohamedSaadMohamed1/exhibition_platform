import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/account_request_model.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/admin_requests_provider.dart';
import '../providers/admin_provider.dart';

class AdminAccountRequestsScreen extends ConsumerStatefulWidget {
  const AdminAccountRequestsScreen({super.key});

  @override
  ConsumerState<AdminAccountRequestsScreen> createState() => _AdminAccountRequestsScreenState();
}

class _AdminAccountRequestsScreenState extends ConsumerState<AdminAccountRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminRequestsProvider);

    ref.listen(adminRequestsProvider, (previous, next) {
      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminRequestsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading && state.requests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.requests.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.requests.length,
                  itemBuilder: (context, index) {
                    final request = state.requests[index];
                    return _RequestCard(request: request);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondaryDark),
          const SizedBox(height: 16),
          Text(
            'No Account Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pending organizer and supplier requests will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondaryDark),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final AccountRequestModel request;

  const _RequestCard({required this.request});

  Future<void> _handleApprove(BuildContext context, WidgetRef ref) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Request?'),
        content: Text('This will create a new ${request.requestedRole.displayName} account for ${request.name}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Approve & Create'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // First create the actual user account
    bool userCreated = false;
    if (request.requestedRole == UserRole.organizer) {
      userCreated = await ref.read(adminUsersNotifierProvider.notifier).createOrganizer(
        name: request.name,
        phone: request.phone,
        email: request.email,
        adminId: currentUserId,
      );
    } else if (request.requestedRole == UserRole.supplier) {
      userCreated = await ref.read(adminUsersNotifierProvider.notifier).createSupplier(
        name: request.name,
        phone: request.phone,
        email: request.email,
        supplierName: request.companyName ?? request.name,
        supplierDescription: request.notes ?? 'Approved Supplier',
        services: [], // Needs to be filled later by supplier
        adminId: currentUserId,
      );
    }

    // If account creation was successful, mark the request as approved
    if (userCreated) {
      await ref.read(adminRequestsProvider.notifier).approveRequest(request.id, currentUserId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${request.name} is now a ${request.requestedRole.displayName}!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request?'),
        content: const Text('Are you sure you want to reject this account request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(adminRequestsProvider.notifier).rejectRequest(request.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = request.status == RequestStatus.pending;

    Color statusColor;
    switch (request.status) {
      case RequestStatus.pending:
        statusColor = AppColors.warning;
        break;
      case RequestStatus.approved:
        statusColor = AppColors.success;
        break;
      case RequestStatus.rejected:
        statusColor = AppColors.error;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      request.requestedRole == UserRole.organizer ? Icons.business : Icons.store,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      request.requestedRole.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    request.status.value.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(icon: Icons.person, title: 'Name', value: request.name),
            _InfoRow(icon: Icons.phone, title: 'Phone', value: request.phone),
            if (request.email != null) _InfoRow(icon: Icons.email, title: 'Email', value: request.email!),
            if (request.companyName != null) _InfoRow(icon: Icons.work, title: 'Company', value: request.companyName!),
            if (request.notes != null) _InfoRow(icon: Icons.note, title: 'Notes', value: request.notes!),
            
            const SizedBox(height: 8),
            Text(
              'Requested on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(request.createdAt)}',
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
            ),

            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: () => _handleReject(context, ref),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      onPressed: () => _handleApprove(context, ref),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondaryDark),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$title:',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
