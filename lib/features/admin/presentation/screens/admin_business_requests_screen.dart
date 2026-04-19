import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/business_request_model.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/admin_business_requests_provider.dart';

class AdminBusinessRequestsScreen extends ConsumerWidget {
  const AdminBusinessRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminBusinessRequestsProvider);

    ref.listen(adminBusinessRequestsProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Business Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(adminBusinessRequestsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(
            current: state.statusFilter,
            onChanged: (filter) => ref
                .read(adminBusinessRequestsProvider.notifier)
                .setStatusFilter(filter),
          ),
          Expanded(
            child: state.isLoading && state.requests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.filteredRequests.isEmpty
                    ? _buildEmpty(state.statusFilter)
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.filteredRequests.length,
                        itemBuilder: (context, i) {
                          final request = state.filteredRequests[i];
                          return _RequestCard(request: request);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String? filter) {
    final label = filter == null
        ? 'No Business Requests'
        : 'No ${_statusLabel(filter)} Requests';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business_center_outlined,
              size: 64, color: AppColors.textSecondaryDark),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Supplier business creation requests will appear here.',
            style: TextStyle(color: AppColors.textSecondaryDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}

class _FilterChips extends StatelessWidget {
  final String? current;
  final ValueChanged<String?> onChanged;

  const _FilterChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = <String?, String>{
      null: 'All',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
    };

    return Container(
      color: AppColors.surfaceDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.entries.map((e) {
            final selected = current == e.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(e.value),
                selected: selected,
                onSelected: (_) => onChanged(e.key),
                selectedColor: AppColors.supplierColor.withOpacity(0.25),
                checkmarkColor: AppColors.supplierColor,
                labelStyle: TextStyle(
                  color: selected
                      ? AppColors.supplierColor
                      : AppColors.textSecondaryDark,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppColors.backgroundDark,
                side: BorderSide(
                  color:
                      selected ? AppColors.supplierColor : Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  final BusinessRequestModel request;
  const _RequestCard({required this.request});

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _expanded = false;
  bool _processing = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondaryDark;
    }
  }

  Future<void> _approve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Approve Request',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Approve "${widget.request.businessName}"? This will create a new supplier profile.',
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final adminId =
        ref.read(currentUserProvider).valueOrNull?.id ?? 'unknown';
    setState(() => _processing = true);
    final success = await ref
        .read(adminBusinessRequestsProvider.notifier)
        .approveRequest(widget.request.id, adminId);
    if (mounted) {
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Business approved and supplier profile created.'
              : 'Failed to approve request.'),
          backgroundColor: success ? Colors.green : AppColors.error,
        ),
      );
    }
  }

  Future<void> _reject() async {
    final notesController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Request',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject "${widget.request.businessName}"?',
              style: const TextStyle(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                hintStyle:
                    const TextStyle(color: AppColors.textSecondaryDark),
                filled: true,
                fillColor: AppColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final adminId =
        ref.read(currentUserProvider).valueOrNull?.id ?? 'unknown';
    setState(() => _processing = true);
    final success = await ref
        .read(adminBusinessRequestsProvider.notifier)
        .rejectRequest(widget.request.id, adminId,
            adminNotes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim());
    notesController.dispose();
    if (mounted) {
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Request rejected.' : 'Failed to reject.'),
          backgroundColor: success ? Colors.orange : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final dateStr =
        DateFormat('MMM d, yyyy – h:mm a').format(r.createdAt.toLocal());

    return Card(
      color: AppColors.cardDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.supplierColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business_center_outlined,
                        color: AppColors.supplierColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.businessName,
                          style: const TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'By ${r.supplierName}',
                          style: const TextStyle(
                              color: AppColors.textSecondaryDark,
                              fontSize: 13),
                        ),
                        if (r.category != null)
                          Text(
                            r.category!,
                            style: const TextStyle(
                                color: AppColors.textMutedDark, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(r.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          r.status[0].toUpperCase() + r.status.substring(1),
                          style: TextStyle(
                            color: _statusColor(r.status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondaryDark,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_expanded)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.grey800),
                  const SizedBox(height: 8),
                  _detail('Submitted', dateStr),
                  if (r.description.isNotEmpty)
                    _detail('Description', r.description),
                  if (r.contactEmail != null)
                    _detail('Email', r.contactEmail!),
                  if (r.contactPhone != null)
                    _detail('Phone', r.contactPhone!),
                  if (r.address != null) _detail('Address', r.address!),
                  if (r.website != null) _detail('Website', r.website!),
                  if (r.adminNotes != null && r.adminNotes!.isNotEmpty)
                    _detail('Admin Notes', r.adminNotes!, highlight: true),
                  if (r.reviewedAt != null)
                    _detail(
                      'Reviewed',
                      DateFormat('MMM d, yyyy')
                          .format(r.reviewedAt!.toLocal()),
                    ),
                  if (r.status == 'pending') ...[
                    const SizedBox(height: 16),
                    _processing
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.error),
                                    foregroundColor: AppColors.error,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: _reject,
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: _approve,
                                  child: const Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: highlight ? Colors.orange : AppColors.textPrimaryDark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
