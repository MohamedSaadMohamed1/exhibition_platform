import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/review_model.dart';
import '../../domain/repositories/review_repository.dart';

/// Implementation of ReviewRepository
class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection(FirestoreCollections.reviews);

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirestoreCollections.orders);

  @override
  Future<Either<Failure, ReviewModel>> createReview(ReviewModel review) async {
    try {
      // Check if user already reviewed
      final existingResult = await hasUserReviewed(
        userId: review.reviewerId,
        targetId: review.targetId,
      );
      if (existingResult.isRight() && existingResult.getOrElse(() => false)) {
        return Left(ValidationFailure.withMessage('You have already reviewed this'));
      }

      final docRef = _reviewsCollection.doc();
      final newReview = review.copyWith(id: docRef.id);

      await docRef.set(newReview.toFirestore());

      // Update target's rating (will be done by Cloud Function in production)
      await _updateTargetRating(review.targetId, review.type);

      return Right(newReview);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, ReviewModel>> getReviewById(String reviewId) async {
    try {
      final doc = await _reviewsCollection.doc(reviewId).get();

      if (!doc.exists) {
        return Left(NotFoundFailure.withMessage('Review not found'));
      }

      return Right(ReviewModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, ReviewModel>> updateReview(ReviewModel review) async {
    try {
      await _reviewsCollection.doc(review.id).update(review.toUpdateMap());

      // Update target's rating
      await _updateTargetRating(review.targetId, review.type);

      return Right(review);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      final doc = await _reviewsCollection.doc(reviewId).get();
      if (!doc.exists) {
        return Left(NotFoundFailure.withMessage('Review not found'));
      }

      final review = ReviewModel.fromFirestore(doc);
      await _reviewsCollection.doc(reviewId).delete();

      // Update target's rating
      await _updateTargetRating(review.targetId, review.type);

      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReviewModel>>> getTargetReviews(
    String targetId, {
    ReviewType? type,
    ReviewFilter? filter,
    int limit = 20,
    String? lastReviewId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _reviewsCollection
          .where('targetId', isEqualTo: targetId)
          .where('isVisible', isEqualTo: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type.value);
      }

      if (filter != null) {
        if (filter.minRating != null) {
          query = query.where('rating', isGreaterThanOrEqualTo: filter.minRating);
        }
        if (filter.verifiedOnly) {
          query = query.where('isVerified', isEqualTo: true);
        }
      }

      // Sort
      final sortBy = filter?.sortBy ?? ReviewSortBy.createdAt;
      final ascending = filter?.ascending ?? false;

      switch (sortBy) {
        case ReviewSortBy.createdAt:
          query = query.orderBy('createdAt', descending: !ascending);
          break;
        case ReviewSortBy.rating:
          query = query.orderBy('rating', descending: !ascending);
          break;
        case ReviewSortBy.helpfulCount:
          query = query.orderBy('helpfulCount', descending: !ascending);
          break;
      }

      if (lastReviewId != null) {
        final lastDoc = await _reviewsCollection.doc(lastReviewId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      return Right(reviews);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReviewModel>>> getUserReviews(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _reviewsCollection
          .where('reviewerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      return Right(reviews);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, ReviewStats>> getTargetReviewStats(
    String targetId, {
    ReviewType? type,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _reviewsCollection
          .where('targetId', isEqualTo: targetId)
          .where('isVisible', isEqualTo: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type.value);
      }

      final snapshot = await query.get();
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      return Right(ReviewStats.fromReviews(reviews));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> canUserReview({
    required String userId,
    required String targetId,
    required ReviewType type,
  }) async {
    try {
      // Check if already reviewed
      final alreadyReviewed = await hasUserReviewed(
        userId: userId,
        targetId: targetId,
      );
      if (alreadyReviewed.isRight() && alreadyReviewed.getOrElse(() => false)) {
        return const Right(false);
      }

      // For service reviews, check if user has completed order
      if (type == ReviewType.service) {
        final orderSnapshot = await _ordersCollection
            .where('customerId', isEqualTo: userId)
            .where('serviceId', isEqualTo: targetId)
            .where('status', isEqualTo: 'completed')
            .limit(1)
            .get();

        return Right(orderSnapshot.docs.isNotEmpty);
      }

      // For events and suppliers, allow anyone to review (for now)
      return const Right(true);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserReviewed({
    required String userId,
    required String targetId,
  }) async {
    try {
      final snapshot = await _reviewsCollection
          .where('reviewerId', isEqualTo: userId)
          .where('targetId', isEqualTo: targetId)
          .limit(1)
          .get();

      return Right(snapshot.docs.isNotEmpty);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markReviewHelpful({
    required String reviewId,
    required String userId,
  }) async {
    try {
      await _reviewsCollection.doc(reviewId).update({
        'helpfulBy': FieldValue.arrayUnion([userId]),
        'helpfulCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> unmarkReviewHelpful({
    required String reviewId,
    required String userId,
  }) async {
    try {
      await _reviewsCollection.doc(reviewId).update({
        'helpfulBy': FieldValue.arrayRemove([userId]),
        'helpfulCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, ReviewModel>> addSupplierResponse({
    required String reviewId,
    required String response,
  }) async {
    try {
      await _reviewsCollection.doc(reviewId).update({
        'supplierResponse': response,
        'supplierResponseAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await _reviewsCollection.doc(reviewId).get();
      return Right(ReviewModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> reportReview({
    required String reviewId,
    required String reporterId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('review_reports').add({
        'reviewId': reviewId,
        'reporterId': reporterId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<List<ReviewModel>> watchTargetReviews(
    String targetId, {
    ReviewType? type,
  }) {
    Query<Map<String, dynamic>> query = _reviewsCollection
        .where('targetId', isEqualTo: targetId)
        .where('isVisible', isEqualTo: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.value);
    }

    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<ReviewModel>> watchUserReviews(String userId) {
    return _reviewsCollection
        .where('reviewerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
  }

  /// Update target's average rating (simplified - use Cloud Function in production)
  Future<void> _updateTargetRating(String targetId, ReviewType type) async {
    try {
      final snapshot = await _reviewsCollection
          .where('targetId', isEqualTo: targetId)
          .where('isVisible', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (final doc in snapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }
      final averageRating = totalRating / snapshot.docs.length;

      // Update the target collection based on type
      String collection;
      switch (type) {
        case ReviewType.event:
          collection = FirestoreCollections.events;
          break;
        case ReviewType.supplier:
          collection = FirestoreCollections.suppliers;
          break;
        case ReviewType.service:
          collection = FirestoreCollections.services;
          break;
      }

      await _firestore.collection(collection).doc(targetId).update({
        'rating': averageRating,
        'reviewsCount': snapshot.docs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't fail the review operation
      print('Failed to update target rating: $e');
    }
  }
}
