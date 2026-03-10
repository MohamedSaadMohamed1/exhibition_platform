import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/enums.dart';
import 'user_model.dart';

part 'job_model.freezed.dart';
part 'job_model.g.dart';

/// Event job model
@freezed
class JobModel with _$JobModel {
  const JobModel._();

  const factory JobModel({
    required String id,
    required String eventId,
    required String organizerId,
    String? eventTitle,
    required String title,
    required String description,
    @Default([]) List<String> requirements,
    String? salary,
    String? location,
    String? jobType, // Full-time, Part-time, Contract
    @TimestampConverter() required DateTime deadline,
    @Default(0) int applicationsCount,
    @Default(JobStatus.open) JobStatus status,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _JobModel;

  factory JobModel.fromJson(Map<String, dynamic> json) =>
      _$JobModelFromJson(json);

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  /// Check if job is open
  bool get isOpen => status == JobStatus.open;

  /// Check if job is closed
  bool get isClosed => status == JobStatus.closed;

  /// Check if deadline has passed
  bool get isDeadlinePassed => DateTime.now().isAfter(deadline);

  /// Check if job is accepting applications
  bool get isAcceptingApplications => isOpen && !isDeadlinePassed;

  /// Days until deadline
  int get daysUntilDeadline {
    final difference = deadline.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }
}

/// Job application model
@freezed
class JobApplication with _$JobApplication {
  const JobApplication._();

  const factory JobApplication({
    required String id,
    required String jobId,
    required String eventId,
    required String userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? coverLetter,
    String? resumeUrl,
    @Default(ApplicationStatus.pending) ApplicationStatus status,
    String? feedback,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @NullableTimestampConverter() DateTime? reviewedAt,
  }) = _JobApplication;

  factory JobApplication.fromJson(Map<String, dynamic> json) =>
      _$JobApplicationFromJson(json);

  factory JobApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobApplication.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  /// Check if application is pending
  bool get isPending => status == ApplicationStatus.pending;

  /// Check if application is reviewed
  bool get isReviewed => status == ApplicationStatus.reviewed;

  /// Check if application is accepted
  bool get isAccepted => status == ApplicationStatus.accepted;

  /// Check if application is rejected
  bool get isRejected => status == ApplicationStatus.rejected;

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending Review';
      case ApplicationStatus.reviewed:
        return 'Under Review';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Not Selected';
    }
  }
}

/// Job filter model
@freezed
class JobFilter with _$JobFilter {
  const JobFilter._();

  const factory JobFilter({
    String? searchQuery,
    String? eventId,
    String? jobType,
    @Default(false) bool showClosedJobs,
    @Default(JobSortBy.deadline) JobSortBy sortBy,
    @Default(true) bool ascending,
  }) = _JobFilter;

  /// Check if filter is active
  bool get isActive =>
      searchQuery != null ||
      eventId != null ||
      jobType != null ||
      showClosedJobs;

  /// Check if job matches filter
  bool matches(JobModel job) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!job.title.toLowerCase().contains(query) &&
          !job.description.toLowerCase().contains(query)) {
        return false;
      }
    }

    if (eventId != null && job.eventId != eventId) {
      return false;
    }

    if (jobType != null && job.jobType != jobType) {
      return false;
    }

    if (!showClosedJobs && job.isClosed) {
      return false;
    }

    return true;
  }
}

/// Job sort options
enum JobSortBy {
  deadline,
  createdAt,
  title,
  applicationsCount,
}

/// Job types
abstract class JobTypes {
  static const String fullTime = 'Full-time';
  static const String partTime = 'Part-time';
  static const String contract = 'Contract';
  static const String temporary = 'Temporary';
  static const String volunteer = 'Volunteer';

  static List<String> get all => [
        fullTime,
        partTime,
        contract,
        temporary,
        volunteer,
      ];
}
