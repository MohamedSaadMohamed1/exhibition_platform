import 'package:dartz/dartz.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/job_model.dart';

/// Job repository interface
abstract class JobRepository {
  /// Get all jobs with optional filter
  Future<Either<Failure, List<JobModel>>> getJobs({
    JobFilter? filter,
    int limit = 20,
    String? lastJobId,
  });

  /// Get job by ID
  Future<Either<Failure, JobModel>> getJobById(String jobId);

  /// Get jobs for an event
  Future<Either<Failure, List<JobModel>>> getEventJobs(
    String eventId, {
    int limit = 20,
  });

  /// Get jobs by organizer
  Future<Either<Failure, List<JobModel>>> getOrganizerJobs(
    String organizerId, {
    int limit = 20,
  });

  /// Create a job
  Future<Either<Failure, JobModel>> createJob(JobModel job);

  /// Update a job
  Future<Either<Failure, JobModel>> updateJob(JobModel job);

  /// Delete a job
  Future<Either<Failure, void>> deleteJob(String jobId);

  /// Close a job (stop accepting applications)
  Future<Either<Failure, void>> closeJob(String jobId);

  /// Reopen a job
  Future<Either<Failure, void>> reopenJob(String jobId);

  /// Get open jobs (for job seekers)
  Future<Either<Failure, List<JobModel>>> getOpenJobs({
    String? eventId,
    String? jobType,
    int limit = 20,
  });

  /// Search jobs
  Future<Either<Failure, List<JobModel>>> searchJobs(
    String query, {
    int limit = 20,
  });

  // ==================== Job Applications ====================

  /// Apply for a job
  Future<Either<Failure, JobApplication>> applyForJob({
    required String jobId,
    required String eventId,
    required String userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? coverLetter,
    String? resumeUrl,
  });

  /// Get application by ID
  Future<Either<Failure, JobApplication>> getApplicationById(String applicationId);

  /// Get applications for a job (organizer)
  Future<Either<Failure, List<JobApplication>>> getJobApplications(
    String jobId, {
    ApplicationStatus? status,
    int limit = 20,
  });

  /// Get user's applications
  Future<Either<Failure, List<JobApplication>>> getUserApplications(
    String userId, {
    int limit = 20,
  });

  /// Update application status
  Future<Either<Failure, JobApplication>> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? feedback,
  });

  /// Check if user already applied
  Future<Either<Failure, bool>> hasUserApplied({
    required String jobId,
    required String userId,
  });

  /// Withdraw application
  Future<Either<Failure, void>> withdrawApplication(String applicationId);

  // ==================== Streams ====================

  /// Watch job for real-time updates
  Stream<JobModel> watchJob(String jobId);

  /// Watch jobs for an event
  Stream<List<JobModel>> watchEventJobs(String eventId);

  /// Watch applications for a job
  Stream<List<JobApplication>> watchJobApplications(String jobId);

  /// Watch user's applications
  Stream<List<JobApplication>> watchUserApplications(String userId);
}
