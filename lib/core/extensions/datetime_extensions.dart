import 'package:intl/intl.dart';

/// DateTime extension methods
extension DateTimeExtensions on DateTime {
  /// Format as "Jan 01, 2024"
  String get formatted => DateFormat('MMM dd, yyyy').format(this);

  /// Format as "Jan 01, 2024 14:30"
  String get formattedWithTime => DateFormat('MMM dd, yyyy HH:mm').format(this);

  /// Format as "14:30"
  String get formattedTime => DateFormat('HH:mm').format(this);

  /// Format as "01/01/2024"
  String get shortFormatted => DateFormat('dd/MM/yyyy').format(this);

  /// Format as "January 2024"
  String get monthYear => DateFormat('MMMM yyyy').format(this);

  /// Format as "01 Jan"
  String get dayMonth => DateFormat('dd MMM').format(this);

  /// Format as "Monday, January 01, 2024"
  String get fullFormatted => DateFormat('EEEE, MMMM dd, yyyy').format(this);

  /// Format as ISO 8601
  String get iso8601 => toIso8601String();

  /// Get relative time string
  String get relative {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      return _formatFuture(difference.abs());
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return 'Yesterday';
      return '$days days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return formatted;
    }
  }

  String _formatFuture(Duration difference) {
    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Tomorrow';
      return 'In ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minutes';
    }
    return 'Soon';
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Check if date is in same year
  bool get isThisYear => year == DateTime.now().year;

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final diff = weekday - DateTime.monday;
    return subtract(Duration(days: diff)).startOfDay;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    final diff = DateTime.sunday - weekday;
    return add(Duration(days: diff)).endOfDay;
  }

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Add days
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Add months
  DateTime addMonths(int months) {
    var newMonth = month + months;
    var newYear = year;
    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }
    return DateTime(newYear, newMonth, day, hour, minute, second);
  }

  /// Check if same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Get difference in days
  int differenceInDays(DateTime other) {
    return difference(other).inDays.abs();
  }

  /// Format with custom pattern
  String format(String pattern) => DateFormat(pattern).format(this);
}

/// Nullable DateTime extension methods
extension NullableDateTimeExtensions on DateTime? {
  /// Format or return empty string
  String get formattedOrEmpty => this?.formatted ?? '';

  /// Check if null
  bool get isNull => this == null;

  /// Check if not null
  bool get isNotNull => this != null;
}
