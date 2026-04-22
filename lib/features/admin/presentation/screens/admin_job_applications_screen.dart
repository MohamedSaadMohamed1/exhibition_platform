import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_job_applications_provider.dart';

class AdminJobApplicationsScreen extends ConsumerStatefulWidget {
  const AdminJobApplicationsScreen({super.key});

  @override
  ConsumerState<AdminJobApplicationsScreen> createState() =>
      _AdminJobApplicationsScreenState();
}

class _AdminJobApplicationsScreenState
    extends ConsumerState<AdminJobApplicationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminJobApplicationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminJobApplicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Job Applications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(
            selected: state.statusFilter,
            onSelected: (status) => ref
                .read(adminJobApplicationsProvider.notifier)
                .filterByStatus(status),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? _ErrorView(
                        message: state.errorMessage!,
                        onRetry: () => ref
                            .read(adminJobApplicationsProvider.notifier)
                            .refresh(),
                      )
                    : state.applications.isEmpty
                        ? const _EmptyView()
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(adminJobApplicationsProvider.notifier)
                                .refresh(),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: state.applications.length + 1,
                              itemBuilder: (context, index) {
                                if (index == state.applications.length) {
                                  if (state.isLoadingMore) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }
                                  if (!state.hasMore) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Center(
                                        child: Text(
                                          'No more applications',
                                          style: TextStyle(
                                            color: AppColors.textSecondaryDark,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }

                                final app = state.applications[index];
                                return _ApplicationCard(
                                  application: app,
                                  onUpdateStatus: (status, feedback) {
                                    ref
                                        .read(adminJobApplicationsProvider
                                            .notifier)
                                        .updateApplicationStatus(
                                          applicationId: app.id,
                                          status: status,
                                          feedback: feedback,
                                        );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  final String? selected;
  final void Function(String?) onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final filters = <String?>[null, 'pending', 'reviewed', 'accepted', 'rejected'];
    final labels = <String?>['All', 'Pending', 'Reviewed', 'Accepted', 'Rejected'];

    return Container(
      color: AppColors.surfaceDark,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final isSelected = selected == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labels[i]!),
              selected: isSelected,
              onSelected: (_) => onSelected(filters[i]),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.backgroundDark,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Application card
// ---------------------------------------------------------------------------

class _ApplicationCard extends StatelessWidget {
  final AdminJobApplication application;
  final void Function(String status, String? feedback) onUpdateStatus;

  const _ApplicationCard({
    required this.application,
    required this.onUpdateStatus,
  });

  Color _statusColor(String? status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'reviewed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(application.status);

    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + status badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (application.position.isNotEmpty)
                        Text(
                          application.position,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.statusDisplayText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (application.email.isNotEmpty)
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: application.email,
              ),
            if (application.phone.isNotEmpty)
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: application.phone,
              ),
            if (application.coverLetter != null &&
                application.coverLetter!.isNotEmpty)
              _InfoRow(
                icon: Icons.description_outlined,
                label: 'Cover Letter',
                value: application.coverLetter!,
              ),
            _CvLinkRow(url: application.resumeUrl),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Applied',
              value:
                  '${application.createdAt.day}/${application.createdAt.month}/${application.createdAt.year}',
            ),
            if (application.feedback != null &&
                application.feedback!.isNotEmpty)
              _InfoRow(
                icon: Icons.feedback_outlined,
                label: 'Feedback',
                value: application.feedback!,
              ),
            // Action buttons for pending/reviewed
            if (application.isPending || application.isReviewed) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall =
                      constraints.maxWidth < 400 && application.isPending;
                  if (isSmall) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: () => onUpdateStatus('reviewed', null),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            textStyle: const TextStyle(fontSize: 10),
                          ),
                          child: const Text('Reviewed'),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    onUpdateStatus('accepted', null),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: const Text('Accept'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showRejectDialog(context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      if (application.isPending) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => onUpdateStatus('reviewed', null),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              textStyle: const TextStyle(fontSize: 10),
                            ),
                            child: const Text('Reviewed'),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => onUpdateStatus('accepted', null),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showRejectDialog(context),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Reject Application',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Feedback (optional)',
            hintStyle: TextStyle(color: AppColors.textSecondaryDark),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey600)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onUpdateStatus(
                'rejected',
                controller.text.trim().isEmpty ? null : controller.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryDark),
          const SizedBox(width: 6),
          Text('$label: ',
              style:
                  TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 3),
          ),
        ],
      ),
    );
  }
}

class _CvLinkRow extends StatelessWidget {
  final String? url;
  const _CvLinkRow({required this.url});

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            size: 14,
            color: hasUrl ? AppColors.primary : AppColors.textSecondaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            'CV: ',
            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
          ),
          if (hasUrl)
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(url!);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: const Text(
                'View / Download CV',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            )
          else
            Text(
              'No CV uploaded',
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 64, color: AppColors.grey600),
          const SizedBox(height: 16),
          Text('No job applications found',
              style:
                  TextStyle(color: AppColors.textSecondaryDark, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message,
              style:
                  TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
