import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/job_model.dart';

const _pageSize = 20;

class AdminJobApplicationsState {
  final List<({JobApplication application, String jobTitle})> applications;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final ApplicationStatus? statusFilter;

  const AdminJobApplicationsState({
    this.applications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.statusFilter,
  });

  AdminJobApplicationsState copyWith({
    List<({JobApplication application, String jobTitle})>? applications,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
    ApplicationStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return AdminJobApplicationsState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class AdminJobApplicationsNotifier extends Notifier<AdminJobApplicationsState> {
  // Stores the last document snapshot for cursor-based pagination
  DocumentSnapshot? _lastDoc;
  // Cache of jobId -> jobTitle to avoid redundant Firestore reads
  final Map<String, String> _jobTitleCache = {};

  @override
  AdminJobApplicationsState build() {
    Future.microtask(() => _load(refresh: true));
    return const AdminJobApplicationsState(isLoading: true);
  }

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collectionGroup('applications');

    if (state.statusFilter != null) {
      query = query.where('status', isEqualTo: state.statusFilter!.value);
    }

    return query.orderBy('createdAt', descending: true);
  }

  /// Fetches job titles for a list of jobIds, using cache to minimise reads.
  Future<Map<String, String>> _fetchJobTitles(List<String> jobIds) async {
    final missing = jobIds.where((id) => !_jobTitleCache.containsKey(id)).toSet();

    if (missing.isNotEmpty) {
      // Firestore 'in' query supports up to 30 items per call
      final batches = <List<String>>[];
      final list = missing.toList();
      for (var i = 0; i < list.length; i += 30) {
        batches.add(list.sublist(i, i + 30 > list.length ? list.length : i + 30));
      }

      for (final batch in batches) {
        final snap = await FirebaseFirestore.instance
            .collection('jobs')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in snap.docs) {
          _jobTitleCache[doc.id] = (doc.data()['title'] as String?) ?? 'Unknown Job';
        }
      }
    }

    return Map.fromEntries(
      jobIds.map((id) => MapEntry(id, _jobTitleCache[id] ?? 'Unknown Job')),
    );
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      _lastDoc = null;
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        applications: [],
        hasMore: true,
      );
    }

    try {
      var query = _buildQuery().limit(_pageSize);

      if (_lastDoc != null) {
        query = query.startAfterDocument(_lastDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
      }

      final apps =
          snapshot.docs.map((doc) => JobApplication.fromFirestore(doc)).toList();

      final jobIds = apps.map((a) => a.jobId).toSet().toList();
      final titles = await _fetchJobTitles(jobIds);

      final items = apps
          .map((a) => (application: a, jobTitle: titles[a.jobId] ?? 'Unknown Job'))
          .toList();

      final newList = refresh ? items : [...state.applications, ...items];

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        applications: newList,
        hasMore: snapshot.docs.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    await _load(refresh: false);
  }

  Future<void> filterByStatus(ApplicationStatus? status) async {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    await _load(refresh: true);
  }

  Future<void> updateApplicationStatus({
    required String jobId,
    required String applicationId,
    required ApplicationStatus status,
    String? feedback,
  }) async {
    try {
      final appRef = FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .collection('applications')
          .doc(applicationId);

      await appRef.update({
        'status': status.value,
        if (feedback != null) 'feedback': feedback,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh the current list from the start
      await _load(refresh: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> refresh() => _load(refresh: true);
}

final adminJobApplicationsProvider = NotifierProvider<
    AdminJobApplicationsNotifier, AdminJobApplicationsState>(
  AdminJobApplicationsNotifier.new,
);
