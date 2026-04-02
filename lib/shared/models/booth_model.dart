import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';

/// Booth model representing a booth in an event
class BoothModel {
  final String id;
  final String eventId;
  final String boothNumber;
  final BoothSize size;
  final String? category;
  final double price;
  final BoothStatus status;
  final String? reservedBy;
  final DateTime? reservedAt;
  final String? bookedBy;
  final DateTime? bookedAt;
  final List<String> amenities;
  final String? description;
  final BoothPosition? position;
  final double? customWidth;
  final double? customHeight;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BoothModel({
    required this.id,
    required this.eventId,
    required this.boothNumber,
    this.size = BoothSize.small,
    this.category,
    required this.price,
    this.status = BoothStatus.available,
    this.reservedBy,
    this.reservedAt,
    this.bookedBy,
    this.bookedAt,
    this.amenities = const [],
    this.description,
    this.position,
    this.customWidth,
    this.customHeight,
    required this.createdAt,
    this.updatedAt,
  });

  factory BoothModel.fromJson(Map<String, dynamic> json) {
    return BoothModel(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      boothNumber: json['boothNumber'] as String? ?? '',
      size: _parseBoothSize(json['size']),
      category: json['category'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: _parseBoothStatus(json['status']),
      reservedBy: json['reservedBy'] as String?,
      reservedAt: json['reservedAt'] != null ? _parseDateTime(json['reservedAt']) : null,
      bookedBy: json['bookedBy'] as String?,
      bookedAt: json['bookedAt'] != null ? _parseDateTime(json['bookedAt']) : null,
      amenities: (json['amenities'] as List<dynamic>?)?.cast<String>() ?? [],
      description: json['description'] as String?,
      position: json['position'] != null
          ? BoothPosition.fromJson(json['position'] as Map<String, dynamic>)
          : null,
      customWidth: (json['customWidth'] as num?)?.toDouble(),
      customHeight: (json['customHeight'] as num?)?.toDouble(),
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

  static BoothSize _parseBoothSize(dynamic value) {
    if (value is String) {
      return BoothSize.values.firstWhere(
        (e) => e.name == value,
        orElse: () => BoothSize.small,
      );
    }
    return BoothSize.small;
  }

  static BoothStatus _parseBoothStatus(dynamic value) {
    if (value is String) {
      return BoothStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => BoothStatus.available,
      );
    }
    return BoothStatus.available;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'boothNumber': boothNumber,
      'size': size.name,
      'category': category,
      'price': price,
      'status': status.name,
      'reservedBy': reservedBy,
      'reservedAt': reservedAt != null ? Timestamp.fromDate(reservedAt!) : null,
      'bookedBy': bookedBy,
      'bookedAt': bookedAt != null ? Timestamp.fromDate(bookedAt!) : null,
      'amenities': amenities,
      'description': description,
      'position': position?.toJson(),
      'customWidth': customWidth,
      'customHeight': customHeight,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory BoothModel.fromFirestore(DocumentSnapshot doc, String eventId) {
    final data = doc.data() as Map<String, dynamic>;
    return BoothModel.fromJson({
      'id': doc.id,
      'eventId': eventId,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json.remove('eventId');
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  bool get isAvailable => status == BoothStatus.available;
  bool get isReserved => status == BoothStatus.reserved;
  bool get isBooked => status == BoothStatus.booked;

  bool get isReservationExpired {
    if (!isReserved || reservedAt == null) return false;
    final timeout = reservedAt!.add(const Duration(minutes: 15));
    return DateTime.now().isAfter(timeout);
  }

  String get sizeDisplayText {
    switch (size) {
      case BoothSize.small:
        return 'Small (3x3m)';
      case BoothSize.medium:
        return 'Medium (4x4m)';
      case BoothSize.large:
        return 'Large (5x5m)';
      case BoothSize.premium:
        return 'Premium (6x6m)';
      case BoothSize.custom:
        if (customWidth != null && customHeight != null) {
          return 'Custom (${customWidth!.toStringAsFixed(1)}x${customHeight!.toStringAsFixed(1)}m)';
        }
        return 'Custom';
    }
  }

  BoothModel copyWith({
    String? id,
    String? eventId,
    String? boothNumber,
    BoothSize? size,
    String? category,
    double? price,
    BoothStatus? status,
    String? reservedBy,
    DateTime? reservedAt,
    String? bookedBy,
    DateTime? bookedAt,
    List<String>? amenities,
    String? description,
    BoothPosition? position,
    double? customWidth,
    double? customHeight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BoothModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      boothNumber: boothNumber ?? this.boothNumber,
      size: size ?? this.size,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      reservedBy: reservedBy ?? this.reservedBy,
      reservedAt: reservedAt ?? this.reservedAt,
      bookedBy: bookedBy ?? this.bookedBy,
      bookedAt: bookedAt ?? this.bookedAt,
      amenities: amenities ?? this.amenities,
      description: description ?? this.description,
      position: position ?? this.position,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Booth position for map layout
class BoothPosition {
  final double x;
  final double y;
  final double rotation;
  final double width;
  final double height;

  const BoothPosition({
    required this.x,
    required this.y,
    this.rotation = 0,
    this.width = 1,
    this.height = 1,
  });

  factory BoothPosition.fromJson(Map<String, dynamic> json) {
    return BoothPosition(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 1,
      height: (json['height'] as num?)?.toDouble() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'rotation': rotation,
      'width': width,
      'height': height,
    };
  }
}

/// Booth filter model
class BoothFilter {
  final String? searchQuery;
  final String? category;
  final BoothSize? size;
  final BoothStatus? status;
  final double? minPrice;
  final double? maxPrice;
  final bool showOnlyAvailable;

  const BoothFilter({
    this.searchQuery,
    this.category,
    this.size,
    this.status,
    this.minPrice,
    this.maxPrice,
    this.showOnlyAvailable = false,
  });

  bool get isActive =>
      searchQuery != null ||
      category != null ||
      size != null ||
      status != null ||
      minPrice != null ||
      maxPrice != null ||
      showOnlyAvailable;

  bool matches(BoothModel booth) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      if (!booth.boothNumber.toLowerCase().contains(searchQuery!.toLowerCase())) {
        return false;
      }
    }
    if (category != null && booth.category != category) return false;
    if (size != null && booth.size != size) return false;
    if (status != null && booth.status != status) return false;
    if (minPrice != null && booth.price < minPrice!) return false;
    if (maxPrice != null && booth.price > maxPrice!) return false;
    if (showOnlyAvailable && !booth.isAvailable) return false;
    return true;
  }

  BoothFilter copyWith({
    String? searchQuery,
    String? category,
    BoothSize? size,
    BoothStatus? status,
    double? minPrice,
    double? maxPrice,
    bool? showOnlyAvailable,
  }) {
    return BoothFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      size: size ?? this.size,
      status: status ?? this.status,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      showOnlyAvailable: showOnlyAvailable ?? this.showOnlyAvailable,
    );
  }
}
