import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/job_model.dart';

// ── Simple event summary for the picker ─────────────────────────────
class EventSummary {
  final String id;
  final String title;

  const EventSummary({required this.id, required this.title});
}

// ── Admin jobs state ─────────────────────────────────────────────────
class AdminJobsState {
  final List<JobModel> jobs;
  final bool isLoading;
  final bool isCreating;
  final String? errorMessage;

  const AdminJobsState({
    this.jobs = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.errorMessage,
  });

  AdminJobsState copyWith({
    List<JobModel>? jobs,
    bool? isLoading,
    bool? isCreating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminJobsState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── Admin jobs notifier ──────────────────────────────────────────────
class AdminJobsNotifier extends Notifier<AdminJobsState> {
  final _firestore = FirebaseFirestore.instance;

  @override
  AdminJobsState build() {
    Future.microtask(_fetchJobs);
    return const AdminJobsState(isLoading: true);
  }

  Future<void> _fetchJobs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .get();

      final jobs = snapshot.docs.map(JobModel.fromFirestore).toList();
      state = state.copyWith(isLoading: false, jobs: jobs);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() => _fetchJobs();

  /// Create a new job and return true on success.
  Future<bool> createJob({
    required String adminId,
    required String title,
    required String description,
    String eventId = '',
    String? eventTitle,
    required DateTime deadline,
    String? jobType,
    String? location,
    String? salary,
    List<String> requirements = const [],
  }) async {
    state = state.copyWith(isCreating: true, clearError: true);
    try {
      final ref = _firestore.collection('jobs').doc();
      final job = JobModel(
        id: ref.id,
        eventId: eventId,
        organizerId: adminId,
        eventTitle: eventTitle,
        title: title,
        description: description,
        requirements: requirements,
        salary: salary?.trim().isEmpty == true ? null : salary?.trim(),
        location: location?.trim().isEmpty == true ? null : location?.trim(),
        jobType: jobType,
        deadline: deadline,
        createdAt: DateTime.now(),
      );

      await ref.set(job.toFirestore());

      state = state.copyWith(
        isCreating: false,
        jobs: [job, ...state.jobs],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Close a job (stop accepting applications).
  Future<void> closeJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': 'closed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _fetchJobs();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Reopen a closed job.
  Future<void> reopenJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': 'open',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _fetchJobs();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Delete a job permanently.
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
      state = state.copyWith(
        jobs: state.jobs.where((j) => j.id != jobId).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final adminJobsProvider =
    NotifierProvider<AdminJobsNotifier, AdminJobsState>(AdminJobsNotifier.new);

// ── Events picker provider ───────────────────────────────────────────
final adminEventsPickerProvider = FutureProvider<List<EventSummary>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('events')
      .orderBy('createdAt', descending: true)
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return EventSummary(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Untitled Event',
    );
  }).toList();
});
