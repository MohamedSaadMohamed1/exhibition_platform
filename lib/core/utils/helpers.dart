import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Helper utility functions
class Helpers {
  Helpers._();

  static const _uuid = Uuid();

  /// Generate a unique ID
  static String generateId() {
    return _uuid.v4();
  }

  /// Generate a short ID (8 characters)
  static String generateShortId() {
    return _uuid.v4().substring(0, 8);
  }

  /// Generate order number
  static String generateOrderNumber() {
    final now = DateTime.now();
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'ORD-${now.year}${now.month.toString().padLeft(2, '0')}$random';
  }

  /// Check if string is null or empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if string is not null and not empty
  static bool isNotNullOrEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  /// Generate color from string (for avatars)
  static Color getColorFromString(String text) {
    final hash = text.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = hash & 0x0000FF;
    return Color.fromRGBO(r, g, b, 1);
  }

  /// Calculate distance between two points (in kilometers)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // Earth's radius in kilometers

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Debounce function
  static void Function() debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(duration, callback);
    };
  }

  /// Parse double safely
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Parse int safely
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Parse bool safely
  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return defaultValue;
  }

  /// Get file extension from path or URL
  static String getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot + 1).toLowerCase();
  }

  /// Check if file is image
  static bool isImageFile(String path) {
    final extension = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  /// Check if file is document
  static bool isDocumentFile(String path) {
    final extension = getFileExtension(path);
    return ['pdf', 'doc', 'docx', 'txt'].contains(extension);
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Calculate age from date of birth
  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Mask email for privacy
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '**@$domain';
    }

    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  /// Mask phone number for privacy
  static String maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
  }
}

/// Timer class for debounce
class Timer {
  Timer._(this._duration, this._callback);
  final Duration _duration;
  final VoidCallback _callback;
  bool _cancelled = false;

  factory Timer(Duration duration, VoidCallback callback) {
    final timer = Timer._(duration, callback);
    timer._start();
    return timer;
  }

  void _start() async {
    await Future.delayed(_duration);
    if (!_cancelled) {
      _callback();
    }
  }

  void cancel() {
    _cancelled = true;
  }
}
