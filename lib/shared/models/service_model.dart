import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/json_converters.dart';

part 'service_model.freezed.dart';
part 'service_model.g.dart';

/// Service model - represents a service offered by a supplier
@freezed
class ServiceModel with _$ServiceModel {
  const ServiceModel._();

  const factory ServiceModel({
    required String id,
    required String supplierId,
    String? supplierName,
    required String title,
    required String description,
    required String category,
    @Default([]) List<String> images,
    double? price,
    String? priceUnit, // per hour, per day, per event, fixed
    @Default(true) bool isActive,
    @Default(0) int ordersCount,
    @Default(0.0) double rating,
    @Default(0) int reviewsCount,
    @Default([]) List<String> tags,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ServiceModel;

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel.fromJson({
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

  /// Get update map for Firestore
  Map<String, dynamic> toUpdateMap() {
    final json = toJson();
    json.remove('id');
    json.remove('createdAt');
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  /// Get primary image or placeholder
  String get primaryImage =>
      images.isNotEmpty ? images.first : 'https://via.placeholder.com/300';

  /// Get formatted price
  String get formattedPrice {
    if (price == null) return 'Contact for price';
    final priceStr = price!.toStringAsFixed(price! == price!.roundToDouble() ? 0 : 2);
    if (priceUnit != null) {
      return '\$$priceStr $priceUnit';
    }
    return '\$$priceStr';
  }

  /// Check if service has reviews
  bool get hasReviews => reviewsCount > 0;

  /// Get rating display
  String get ratingDisplay => rating.toStringAsFixed(1);
}

/// Service filter model
@freezed
class ServiceFilter with _$ServiceFilter {
  const ServiceFilter._();

  const factory ServiceFilter({
    String? searchQuery,
    String? supplierId,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    @Default(ServiceSortBy.createdAt) ServiceSortBy sortBy,
    @Default(false) bool ascending,
  }) = _ServiceFilter;

  /// Check if filter is active
  bool get isActive =>
      searchQuery != null ||
      supplierId != null ||
      category != null ||
      minPrice != null ||
      maxPrice != null ||
      minRating != null;

  /// Check if service matches filter
  bool matches(ServiceModel service) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!service.title.toLowerCase().contains(query) &&
          !service.description.toLowerCase().contains(query)) {
        return false;
      }
    }

    if (supplierId != null && service.supplierId != supplierId) {
      return false;
    }

    if (category != null && service.category != category) {
      return false;
    }

    if (minPrice != null && (service.price == null || service.price! < minPrice!)) {
      return false;
    }

    if (maxPrice != null && (service.price == null || service.price! > maxPrice!)) {
      return false;
    }

    if (minRating != null && service.rating < minRating!) {
      return false;
    }

    return true;
  }
}

/// Service sort options
enum ServiceSortBy {
  createdAt,
  title,
  price,
  rating,
  ordersCount,
}

/// Service categories
abstract class ServiceCategories {
  static const String eventPlanning = 'Event Planning';
  static const String catering = 'Catering';
  static const String decoration = 'Decoration';
  static const String photography = 'Photography';
  static const String videography = 'Videography';
  static const String entertainment = 'Entertainment';
  static const String audioVisual = 'Audio/Visual';
  static const String lighting = 'Lighting';
  static const String transportation = 'Transportation';
  static const String security = 'Security';
  static const String cleaning = 'Cleaning';
  static const String printing = 'Printing';
  static const String staffing = 'Staffing';
  static const String equipment = 'Equipment Rental';
  static const String other = 'Other';

  static List<String> get all => [
        eventPlanning,
        catering,
        decoration,
        photography,
        videography,
        entertainment,
        audioVisual,
        lighting,
        transportation,
        security,
        cleaning,
        printing,
        staffing,
        equipment,
        other,
      ];
}

/// Price units
abstract class PriceUnits {
  static const String perHour = 'per hour';
  static const String perDay = 'per day';
  static const String perEvent = 'per event';
  static const String fixed = 'fixed';
  static const String negotiable = 'negotiable';

  static List<String> get all => [
        perHour,
        perDay,
        perEvent,
        fixed,
        negotiable,
      ];
}
