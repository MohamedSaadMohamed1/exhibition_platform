import 'package:cloud_firestore/cloud_firestore.dart';

/// Supplier model representing a supplier/vendor
class SupplierModel {
  final String id;
  final String name;
  final String description;
  final List<String> services;
  final String? category;
  final List<String> images;
  final String ownerId;
  final String? ownerName;
  final String? contactEmail;
  final String? contactPhone;
  final String? website;
  final String? address;
  final double rating;
  final int reviewCount;
  final String createdByAdmin;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SupplierModel({
    required this.id,
    required this.name,
    required this.description,
    this.services = const [],
    this.category,
    this.images = const [],
    required this.ownerId,
    this.ownerName,
    this.contactEmail,
    this.contactPhone,
    this.website,
    this.address,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdByAdmin,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      services: (json['services'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      ownerId: json['ownerId'] as String? ?? '',
      ownerName: json['ownerName'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      createdByAdmin: json['createdByAdmin'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'services': services,
      'category': category,
      'images': images,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdByAdmin': createdByAdmin,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory SupplierModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupplierModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  /// Get cover image
  String? get coverImage => images.isNotEmpty ? images.first : null;

  /// Alias for backward compatibility with UI screens
  String get businessName => name;
  List<String> get categories => services;
  int get reviewsCount => reviewCount;
  String? get profileImage => coverImage;
  int get ordersCount => 0; // TODO: Add ordersCount field to model
  String get userId => ownerId;

  /// Check if supplier has contact info
  bool get hasContactInfo =>
      contactEmail != null || contactPhone != null || website != null;

  /// Get update map for Firestore
  Map<String, dynamic> toUpdateMap() {
    final json = toJson();
    json.remove('id');
    json.remove('createdAt');
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? services,
    String? category,
    List<String>? images,
    String? ownerId,
    String? ownerName,
    String? contactEmail,
    String? contactPhone,
    String? website,
    String? address,
    double? rating,
    int? reviewCount,
    String? createdByAdmin,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      services: services ?? this.services,
      category: category ?? this.category,
      images: images ?? this.images,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      website: website ?? this.website,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdByAdmin: createdByAdmin ?? this.createdByAdmin,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Supplier filter model
class SupplierFilter {
  final String? searchQuery;
  final String? category;
  final List<String> services;
  final double? minRating;
  final bool showOnlyVerified;
  final SupplierSortBy sortBy;
  final bool ascending;

  const SupplierFilter({
    this.searchQuery,
    this.category,
    this.services = const [],
    this.minRating,
    this.showOnlyVerified = false,
    this.sortBy = SupplierSortBy.rating,
    this.ascending = false,
  });

  /// Check if filter is active
  bool get isActive =>
      searchQuery != null ||
      category != null ||
      services.isNotEmpty ||
      minRating != null ||
      showOnlyVerified;

  /// Check if supplier matches filter
  bool matches(SupplierModel supplier) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!supplier.name.toLowerCase().contains(query) &&
          !supplier.description.toLowerCase().contains(query)) {
        return false;
      }
    }

    if (category != null && supplier.category != category) {
      return false;
    }

    if (services.isNotEmpty &&
        !services.any((s) => supplier.services.contains(s))) {
      return false;
    }

    if (minRating != null && supplier.rating < minRating!) {
      return false;
    }

    if (showOnlyVerified && !supplier.isVerified) {
      return false;
    }

    return true;
  }

  SupplierFilter copyWith({
    String? searchQuery,
    String? category,
    List<String>? services,
    double? minRating,
    bool? showOnlyVerified,
    SupplierSortBy? sortBy,
    bool? ascending,
  }) {
    return SupplierFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      services: services ?? this.services,
      minRating: minRating ?? this.minRating,
      showOnlyVerified: showOnlyVerified ?? this.showOnlyVerified,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// Supplier sort options
enum SupplierSortBy {
  rating,
  name,
  reviewCount,
  ordersCount,
  createdAt,
}

/// Supplier categories
abstract class SupplierCategories {
  static const String catering = 'Catering';
  static const String decoration = 'Decoration';
  static const String audioVisual = 'Audio & Visual';
  static const String printing = 'Printing';
  static const String furniture = 'Furniture';
  static const String security = 'Security';
  static const String cleaning = 'Cleaning';
  static const String photography = 'Photography';
  static const String transportation = 'Transportation';
  static const String other = 'Other';

  static List<String> get all => [
        catering,
        decoration,
        audioVisual,
        printing,
        furniture,
        security,
        cleaning,
        photography,
        transportation,
        other,
      ];
}
