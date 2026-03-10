import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converter for Timestamp to DateTime
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is DateTime) {
      return json;
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}

/// Converter for nullable Timestamp to DateTime
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is DateTime) {
      return json;
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    return null;
  }

  @override
  dynamic toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}

/// Converter for GeoPoint
class GeoPointConverter implements JsonConverter<GeoPoint?, dynamic> {
  const GeoPointConverter();

  @override
  GeoPoint? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is GeoPoint) return json;
    if (json is Map<String, dynamic>) {
      return GeoPoint(
        (json['latitude'] as num?)?.toDouble() ?? 0,
        (json['longitude'] as num?)?.toDouble() ?? 0,
      );
    }
    return null;
  }

  @override
  dynamic toJson(GeoPoint? object) {
    if (object == null) return null;
    return {
      'latitude': object.latitude,
      'longitude': object.longitude,
    };
  }
}
