import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/review_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../router/routes.dart';
import '../providers/review_provider.dart';

class AllReviewsScreen extends ConsumerStatefulWidget {
  final String targetId;
  final String targetName;
  final String? targetImage;
  final ReviewType reviewType;

  const AllReviewsScreen({
    super.key,
    required this.targetId,
    required this.targetName,
    this.targetImage,
    required this.reviewType,
  });

  @override
  ConsumerState<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends ConsumerState<AllReviewsScreen> {
  double? _ratingFilter; // null = all

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(targetReviewsProvider((
      targetId: widget.targetId,
      type: widget.reviewType,
    )));
    final statsAsync = ref.watch(reviewStatsProvider((
      targetId: widget.targetId,
      type: widget.reviewType,
    )));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    final filteredReviews = _ratingFilter == null
        ? reviewsState.reviews
        : reviewsState.reviews
            .where((r) => r.rating.round() == _ratingFilter!.round())
            .toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          '${widget.targetName} Reviews',
          style: const TextStyle(color: AppColors.textPrimaryDark),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        elevation: 0,
        actions: [
          if (currentUser != null)
            _WriteReviewButton(
              targetId: widget.targetId,
              targetName: widget.targetName,
              targetImage: widget.targetImage,
              reviewType: widget.reviewType,
              currentUserId: currentUser.id,
            ),
        ],
      ),
      body: Column(
        children: [
          statsAsync.when(
            data: (stats) => stats.totalReviews > 0
                ? _StatsHeader(stats: stats)
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          _FilterChips(
            selected: _ratingFilter,
            onSelected: (val) => setState(() => _ratingFilter = val),
          ),
          Expanded(
            child: reviewsState.isLoading && reviewsState.reviews.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredReviews.isEmpty
                    ? _EmptyState(
                        targetId: widget.targetId,
                        targetName: widget.targetName,
                        targetImage: widget.targetImage,
                        reviewType: widget.reviewType,
                        currentUser: currentUser,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: filteredReviews.length +
                            (reviewsState.hasMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == filteredReviews.length) {
                            ref
                                .read(targetReviewsProvider((
                                  targetId: widget.targetId,
                                  type: widget.reviewType,
                                )).notifier)
                                .loadMore();
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return _ReviewCard(review: filteredReviews[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewButton extends ConsumerWidget {
  final String targetId;
  final String targetName;
  final String? targetImage;
  final ReviewType reviewType;
  final String currentUserId;

  const _WriteReviewButton({
    required this.targetId,
    required this.targetName,
    this.targetImage,
    required this.reviewType,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasReviewedAsync = ref.watch(
      hasUserReviewedProvider((userId: currentUserId, targetId: targetId)),
    );
    return hasReviewedAsync.when(
      data: (reviewed) => reviewed
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.check_circle, color: AppColors.success),
            )
          : TextButton.icon(
              icon: const Icon(Icons.star_outline, color: AppColors.warning),
              label: const Text(
                'Rate',
                style: TextStyle(color: AppColors.warning),
              ),
              onPressed: () async {
                final result = await context.pushNamed(
                  AppRoutes.writeReview,
                  extra: {
                    'targetId': targetId,
                    'targetName': targetName,
                    'targetImage': targetImage,
                    'reviewType': reviewType,
                  },
                );
                if (result == true) {
                  ref.invalidate(targetReviewsProvider);
                  ref.invalidate(reviewStatsProvider);
                  ref.invalidate(hasUserReviewedProvider);
                }
              },
            ),
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final ReviewStats stats;

  const _StatsHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < stats.averageRating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.warning,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '${stats.totalReviews} reviews',
                style: const TextStyle(
                    color: AppColors.textSecondaryDark, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final pct = stats.getPercentage(star) / 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: const TextStyle(
                            color: AppColors.textSecondaryDark, fontSize: 12),
                      ),
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 12),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppColors.grey700,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.warning),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final double? selected;
  final ValueChanged<double?> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final options = <String, double?>{
      'All': null,
      '5 ⭐': 5,
      '4 ⭐': 4,
      '3 ⭐': 3,
      '2 ⭐': 2,
      '1 ⭐': 1,
    };
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: options.entries.map((entry) {
          final isActive = selected == entry.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.key),
              selected: isActive,
              onSelected: (_) => onSelected(entry.value),
              backgroundColor: AppColors.cardDark,
              selectedColor: AppColors.primary.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondaryDark,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isActive ? AppColors.primary : AppColors.grey700,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                backgroundImage: review.reviewerImage != null
                    ? NetworkImage(review.reviewerImage!)
                    : null,
                child: review.reviewerImage == null
                    ? Text(
                        (review.reviewerName ?? '?')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName ?? 'User',
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('d MMM yyyy').format(review.createdAt),
                      style: const TextStyle(
                        color: AppColors.textMutedDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.warning,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                height: 1.5,
              ),
            ),
          ],
          if (review.hasSupplierResponse) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supplier Response',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.supplierResponse!,
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String targetId;
  final String targetName;
  final String? targetImage;
  final ReviewType reviewType;
  final dynamic currentUser;

  const _EmptyState({
    required this.targetId,
    required this.targetName,
    this.targetImage,
    required this.reviewType,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_outline, size: 64, color: AppColors.grey600),
          const SizedBox(height: 16),
          const Text(
            'No reviews yet',
            style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to review!',
            style: TextStyle(color: AppColors.textSecondaryDark),
          ),
          if (currentUser != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.star_outline),
              label: const Text('Write a Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => context.pushNamed(
                AppRoutes.writeReview,
                extra: {
                  'targetId': targetId,
                  'targetName': targetName,
                  'targetImage': targetImage,
                  'reviewType': reviewType,
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
