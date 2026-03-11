import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/json_converters.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

/// Review model - can be for events, suppliers, or services
@freezed
class ReviewModel with _$ReviewModel {
  const ReviewModel._();

  const factory ReviewModel({
    required String id,
    required String reviewerId,
    String? reviewerName,
    String? reviewerImage,
    required ReviewType type,
    required String targetId, // eventId, supplierId, or serviceId
    String? targetName,
    String? orderId, // For service reviews, link to order
    required double rating, // 1-5
    String? title,
    String? comment,
    @Default([]) List<String> images,
    @Default(0) int helpfulCount,
    @Default([]) List<String> helpfulBy, // User IDs who found this helpful
    String? supplierResponse,
    @NullableTimestampConverter() DateTime? supplierResponseAt,
    @Default(false) bool isVerified, // Verified purchase/attendance
    @Default(true) bool isVisible,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromJson({
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

  /// Get update map
  Map<String, dynamic> toUpdateMap() {
    final json = toJson();
    json.remove('id');
    json.remove('createdAt');
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  /// Check if review has images
  bool get hasImages => images.isNotEmpty;

  /// Alias for backward compatibility with UI screens
  String? get userAvatar => reviewerImage;
  String? get userName => reviewerName;

  /// Check if review has supplier response
  bool get hasSupplierResponse =>
      supplierResponse != null && supplierResponse!.isNotEmpty;

  /// Get rating stars (for display)
  List<bool> get ratingStars {
    return List.generate(5, (index) => index < rating.round());
  }

  /// Get rating display text
  String get ratingDisplayText {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Very Good';
    if (rating >= 2.5) return 'Good';
    if (rating >= 1.5) return 'Fair';
    return 'Poor';
  }

  /// Check if user found this helpful
  bool isHelpfulBy(String userId) => helpfulBy.contains(userId);
}

/// Review type enum
enum ReviewType {
  @JsonValue('event')
  event,
  @JsonValue('supplier')
  supplier,
  @JsonValue('service')
  service;

  String get value {
    switch (this) {
      case ReviewType.event:
        return 'event';
      case ReviewType.supplier:
        return 'supplier';
      case ReviewType.service:
        return 'service';
    }
  }

  static ReviewType fromString(String value) {
    return ReviewType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ReviewType.service,
    );
  }

  String get displayName {
    switch (this) {
      case ReviewType.event:
        return 'Event Review';
      case ReviewType.supplier:
        return 'Supplier Review';
      case ReviewType.service:
        return 'Service Review';
    }
  }
}

/// Review filter model
@freezed
class ReviewFilter with _$ReviewFilter {
  const ReviewFilter._();

  const factory ReviewFilter({
    ReviewType? type,
    String? targetId,
    String? reviewerId,
    double? minRating,
    @Default(false) bool verifiedOnly,
    @Default(ReviewSortBy.createdAt) ReviewSortBy sortBy,
    @Default(false) bool ascending,
  }) = _ReviewFilter;

  /// Check if filter is active
  bool get isActive =>
      type != null ||
      targetId != null ||
      reviewerId != null ||
      minRating != null ||
      verifiedOnly;
}

/// Review sort options
enum ReviewSortBy {
  createdAt,
  rating,
  helpfulCount,
}

/// Review statistics
@freezed
class ReviewStats with _$ReviewStats {
  const ReviewStats._();

  const factory ReviewStats({
    @Default(0) int totalReviews,
    @Default(0.0) double averageRating,
    @Default(0) int fiveStarCount,
    @Default(0) int fourStarCount,
    @Default(0) int threeStarCount,
    @Default(0) int twoStarCount,
    @Default(0) int oneStarCount,
  }) = _ReviewStats;

  factory ReviewStats.fromJson(Map<String, dynamic> json) =>
      _$ReviewStatsFromJson(json);

  /// Get percentage for each rating
  double getPercentage(int stars) {
    if (totalReviews == 0) return 0;
    int count;
    switch (stars) {
      case 5:
        count = fiveStarCount;
        break;
      case 4:
        count = fourStarCount;
        break;
      case 3:
        count = threeStarCount;
        break;
      case 2:
        count = twoStarCount;
        break;
      case 1:
        count = oneStarCount;
        break;
      default:
        count = 0;
    }
    return (count / totalReviews) * 100;
  }

  /// Calculate from list of reviews
  factory ReviewStats.fromReviews(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return const ReviewStats();
    }

    int five = 0, four = 0, three = 0, two = 0, one = 0;
    double total = 0;

    for (final review in reviews) {
      total += review.rating;
      final roundedRating = review.rating.round();
      switch (roundedRating) {
        case 5:
          five++;
          break;
        case 4:
          four++;
          break;
        case 3:
          three++;
          break;
        case 2:
          two++;
          break;
        case 1:
          one++;
          break;
      }
    }

    return ReviewStats(
      totalReviews: reviews.length,
      averageRating: total / reviews.length,
      fiveStarCount: five,
      fourStarCount: four,
      threeStarCount: three,
      twoStarCount: two,
      oneStarCount: one,
    );
  }
}
