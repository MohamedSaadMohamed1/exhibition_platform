import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/review_model.dart';

/// Review repository interface
abstract class ReviewRepository {
  /// Create a review
  Future<Either<Failure, ReviewModel>> createReview(ReviewModel review);

  /// Get review by ID
  Future<Either<Failure, ReviewModel>> getReviewById(String reviewId);

  /// Update a review
  Future<Either<Failure, ReviewModel>> updateReview(ReviewModel review);

  /// Delete a review
  Future<Either<Failure, void>> deleteReview(String reviewId);

  /// Get reviews for a target (event, supplier, or service)
  Future<Either<Failure, List<ReviewModel>>> getTargetReviews(
    String targetId, {
    ReviewType? type,
    ReviewFilter? filter,
    int limit = 20,
    String? lastReviewId,
  });

  /// Get reviews by user
  Future<Either<Failure, List<ReviewModel>>> getUserReviews(
    String userId, {
    int limit = 20,
  });

  /// Get review statistics for a target
  Future<Either<Failure, ReviewStats>> getTargetReviewStats(
    String targetId, {
    ReviewType? type,
  });

  /// Check if user can review (e.g., has completed order)
  Future<Either<Failure, bool>> canUserReview({
    required String userId,
    required String targetId,
    required ReviewType type,
  });

  /// Check if user already reviewed
  Future<Either<Failure, bool>> hasUserReviewed({
    required String userId,
    required String targetId,
  });

  /// Mark review as helpful
  Future<Either<Failure, void>> markReviewHelpful({
    required String reviewId,
    required String userId,
  });

  /// Unmark review as helpful
  Future<Either<Failure, void>> unmarkReviewHelpful({
    required String reviewId,
    required String userId,
  });

  /// Add supplier response to review
  Future<Either<Failure, ReviewModel>> addSupplierResponse({
    required String reviewId,
    required String response,
  });

  /// Report a review
  Future<Either<Failure, void>> reportReview({
    required String reviewId,
    required String reporterId,
    required String reason,
  });

  /// Watch reviews for a target
  Stream<List<ReviewModel>> watchTargetReviews(
    String targetId, {
    ReviewType? type,
  });

  /// Watch user reviews
  Stream<List<ReviewModel>> watchUserReviews(String userId);
}
