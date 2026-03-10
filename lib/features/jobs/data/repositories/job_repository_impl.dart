import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/job_model.dart';
import '../../domain/repositories/job_repository.dart';

/// Implementation of JobRepository
class JobRepositoryImpl implements JobRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  JobRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _jobsCollection =>
      _firestore.collection(FirestoreCollections.jobs);

  CollectionReference<Map<String, dynamic>> _applicationsCollection(String jobId) =>
      _jobsCollection.doc(jobId).collection('applications');

  @override
  Future<Either<Failure, List<JobModel>>> getJobs({
    JobFilter? filter,
    int limit = 20,
    String? lastJobId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _jobsCollection;

      // Apply filters
      if (filter != null) {
        if (filter.eventId != null) {
          query = query.where('eventId', isEqualTo: filter.eventId);
        }
        if (filter.jobType != null) {
          query = query.where('jobType', isEqualTo: filter.jobType);
        }
        if (!filter.showClosedJobs) {
          query = query.where('status', isEqualTo: JobStatus.open.value);
        }
      } else {
        query = query.where('status', isEqualTo: JobStatus.open.value);
      }

      // Sort
      final sortBy = filter?.sortBy ?? JobSortBy.deadline;
      final ascending = filter?.ascending ?? true;

      switch (sortBy) {
        case JobSortBy.deadline:
          query = query.orderBy('deadline', descending: !ascending);
          break;
        case JobSortBy.createdAt:
          query = query.orderBy('createdAt', descending: !ascending);
          break;
        case JobSortBy.title:
          query = query.orderBy('title', descending: !ascending);
          break;
        case JobSortBy.applicationsCount:
          query = query.orderBy('applicationsCount', descending: !ascending);
          break;
      }

      // Pagination
      if (lastJobId != null) {
        final lastDoc = await _jobsCollection.doc(lastJobId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final jobs = snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();

      return Right(jobs);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, JobModel>> getJobById(String jobId) async {
    try {
      final doc = await _jobsCollection.doc(jobId).get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Job not found'));
      }

      return Right(JobModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<JobModel>>> getEventJobs(
    String eventId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _jobsCollection
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: JobStatus.open.value)
          .orderBy('deadline')
          .limit(limit)
          .get();

      final jobs = snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
      return Right(jobs);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<JobModel>>> getOrganizerJobs(
    String organizerId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _jobsCollection
          .where('organizerId', isEqualTo: organizerId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final jobs = snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
      return Right(jobs);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, JobModel>> createJob(JobModel job) async {
    try {
      final docRef = _jobsCollection.doc();
      final newJob = job.copyWith(id: docRef.id);

      await docRef.set(newJob.toFirestore());

      return Right(newJob);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, JobModel>> updateJob(JobModel job) async {
    try {
      final json = job.toJson();
      json.remove('id');
      json.remove('createdAt');
      json['updatedAt'] = FieldValue.serverTimestamp();

      await _jobsCollection.doc(job.id).update(json);
      return Right(job);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteJob(String jobId) async {
    try {
      await _jobsCollection.doc(jobId).delete();
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> closeJob(String jobId) async {
    try {
      await _jobsCollection.doc(jobId).update({
        'status': JobStatus.closed.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> reopenJob(String jobId) async {
    try {
      await _jobsCollection.doc(jobId).update({
        'status': JobStatus.open.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<JobModel>>> getOpenJobs({
    String? eventId,
    String? jobType,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _jobsCollection
          .where('status', isEqualTo: JobStatus.open.value)
          .where('deadline', isGreaterThan: Timestamp.now());

      if (eventId != null) {
        query = query.where('eventId', isEqualTo: eventId);
      }
      if (jobType != null) {
        query = query.where('jobType', isEqualTo: jobType);
      }

      final snapshot = await query.orderBy('deadline').limit(limit).get();
      final jobs = snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();

      return Right(jobs);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<JobModel>>> searchJobs(
    String query, {
    int limit = 20,
  }) async {
    try {
      final queryLower = query.toLowerCase();

      final snapshot = await _jobsCollection
          .where('status', isEqualTo: JobStatus.open.value)
          .where('searchKeywords', arrayContains: queryLower)
          .limit(limit)
          .get();

      final jobs = snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
      return Right(jobs);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  // ==================== Job Applications ====================

  @override
  Future<Either<Failure, JobApplication>> applyForJob({
    required String jobId,
    required String eventId,
    required String userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? coverLetter,
    String? resumeUrl,
  }) async {
    try {
      // Check if already applied
      final existingResult = await hasUserApplied(jobId: jobId, userId: userId);
      if (existingResult.isRight() && existingResult.getOrElse(() => false)) {
        return Left(ValidationFailure('You have already applied for this job'));
      }

      final applicationId = _uuid.v4();
      final application = JobApplication(
        id: applicationId,
        jobId: jobId,
        eventId: eventId,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        userEmail: userEmail,
        coverLetter: coverLetter,
        resumeUrl: resumeUrl,
        status: ApplicationStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        // Create application
        transaction.set(
          _applicationsCollection(jobId).doc(applicationId),
          application.toFirestore(),
        );

        // Increment applications count on job
        transaction.update(_jobsCollection.doc(jobId), {
          'applicationsCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return Right(application);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, JobApplication>> getApplicationById(
    String applicationId,
  ) async {
    try {
      // We need to search across all jobs for this application
      final jobsSnapshot = await _jobsCollection.get();

      for (final jobDoc in jobsSnapshot.docs) {
        final appDoc = await _applicationsCollection(jobDoc.id)
            .doc(applicationId)
            .get();
        if (appDoc.exists) {
          return Right(JobApplication.fromFirestore(appDoc));
        }
      }

      return Left(NotFoundFailure('Application not found'));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<JobApplication>>> getJobApplications(
    String jobId, {
    ApplicationStatus? status,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _applicationsCollection(jobId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final applications = snapshot.docs
          .map((doc) => JobApplication.fromFirestore(doc))
          .toList();

      return Right(applications);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<JobApplication>>> getUserApplications(
    String userId, {
    int limit = 20,
  }) async {
    try {
      // Query all jobs and get applications for this user
      final jobsSnapshot = await _jobsCollection.get();
      final List<JobApplication> allApplications = [];

      for (final jobDoc in jobsSnapshot.docs) {
        final appSnapshot = await _applicationsCollection(jobDoc.id)
            .where('userId', isEqualTo: userId)
            .get();

        allApplications.addAll(
          appSnapshot.docs.map((doc) => JobApplication.fromFirestore(doc)),
        );
      }

      // Sort by createdAt descending
      allApplications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Right(allApplications.take(limit).toList());
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, JobApplication>> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? feedback,
  }) async {
    try {
      // Find the application
      final jobsSnapshot = await _jobsCollection.get();

      for (final jobDoc in jobsSnapshot.docs) {
        final appRef = _applicationsCollection(jobDoc.id).doc(applicationId);
        final appDoc = await appRef.get();

        if (appDoc.exists) {
          await appRef.update({
            'status': status.value,
            if (feedback != null) 'feedback': feedback,
            'reviewedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          final updatedDoc = await appRef.get();
          return Right(JobApplication.fromFirestore(updatedDoc));
        }
      }

      return Left(NotFoundFailure('Application not found'));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserApplied({
    required String jobId,
    required String userId,
  }) async {
    try {
      final snapshot = await _applicationsCollection(jobId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return Right(snapshot.docs.isNotEmpty);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> withdrawApplication(String applicationId) async {
    try {
      // Find and delete the application
      final jobsSnapshot = await _jobsCollection.get();

      for (final jobDoc in jobsSnapshot.docs) {
        final appRef = _applicationsCollection(jobDoc.id).doc(applicationId);
        final appDoc = await appRef.get();

        if (appDoc.exists) {
          await _firestore.runTransaction((transaction) async {
            transaction.delete(appRef);
            transaction.update(_jobsCollection.doc(jobDoc.id), {
              'applicationsCount': FieldValue.increment(-1),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          });
          return const Right(null);
        }
      }

      return Left(NotFoundFailure('Application not found'));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  // ==================== Streams ====================

  @override
  Stream<JobModel> watchJob(String jobId) {
    return _jobsCollection.doc(jobId).snapshots().map(
      (doc) => JobModel.fromFirestore(doc),
    );
  }

  @override
  Stream<List<JobModel>> watchEventJobs(String eventId) {
    return _jobsCollection
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: JobStatus.open.value)
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<JobApplication>> watchJobApplications(String jobId) {
    return _applicationsCollection(jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobApplication.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<JobApplication>> watchUserApplications(String userId) {
    // Note: This is a simplified implementation
    // In production, you might want to use a collection group query
    // or denormalize the data
    return Stream.value([]);
  }
}
