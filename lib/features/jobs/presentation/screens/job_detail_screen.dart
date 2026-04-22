import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/models/job_model.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/job_provider.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _hasApplied = false;

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobProvider(widget.jobId));
    final currentUser = ref.watch(currentUserProvider).value;

    return jobAsync.when(
      data: (job) {
        if (job == null) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldDark,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
            ),
            body: const Center(
              child: Text(
                'Job not found',
                style: TextStyle(color: AppColors.textPrimaryDark),
              ),
            ),
          );
        }
        return _JobDetailContent(
          job: job,
          hasApplied: _hasApplied,
          currentUserId: currentUser?.id,
          onApply: () => _showApplicationSheet(context, job),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        ),
        body: const LoadingWidget(),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        ),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(jobProvider(widget.jobId)),
        ),
      ),
    );
  }

  void _showApplicationSheet(BuildContext context, JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ApplicationSheet(
        job: job,
        onSuccess: () => setState(() => _hasApplied = true),
      ),
    );
  }
}

class _JobDetailContent extends StatelessWidget {
  final JobModel job;
  final bool hasApplied;
  final String? currentUserId;
  final VoidCallback onApply;

  const _JobDetailContent({
    required this.job,
    required this.hasApplied,
    required this.currentUserId,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.cardDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            job.jobType ?? 'Full-time',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(),
                  const SizedBox(height: 20),

                  // Event Info
                  if (job.eventTitle != null) ...[
                    _InfoCard(
                      icon: Icons.event,
                      title: 'Event',
                      value: job.eventTitle!,
                      onTap: () => context.push('/events/${job.eventId}'),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Location
                  if (job.location != null) ...[
                    _InfoCard(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: job.location!,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Salary
                  if (job.salary != null) ...[
                    _InfoCard(
                      icon: Icons.attach_money,
                      title: 'Salary',
                      value: job.salary!,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Applications Count
                  _InfoCard(
                    icon: Icons.people_outline,
                    title: 'Applications',
                    value: '${job.applicationsCount} applicants',
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.description,
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Requirements
                  if (job.requirements.isNotEmpty) ...[
                    const Text(
                      'Requirements',
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...job.requirements.map((req) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  req,
                                  style: const TextStyle(
                                    color: AppColors.textSecondaryDark,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Deadline Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: job.isDeadlinePassed
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: job.isDeadlinePassed
                            ? AppColors.error.withOpacity(0.3)
                            : AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: job.isDeadlinePassed
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.isDeadlinePassed
                                    ? 'Application Closed'
                                    : 'Application Deadline',
                                style: TextStyle(
                                  color: job.isDeadlinePassed
                                      ? AppColors.error
                                      : AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatDeadline(job.deadline),
                                style: const TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!job.isDeadlinePassed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${job.daysUntilDeadline} days left',
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: _buildBottomButton(),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (job.isClosed) {
      statusColor = AppColors.error;
      statusText = 'Closed';
      statusIcon = Icons.cancel_outlined;
    } else if (job.isDeadlinePassed) {
      statusColor = AppColors.warning;
      statusText = 'Deadline Passed';
      statusIcon = Icons.schedule;
    } else {
      statusColor = AppColors.success;
      statusText = 'Accepting Applications';
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    if (hasApplied) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text(
              'Application Submitted',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final canApply = job.isAcceptingApplications;

    return ElevatedButton(
      onPressed: canApply ? onApply : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.grey600,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        canApply ? 'Apply Now' : 'Applications Closed',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[deadline.month - 1]} ${deadline.day}, ${deadline.year}';
  }
}

// ── Application bottom sheet ──────────────────────────────────────────
class _ApplicationSheet extends ConsumerStatefulWidget {
  final JobModel job;
  final VoidCallback onSuccess;

  const _ApplicationSheet({required this.job, required this.onSuccess});

  @override
  ConsumerState<_ApplicationSheet> createState() => _ApplicationSheetState();
}

class _ApplicationSheetState extends ConsumerState<_ApplicationSheet> {
  final _coverLetterController = TextEditingController();
  String? _cvFilePath;
  String? _cvFileName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _cvFilePath = result.files.single.path;
        _cvFileName = result.files.single.name;
      });
    }
  }

  Future<String?> _uploadCv(String jobId, String userId) async {
    if (_cvFilePath == null) return null;
    final file = File(_cvFilePath!);
    final ext = _cvFileName!.split('.').last;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('cv_uploads/$jobId/${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext');
    await storageRef.putFile(file);
    return await storageRef.getDownloadURL();
  }

  Future<void> _submit() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);
    try {
      String? resumeUrl;
      if (_cvFilePath != null) {
        resumeUrl = await _uploadCv(widget.job.id, currentUser.id);
      }

      final repository = ref.read(jobRepositoryProvider);
      final result = await repository.applyForJob(
        jobId: widget.job.id,
        eventId: widget.job.eventId,
        userId: currentUser.id,
        userName: currentUser.name,
        userPhone: currentUser.phone,
        userEmail: currentUser.email,
        coverLetter: _coverLetterController.text.trim().isEmpty
            ? null
            : _coverLetterController.text.trim(),
        resumeUrl: resumeUrl,
      );

      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (_) {
            Navigator.pop(context);
            widget.onSuccess();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Application submitted successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Apply for Job',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondaryDark),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Job summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.work_outline, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.title,
                          style: const TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.job.eventTitle != null)
                          Text(
                            widget.job.eventTitle!,
                            style: const TextStyle(
                              color: AppColors.textSecondaryDark,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cover Letter',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _coverLetterController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                hintText: 'Tell us why you\'re a great fit for this role...',
                hintStyle: const TextStyle(color: AppColors.textMutedDark),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // CV upload button
            InkWell(
              onTap: _isSubmitting ? null : _pickCv,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: _cvFileName != null
                      ? AppColors.primary.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _cvFileName != null
                        ? AppColors.primary
                        : AppColors.grey600,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _cvFileName != null ? Icons.description : Icons.upload_file,
                      color: _cvFileName != null
                          ? AppColors.primary
                          : AppColors.textSecondaryDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _cvFileName ?? 'Upload CV / Resume (PDF, DOC)',
                        style: TextStyle(
                          color: _cvFileName != null
                              ? AppColors.primary
                              : AppColors.textSecondaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_cvFileName != null)
                      GestureDetector(
                        onTap: () => setState(() {
                          _cvFilePath = null;
                          _cvFileName = null;
                        }),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.grey600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Application',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMutedDark,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: onTap != null
                          ? AppColors.primary
                          : AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
