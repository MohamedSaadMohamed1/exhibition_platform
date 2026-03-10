import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts Firestore Timestamp to DateTime and vice versa
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Handles nullable Timestamps
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.tryParse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

/// Server timestamp placeholder for writes
class ServerTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const ServerTimestampConverter();

  @override
  DateTime fromJson(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  @override
  FieldValue toJson(DateTime date) => FieldValue.serverTimestamp();
}

/// Extension methods for Firestore documents
extension DocumentSnapshotExtension on DocumentSnapshot {
  /// Get data with ID included
  Map<String, dynamic> dataWithId() {
    final data = this.data() as Map<String, dynamic>? ?? {};
    data['id'] = id;
    return data;
  }

  /// Check if document exists and has data
  bool get hasData => exists && data() != null;
}

/// Extension methods for Firestore queries
extension QuerySnapshotExtension on QuerySnapshot {
  /// Get all documents as list of maps with IDs
  List<Map<String, dynamic>> toListWithIds() {
    return docs.map((doc) => doc.dataWithId()).toList();
  }

  /// Check if query has results
  bool get hasResults => docs.isNotEmpty;
}

/// Extension methods for DocumentReference
extension DocumentReferenceExtension on DocumentReference {
  /// Set data with server timestamp
  Future<void> setWithTimestamp(Map<String, dynamic> data, {bool merge = false}) {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return set(data, SetOptions(merge: merge));
  }

  /// Update data with server timestamp
  Future<void> updateWithTimestamp(Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return update(data);
  }
}

/// Extension methods for CollectionReference
extension CollectionReferenceExtension on CollectionReference {
  /// Add document with server timestamp
  Future<DocumentReference> addWithTimestamp(Map<String, dynamic> data) {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return add(data);
  }
}
