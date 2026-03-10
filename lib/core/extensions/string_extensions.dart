/// String extension methods
extension StringExtensions on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isValidPhone {
    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    return RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    ).hasMatch(this);
  }

  /// Check if string is numeric
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Convert to title case
  String get toTitleCase {
    return toLowerCase().capitalizeWords;
  }

  /// Get initials from name
  String get initials {
    if (isEmpty) return '';
    final parts = trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '';
  }

  /// Remove all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Truncate with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst('_', '');
  }

  /// Convert to camelCase
  String get toCamelCase {
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalize).join();
  }

  /// Check if null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Parse as int or return null
  int? get toIntOrNull => int.tryParse(this);

  /// Parse as double or return null
  double? get toDoubleOrNull => double.tryParse(this);

  /// Mask email for privacy
  String get maskedEmail {
    final parts = split('@');
    if (parts.length != 2) return this;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '**@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  /// Mask phone for privacy
  String get maskedPhone {
    if (length <= 4) return this;
    return '${'*' * (length - 4)}${substring(length - 4)}';
  }
}

/// Nullable string extension methods
extension NullableStringExtensions on String? {
  /// Check if null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Return value or default
  String orDefault([String defaultValue = '']) => this ?? defaultValue;
}
