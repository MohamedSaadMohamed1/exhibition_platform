import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/job_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_job_applications_provider.dart';
import '../providers/admin_jobs_provider.dart';

class AdminJobsScreen extends ConsumerStatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  ConsumerState<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends ConsumerState<AdminJobsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(adminJobsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Jobs Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.adminColor,
          labelColor: AppColors.adminColor,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(
              text: 'Jobs (${jobsState.jobs.length})',
              icon: const Icon(Icons.work_outline, size: 18),
            ),
            const Tab(
              text: 'Applications',
              icon: Icon(Icons.assignment_outlined, size: 18),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _JobsTab(),
          _ApplicationsTab(),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          if (_tabController.index != 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showCreateJobSheet(context),
            backgroundColor: AppColors.adminColor,
            icon: const Icon(Icons.add),
            label: const Text('Add Job'),
          );
        },
      ),
    );
  }

  void _showCreateJobSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _CreateJobSheet(),
    );
  }
}

// ── Jobs tab ─────────────────────────────────────────────────────────
class _JobsTab extends ConsumerWidget {
  const _JobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminJobsProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(adminJobsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 64, color: AppColors.grey600),
            const SizedBox(height: 16),
            const Text(
              'No jobs yet',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to create the first job posting',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminJobsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.jobs.length,
        itemBuilder: (context, i) => _JobCard(job: state.jobs[i]),
      ),
    );
  }
}

// ── Job card ─────────────────────────────────────────────────────────
class _JobCard extends ConsumerWidget {
  final JobModel job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(adminJobsProvider.notifier);

    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _StatusBadge(isOpen: job.isOpen),
              ],
            ),
            if (job.eventTitle != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.event, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    job.eventTitle!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            // Info row
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (job.jobType != null)
                  _InfoChip(Icons.schedule, job.jobType!),
                if (job.location != null)
                  _InfoChip(Icons.location_on, job.location!),
                _InfoChip(Icons.people, '${job.applicationsCount} applicants'),
                _InfoChip(
                  Icons.timer,
                  job.isDeadlinePassed
                      ? 'Deadline passed'
                      : '${job.daysUntilDeadline}d left',
                  color: job.isDeadlinePassed ? AppColors.error : AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (job.isOpen)
                  TextButton.icon(
                    onPressed: () async {
                      await notifier.closeJob(job.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Job closed')),
                        );
                      }
                    },
                    icon: const Icon(Icons.lock_outline, size: 16),
                    label: const Text('Close'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.warning,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () async {
                      await notifier.reopenJob(job.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Job reopened')),
                        );
                      }
                    },
                    icon: const Icon(Icons.lock_open_outlined, size: 16),
                    label: const Text('Reopen'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                    ),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, notifier),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminJobsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Delete Job', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${job.title}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await notifier.deleteJob(job.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isOpen ? AppColors.success : AppColors.grey600).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          color: isOpen ? AppColors.success : AppColors.grey500,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondaryDark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: c, fontSize: 12)),
      ],
    );
  }
}

// ── Applications tab (reuses existing provider) ───────────────────────
class _ApplicationsTab extends ConsumerStatefulWidget {
  const _ApplicationsTab();

  @override
  ConsumerState<_ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends ConsumerState<_ApplicationsTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(adminJobApplicationsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminJobApplicationsProvider);

    return Column(
      children: [
        _FilterBar(
          selected: state.statusFilter,
          onSelected: (s) =>
              ref.read(adminJobApplicationsProvider.notifier).filterByStatus(s),
        ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text(state.errorMessage!,
                              style: const TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(adminJobApplicationsProvider.notifier)
                                .refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : state.applications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 64, color: AppColors.grey600),
                              const SizedBox(height: 16),
                              const Text('No applications found',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 16)),
                            ],
                          ),
                        )
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
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                              final app = state.applications[index];
                              return _AppCard(
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
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String? selected;
  final void Function(String?) onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const filters = <String?>[null, 'pending', 'reviewed', 'accepted', 'rejected'];
    const labels = <String>['All', 'Pending', 'Reviewed', 'Accepted', 'Rejected'];

    const filterColors = <String?, Color>{
      null: AppColors.adminColor,
      'pending': Colors.orange,
      'reviewed': Colors.blue,
      'accepted': Colors.green,
      'rejected': Colors.red,
    };

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
              label: Text(labels[i]),
              selected: isSelected,
              onSelected: (_) => onSelected(filters[i]),
              selectedColor: filterColors[filters[i]] ?? AppColors.adminColor,
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

class _AppCard extends StatelessWidget {
  final AdminJobApplication application;
  final void Function(String status, String? feedback) onUpdateStatus;

  const _AppCard({required this.application, required this.onUpdateStatus});

  Color _statusColor(String? s) {
    switch (s) {
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
    final color = _statusColor(application.status);
    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.fullName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      if (application.position.isNotEmpty)
                        Text(application.position,
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(application.statusDisplayText,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (application.email.isNotEmpty)
              _Row(Icons.email_outlined, application.email),
            if (application.phone.isNotEmpty)
              _Row(Icons.phone_outlined, application.phone),
            if (application.coverLetter?.isNotEmpty == true)
              _Row(Icons.description_outlined, application.coverLetter!),
            _Row(Icons.calendar_today_outlined,
                '${application.createdAt.day}/${application.createdAt.month}/${application.createdAt.year}'),
            if (application.feedback?.isNotEmpty == true)
              _Row(Icons.feedback_outlined, application.feedback!),
            if (application.isPending || application.isReviewed) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              Row(
                children: [
                  if (application.isPending)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onUpdateStatus('reviewed', null),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue)),
                        child: const Text('Reviewed'),
                      ),
                    ),
                  if (application.isPending) const SizedBox(width: 8),
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
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Reject'),
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

  void _showRejectDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Reject Application',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
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
              onUpdateStatus('rejected',
                  ctrl.text.trim().isEmpty ? null : ctrl.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String value;
  const _Row(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryDark),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── Create Job bottom sheet ──────────────────────────────────────────
class _CreateJobSheet extends ConsumerStatefulWidget {
  const _CreateJobSheet();

  @override
  ConsumerState<_CreateJobSheet> createState() => _CreateJobSheetState();
}

class _CreateJobSheetState extends ConsumerState<_CreateJobSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _reqCtrl = TextEditingController();

  String? _selectedJobType;
  EventSummary? _selectedEvent;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  final List<String> _requirements = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _reqCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(adminEventsPickerProvider);
    final jobsState = ref.watch(adminJobsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
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
              const SizedBox(height: 16),
              const Text(
                'Create New Job',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              _FormField(
                label: 'Job Title *',
                child: TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('e.g. Event Coordinator'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),

              // Event selector
              _FormField(
                label: 'Event (Optional)',
                child: eventsAsync.when(
                  data: (events) => DropdownButtonFormField<EventSummary>(
                    value: _selectedEvent,
                    dropdownColor: AppColors.cardDark,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Select event'),
                    items: [
                      const DropdownMenuItem<EventSummary>(
                        value: null,
                        child: Text('No event', style: TextStyle(color: Colors.white54)),
                      ),
                      ...events.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.title,
                                style: const TextStyle(color: Colors.white)),
                          )),
                    ],
                    onChanged: (e) => setState(() => _selectedEvent = e),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Failed to load events: $e',
                      style: const TextStyle(color: AppColors.error)),
                ),
              ),

              // Description
              _FormField(
                label: 'Description *',
                child: TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Job description...'),
                  maxLines: 4,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),

              // Job type
              _FormField(
                label: 'Job Type',
                child: DropdownButtonFormField<String>(
                  value: _selectedJobType,
                  dropdownColor: AppColors.cardDark,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Select type'),
                  items: JobTypes.all
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t,
                                style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedJobType = v),
                ),
              ),

              // Location + Salary in row
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Location',
                      child: TextFormField(
                        controller: _locationCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('e.g. Dubai'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      label: 'Salary',
                      child: TextFormField(
                        controller: _salaryCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('e.g. KD 500/month'),
                      ),
                    ),
                  ),
                ],
              ),

              // Deadline
              _FormField(
                label: 'Application Deadline *',
                child: InkWell(
                  onTap: _pickDeadline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: AppColors.textSecondaryDark),
                        const SizedBox(width: 8),
                        Text(
                          '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Requirements
              _FormField(
                label: 'Requirements',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _reqCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Add a requirement'),
                            onFieldSubmitted: (_) => _addRequirement(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addRequirement,
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.adminColor),
                        ),
                      ],
                    ),
                    if (_requirements.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _requirements
                            .map((r) => Chip(
                                  label: Text(r,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  backgroundColor: AppColors.cardDark,
                                  deleteIcon: const Icon(Icons.close,
                                      size: 14, color: Colors.white54),
                                  onDeleted: () => setState(
                                      () => _requirements.remove(r)),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: jobsState.isCreating ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: jobsState.isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Job',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _addRequirement() {
    final text = _reqCtrl.text.trim();
    if (text.isNotEmpty && !_requirements.contains(text)) {
      setState(() => _requirements.add(text));
      _reqCtrl.clear();
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.adminColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull ??
        ref.read(authNotifierProvider).user;

    final success = await ref.read(adminJobsProvider.notifier).createJob(
          adminId: currentUser?.id ?? 'admin',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          eventId: _selectedEvent?.id ?? '',
          eventTitle: _selectedEvent?.title,
          deadline: _deadline,
          jobType: _selectedJobType,
          location: _locationCtrl.text.trim().isEmpty
              ? null
              : _locationCtrl.text.trim(),
          salary: _salaryCtrl.text.trim().isEmpty
              ? null
              : _salaryCtrl.text.trim(),
          requirements: List.from(_requirements),
        );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(adminJobsProvider).errorMessage ?? 'Failed to create job',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.adminColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      );
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
