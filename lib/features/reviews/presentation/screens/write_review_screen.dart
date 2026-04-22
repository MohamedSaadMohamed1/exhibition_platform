import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/review_model.dart';
import '../../../../shared/providers/providers.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String targetId;
  final String targetName;
  final String? targetImage;
  final ReviewType reviewType;

  const WriteReviewScreen({
    super.key,
    required this.targetId,
    required this.targetName,
    this.targetImage,
    required this.reviewType,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  double _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _typeLabel {
    switch (widget.reviewType) {
      case ReviewType.event:
        return 'Event';
      case ReviewType.supplier:
        return 'Supplier';
      case ReviewType.service:
        return 'Service';
    }
  }

  String get _ratingLabel {
    if (_selectedRating == 0) return 'Select your rating';
    if (_selectedRating >= 5) return 'Excellent';
    if (_selectedRating >= 4) return 'Very Good';
    if (_selectedRating >= 3) return 'Good';
    if (_selectedRating >= 2) return 'Fair';
    return 'Poor';
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    final review = ReviewModel(
      id: const Uuid().v4(),
      reviewerId: currentUser.id,
      reviewerName: currentUser.name,
      reviewerImage: currentUser.profileImage,
      targetId: widget.targetId,
      targetName: widget.targetName,
      type: widget.reviewType,
      rating: _selectedRating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      isVerified: false,
      isVisible: true,
      createdAt: DateTime.now(),
    );

    final repository = ref.read(reviewRepositoryProvider);
    final result = await repository.createReview(review);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) {
        final msg = failure.message.contains('already reviewed')
            ? 'You have already reviewed this'
            : failure.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully ✓'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'Rate $_typeLabel',
          style: const TextStyle(color: AppColors.textPrimaryDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTargetCard(),
            const SizedBox(height: 28),
            _buildStarPicker(),
            const SizedBox(height: 28),
            _buildCommentField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (widget.targetImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.targetImage!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImageFallback(),
              ),
            )
          else
            _buildImageFallback(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.targetName,
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share your experience',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.store, color: AppColors.primary, size: 28),
    );
  }

  Widget _buildStarPicker() {
    return Column(
      children: [
        Text(
          _ratingLabel,
          style: TextStyle(
            color: _selectedRating > 0
                ? AppColors.warning
                : AppColors.textSecondaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = (index + 1).toDouble();
            return GestureDetector(
              onTap: () => setState(() => _selectedRating = starValue),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  _selectedRating >= starValue
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: _selectedRating >= starValue
                      ? AppColors.warning
                      : AppColors.grey600,
                  size: 48,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment (optional)',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _commentController,
          maxLines: 4,
          maxLength: 500,
          style: const TextStyle(color: AppColors.textPrimaryDark),
          decoration: InputDecoration(
            hintText: 'Tell us about your experience...',
            hintStyle: TextStyle(color: AppColors.textMutedDark),
            filled: true,
            fillColor: AppColors.cardDark,
            counterStyle: TextStyle(color: AppColors.textMutedDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey700),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Submit Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
