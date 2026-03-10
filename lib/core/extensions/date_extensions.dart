import 'package:intl/intl.dart';

/// DateTime extensions
extension DateTimeX on DateTime {
  /// Format as date string
  String toDateString() => DateFormat('dd/MM/yyyy').format(this);

  /// Format as time string
  String toTimeString() => DateFormat('HH:mm').format(this);

  /// Format as datetime string
  String toDateTimeString() => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Format as readable date
  String toReadableDate() => DateFormat('MMMM d, yyyy').format(this);

  /// Format as short date
  String toShortDate() => DateFormat('MMM d').format(this);

  /// Format as relative time
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

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
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Format for chat messages
  String toChatTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(year, month, day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(this);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(this).inDays < 7) {
      return DateFormat('EEEE').format(this); // Day name
    } else {
      return DateFormat('dd/MM/yyyy').format(this);
    }
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

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Add days
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Format event date range
  static String formatEventDateRange(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      // Same day
      return '${DateFormat('MMMM d, yyyy').format(start)} ${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
    } else if (start.year == end.year && start.month == end.month) {
      // Same month
      return '${DateFormat('MMMM d').format(start)} - ${DateFormat('d, yyyy').format(end)}';
    } else if (start.year == end.year) {
      // Same year
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    } else {
      // Different years
      return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    }
  }
}

/// Duration extensions
extension DurationX on Duration {
  /// Format as countdown
  String toCountdown() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Format as readable
  String toReadable() {
    if (inDays > 0) {
      return '$inDays ${inDays == 1 ? 'day' : 'days'}';
    } else if (inHours > 0) {
      return '$inHours ${inHours == 1 ? 'hour' : 'hours'}';
    } else if (inMinutes > 0) {
      return '$inMinutes ${inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return '$inSeconds ${inSeconds == 1 ? 'second' : 'seconds'}';
    }
  }
}
