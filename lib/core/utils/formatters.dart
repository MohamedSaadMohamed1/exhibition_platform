import 'package:intl/intl.dart';

/// Formatters utility class
class Formatters {
  Formatters._();

  // Date formatters
  static final _dateFormat = DateFormat('MMM dd, yyyy');
  static final _dateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');
  static final _timeFormat = DateFormat('HH:mm');
  static final _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _dayMonthFormat = DateFormat('dd MMM');
  static final _fullDateFormat = DateFormat('EEEE, MMMM dd, yyyy');

  /// Format date - "Jan 01, 2024"
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format date time - "Jan 01, 2024 14:30"
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format time - "14:30"
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format short date - "01/01/2024"
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Format month year - "January 2024"
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format day month - "01 Jan"
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Format full date - "Monday, January 01, 2024"
  static String formatFullDate(DateTime date) {
    return _fullDateFormat.format(date);
  }

  /// Format relative time - "2 hours ago", "yesterday", etc.
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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
      return formatDate(date);
    }
  }

  /// Format duration - "2h 30m"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Format currency
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format compact currency - "$1.5K"
  static String formatCompactCurrency(double amount, {String currency = 'USD'}) {
    final formatter = NumberFormat.compactCurrency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 1,
    );
    return formatter.format(amount);
  }

  /// Get currency symbol
  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'AED':
        return 'د.إ';
      case 'SAR':
        return '﷼';
      default:
        return currency;
    }
  }

  /// Format number with commas - "1,234,567"
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  /// Format compact number - "1.2K", "3.5M"
  static String formatCompactNumber(num number) {
    final formatter = NumberFormat.compact();
    return formatter.format(number);
  }

  /// Format phone number
  static String formatPhoneNumber(String phone) {
    // Remove any non-digit characters except +
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (phone.startsWith('+')) {
      // International format
      if (phone.length > 10) {
        return '${phone.substring(0, phone.length - 10)} ${phone.substring(phone.length - 10, phone.length - 7)} ${phone.substring(phone.length - 7, phone.length - 4)} ${phone.substring(phone.length - 4)}';
      }
    }

    return phone;
  }

  /// Format file size - "1.5 MB"
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalize each word
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
