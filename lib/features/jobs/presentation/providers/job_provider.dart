import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/job_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/job_repository.dart';

/// Jobs state
class JobsState {
  final List<JobModel> jobs;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final JobFilter filter;

  const JobsState({
    this.jobs = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.filter = const JobFilter(),
  });

  JobsState copyWith({
    List<JobModel>? jobs,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    JobFilter? filter,
  }) {
    return JobsState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

/// Jobs notifier
class JobsNotifier extends Notifier<JobsState> {
  late JobRepository _jobRepository;

  @override
  JobsState build() {
    _jobRepository = ref.watch(jobRepositoryProvider);
    Future.microtask(() => _loadJobs());
    return const JobsState(isLoading: true);
  }

  Future<void> _loadJobs({bool refresh = false}) async {
    if (state.isLoading && state.jobs.isNotEmpty && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      jobs: refresh ? [] : state.jobs,
    );

    final result = await _jobRepository.getJobs(filter: state.filter);

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (jobs) {
        state = state.copyWith(
          jobs: jobs,
          isLoading: false,
          hasMore: jobs.length >= 20,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final lastId = state.jobs.isNotEmpty ? state.jobs.last.id : null;

    state = state.copyWith(isLoading: true);

    final result = await _jobRepository.getJobs(
      filter: state.filter,
      lastJobId: lastId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (jobs) {
        state = state.copyWith(
          jobs: [...state.jobs, ...jobs],
          isLoading: false,
          hasMore: jobs.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadJobs(refresh: true);
  }

  void applyFilter(JobFilter filter) {
    state = state.copyWith(filter: filter);
    _loadJobs(refresh: true);
  }

  void clearFilter() {
    state = state.copyWith(filter: const JobFilter());
    _loadJobs(refresh: true);
  }
}

/// Jobs notifier provider
final jobsNotifierProvider = NotifierProvider<JobsNotifier, JobsState>(() {
  return JobsNotifier();
});

/// Single job provider
final jobProvider = FutureProvider.family<JobModel?, String>((ref, jobId) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getJobById(jobId);
  return result.fold((l) => null, (r) => r);
});

/// Job stream provider
final jobStreamProvider = StreamProvider.family<JobModel, String>((ref, jobId) {
  final repository = ref.watch(jobRepositoryProvider);
  return repository.watchJob(jobId);
});

/// Event jobs provider
final eventJobsProvider =
    FutureProvider.family<List<JobModel>, String>((ref, eventId) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getEventJobs(eventId);
  return result.fold((l) => [], (r) => r);
});

/// Event jobs stream provider
final eventJobsStreamProvider =
    StreamProvider.family<List<JobModel>, String>((ref, eventId) {
  final repository = ref.watch(jobRepositoryProvider);
  return repository.watchEventJobs(eventId);
});

/// Organizer jobs provider
final organizerJobsProvider =
    FutureProvider.family<List<JobModel>, String>((ref, organizerId) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getOrganizerJobs(organizerId);
  return result.fold((l) => [], (r) => r);
});

/// Open jobs provider
final openJobsProvider = FutureProvider<List<JobModel>>((ref) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getOpenJobs();
  return result.fold((l) => [], (r) => r);
});

/// Job applications provider
final jobApplicationsProvider =
    FutureProvider.family<List<JobApplication>, String>((ref, jobId) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getJobApplications(jobId);
  return result.fold((l) => [], (r) => r);
});

/// Job applications stream provider
final jobApplicationsStreamProvider =
    StreamProvider.family<List<JobApplication>, String>((ref, jobId) {
  final repository = ref.watch(jobRepositoryProvider);
  return repository.watchJobApplications(jobId);
});

/// User applications provider
final userApplicationsProvider =
    FutureProvider.family<List<JobApplication>, String>((ref, userId) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getUserApplications(userId);
  return result.fold((l) => [], (r) => r);
});

/// Has user applied provider
final hasUserAppliedProvider =
    FutureProvider.family<bool, ({String jobId, String userId})>((ref, params) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.hasUserApplied(
    jobId: params.jobId,
    userId: params.userId,
  );
  return result.fold((l) => false, (r) => r);
});
