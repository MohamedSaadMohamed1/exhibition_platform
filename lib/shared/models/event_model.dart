import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';

/// Event model representing an exhibition event
class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String? address;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> tags;
  final List<String> images;
  final int interestedCount;
  final int boothCount;
  final String organizerId;
  final String? organizerName;
  final EventStatus status;
  final String? category;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.address,
    required this.startDate,
    required this.endDate,
    this.tags = const [],
    this.images = const [],
    this.interestedCount = 0,
    this.boothCount = 0,
    required this.organizerId,
    this.organizerName,
    this.status = EventStatus.draft,
    this.category,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      address: json['address'] as String?,
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTime(json['endDate']),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      interestedCount: json['interestedCount'] as int? ?? 0,
      boothCount: json['boothCount'] as int? ?? 0,
      organizerId: json['organizerId'] as String? ?? '',
      organizerName: json['organizerName'] as String?,
      status: _parseEventStatus(json['status']),
      category: json['category'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
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

  static EventStatus _parseEventStatus(dynamic value) {
    if (value is String) {
      return EventStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => EventStatus.draft,
      );
    }
    return EventStatus.draft;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'address': address,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'tags': tags,
      'images': images,
      'interestedCount': interestedCount,
      'boothCount': boothCount,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'status': status.name,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel.fromJson({
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

  Map<String, dynamic> toUpdateFirestore() {
    final json = toJson();
    json.remove('id');
    json.remove('createdAt');
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  bool get isPublished => status == EventStatus.published;

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  bool get isPast => DateTime.now().isAfter(endDate);

  int get durationDays => endDate.difference(startDate).inDays + 1;

  String? get coverImage => images.isNotEmpty ? images.first : null;

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? address,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    List<String>? images,
    int? interestedCount,
    int? boothCount,
    String? organizerId,
    String? organizerName,
    EventStatus? status,
    String? category,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      interestedCount: interestedCount ?? this.interestedCount,
      boothCount: boothCount ?? this.boothCount,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      status: status ?? this.status,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Event filter model
class EventFilter {
  final String? searchQuery;
  final String? location;
  final String? category;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final List<String> tags;
  final bool showPastEvents;
  final EventSortBy sortBy;
  final bool ascending;

  const EventFilter({
    this.searchQuery,
    this.location,
    this.category,
    this.startDateFrom,
    this.startDateTo,
    this.tags = const [],
    this.showPastEvents = false,
    this.sortBy = EventSortBy.startDate,
    this.ascending = true,
  });

  bool get isActive =>
      searchQuery != null ||
      location != null ||
      category != null ||
      startDateFrom != null ||
      startDateTo != null ||
      tags.isNotEmpty ||
      showPastEvents;

  bool matches(EventModel event) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!event.title.toLowerCase().contains(query) &&
          !event.description.toLowerCase().contains(query)) {
        return false;
      }
    }

    if (location != null &&
        location!.isNotEmpty &&
        !event.location.toLowerCase().contains(location!.toLowerCase())) {
      return false;
    }

    if (category != null && category!.isNotEmpty && event.category != category) {
      return false;
    }

    if (startDateFrom != null && event.startDate.isBefore(startDateFrom!)) {
      return false;
    }

    if (startDateTo != null && event.startDate.isAfter(startDateTo!)) {
      return false;
    }

    if (tags.isNotEmpty && !tags.any((tag) => event.tags.contains(tag))) {
      return false;
    }

    if (!showPastEvents && event.isPast) {
      return false;
    }

    return true;
  }

  EventFilter copyWith({
    String? searchQuery,
    String? location,
    String? category,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    List<String>? tags,
    bool? showPastEvents,
    EventSortBy? sortBy,
    bool? ascending,
  }) {
    return EventFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      location: location ?? this.location,
      category: category ?? this.category,
      startDateFrom: startDateFrom ?? this.startDateFrom,
      startDateTo: startDateTo ?? this.startDateTo,
      tags: tags ?? this.tags,
      showPastEvents: showPastEvents ?? this.showPastEvents,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// Event sort options
enum EventSortBy {
  startDate,
  createdAt,
  interestedCount,
  title,
}
