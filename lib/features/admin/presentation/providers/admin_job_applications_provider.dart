import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _pageSize = 20;

/// Flat model matching the actual Firestore structure in `job_applications`
class AdminJobApplication {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String position;
  final String? coverLetter;
  final String? resumeUrl;
  final String? status;
  final String? feedback;
  final String? source;
  final DateTime createdAt;

  const AdminJobApplication({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.position,
    this.coverLetter,
    this.resumeUrl,
    this.status,
    this.feedback,
    this.source,
    required this.createdAt,
  });

  factory AdminJobApplication.fromMap(String id, Map<String, dynamic> data) {
    DateTime createdAt;
    final raw = data['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else {
      createdAt = DateTime.now();
    }

    return AdminJobApplication(
      id: id,
      fullName: (data['fullName'] as String?) ?? (data['userName'] as String?) ?? 'Unknown',
      email: (data['email'] as String?) ?? (data['userEmail'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? (data['userPhone'] as String?) ?? '',
      position: (data['position'] as String?) ?? '',
      coverLetter: data['coverLetter'] as String?,
      resumeUrl: data['resumeUrl'] as String?,
      status: (data['status'] as String?) ?? 'pending',
      feedback: data['feedback'] as String?,
      source: data['source'] as String?,
      createdAt: createdAt,
    );
  }

  String get statusDisplayText {
    switch (status) {
      case 'reviewed':
        return 'Reviewed';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending Review';
    }
  }

  bool get isPending => status == null || status == 'pending';
  bool get isReviewed => status == 'reviewed';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}

class AdminJobApplicationsState {
  final List<AdminJobApplication> applications;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final String? statusFilter; // 'pending','reviewed','accepted','rejected', null=all

  const AdminJobApplicationsState({
    this.applications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.statusFilter,
  });

  AdminJobApplicationsState copyWith({
    List<AdminJobApplication>? applications,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
    String? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return AdminJobApplicationsState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class AdminJobApplicationsNotifier extends Notifier<AdminJobApplicationsState> {
  List<AdminJobApplication> _all = [];
  int _currentPage = 0;

  @override
  AdminJobApplicationsState build() {
    Future.microtask(() => _fetchAll());
    return const AdminJobApplicationsState(isLoading: true);
  }

  Future<void> _fetchAll() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      applications: [],
      hasMore: true,
    );

    try {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('job_applications');

      if (state.statusFilter != null) {
        query = query.where('status', isEqualTo: state.statusFilter);
      }

      final snapshot = await query.get();

      final all = snapshot.docs
          .map((doc) => AdminJobApplication.fromMap(doc.id, doc.data()))
          .toList();

      // Sort by createdAt descending in memory
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _all = all;
      _currentPage = 0;

      final firstPage = all.take(_pageSize).toList();

      state = state.copyWith(
        isLoading: false,
        applications: firstPage,
        hasMore: all.length > _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);

    _currentPage++;
    final start = _currentPage * _pageSize;
    final end = start + _pageSize;
    final next = _all.sublist(
      start,
      end > _all.length ? _all.length : end,
    );

    state = state.copyWith(
      isLoadingMore: false,
      applications: [...state.applications, ...next],
      hasMore: end < _all.length,
    );
  }

  Future<void> filterByStatus(String? status) async {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    await _fetchAll();
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? feedback,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('job_applications')
          .doc(applicationId)
          .update({
        'status': status,
        if (feedback != null) 'feedback': feedback,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _fetchAll();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> refresh() => _fetchAll();
}

final adminJobApplicationsProvider = NotifierProvider<
    AdminJobApplicationsNotifier, AdminJobApplicationsState>(
  AdminJobApplicationsNotifier.new,
);
