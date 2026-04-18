import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/review_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/review_repository.dart';

/// Reviews state
class ReviewsState {
  final List<ReviewModel> reviews;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final ReviewFilter filter;

  const ReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.filter = const ReviewFilter(),
  });

  ReviewsState copyWith({
    List<ReviewModel>? reviews,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    ReviewFilter? filter,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

/// Target reviews notifier
class TargetReviewsNotifier
    extends FamilyNotifier<ReviewsState, ({String targetId, ReviewType? type})> {
  late ReviewRepository _reviewRepository;

  @override
  ReviewsState build(({String targetId, ReviewType? type}) params) {
    _reviewRepository = ref.watch(reviewRepositoryProvider);
    _loadReviews(params);
    return const ReviewsState(isLoading: true);
  }

  Future<void> _loadReviews(
    ({String targetId, ReviewType? type}) params, {
    bool refresh = false,
  }) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      reviews: refresh ? [] : state.reviews,
    );

    final result = await _reviewRepository.getTargetReviews(
      params.targetId,
      type: params.type,
      filter: state.filter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (reviews) {
        state = state.copyWith(
          reviews: reviews,
          isLoading: false,
          hasMore: reviews.length >= 20,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final lastId = state.reviews.isNotEmpty ? state.reviews.last.id : null;

    state = state.copyWith(isLoading: true);

    final result = await _reviewRepository.getTargetReviews(
      arg.targetId,
      type: arg.type,
      filter: state.filter,
      lastReviewId: lastId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (reviews) {
        state = state.copyWith(
          reviews: [...state.reviews, ...reviews],
          isLoading: false,
          hasMore: reviews.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadReviews(arg, refresh: true);
  }

  void applyFilter(ReviewFilter filter) {
    state = state.copyWith(filter: filter);
    _loadReviews(arg, refresh: true);
  }

  Future<bool> markHelpful(String reviewId, String userId, bool isHelpful) async {
    if (isHelpful) {
      final result = await _reviewRepository.markReviewHelpful(
        reviewId: reviewId,
        userId: userId,
      );
      if (result.isRight()) {
        await refresh();
        return true;
      }
    } else {
      final result = await _reviewRepository.unmarkReviewHelpful(
        reviewId: reviewId,
        userId: userId,
      );
      if (result.isRight()) {
        await refresh();
        return true;
      }
    }
    return false;
  }
}

/// Target reviews provider
final targetReviewsProvider = NotifierProvider.family<TargetReviewsNotifier,
    ReviewsState, ({String targetId, ReviewType? type})>(() {
  return TargetReviewsNotifier();
});

/// Single review provider
final reviewProvider =
    FutureProvider.family<ReviewModel?, String>((ref, reviewId) async {
  final repository = ref.watch(reviewRepositoryProvider);
  final result = await repository.getReviewById(reviewId);
  return result.fold((l) => null, (r) => r);
});

/// User reviews provider
final userReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, userId) async {
  final repository = ref.watch(reviewRepositoryProvider);
  final result = await repository.getUserReviews(userId);
  return result.fold((l) => [], (r) => r);
});

/// User reviews stream provider
final userReviewsStreamProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, userId) {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.watchUserReviews(userId);
});

/// Target reviews stream provider
final targetReviewsStreamProvider = StreamProvider.family<List<ReviewModel>,
    ({String targetId, ReviewType? type})>((ref, params) {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.watchTargetReviews(params.targetId, type: params.type);
});

/// Review stats provider
final reviewStatsProvider = FutureProvider.family<ReviewStats,
    ({String targetId, ReviewType? type})>((ref, params) async {
  final repository = ref.watch(reviewRepositoryProvider);
  final result = await repository.getTargetReviewStats(
    params.targetId,
    type: params.type,
  );
  return result.fold((l) => const ReviewStats(), (r) => r);
});

/// Can user review provider
final canUserReviewProvider = FutureProvider.family<bool,
    ({String userId, String targetId, ReviewType type})>((ref, params) async {
  final repository = ref.watch(reviewRepositoryProvider);
  final result = await repository.canUserReview(
    userId: params.userId,
    targetId: params.targetId,
    type: params.type,
  );
  return result.fold((l) => false, (r) => r);
});

/// Has user reviewed provider
final hasUserReviewedProvider =
    FutureProvider.family<bool, ({String userId, String targetId})>((ref, params) async {
  final repository = ref.watch(reviewRepositoryProvider);
  final result = await repository.hasUserReviewed(
    userId: params.userId,
    targetId: params.targetId,
  );
  return result.fold((l) => false, (r) => r);
});
