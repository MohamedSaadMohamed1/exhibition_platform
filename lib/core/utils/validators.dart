/// Validation utilities for form fields
abstract class Validators {
  /// Normalize a phone number to E.164 format expected by Firebase Auth.
  ///
  /// Firebase Auth always stores/returns numbers in E.164 (e.g. +966501234567).
  /// The Firestore migration rule compares the stored phone against
  /// request.auth.token.phone_number, so both MUST be in the same format.
  ///
  /// Examples:
  ///   normalizePhone('0501234567', '+966')  → '+966501234567'
  ///   normalizePhone('+966501234567', '+966') → '+966501234567' (idempotent)
  ///   normalizePhone('501234567', '+966')   → '+966501234567'
  static String normalizePhone(String localPhone, String countryCode) {
    // Strip whitespace, dashes, and parentheses
    String cleaned = localPhone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final code = countryCode.replaceAll(RegExp(r'[\s\-]'), '');

    // Already fully qualified
    if (cleaned.startsWith('+')) return cleaned;

    // Has country code digits without +  (e.g. "966XXXXXXX")
    final codeDigits = code.replaceAll('+', '');
    if (cleaned.startsWith(codeDigits)) {
      return '+$cleaned';
    }

    // Local format with leading zero (e.g. "05XXXXXXXX" → strip the 0)
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    return '$code$cleaned';
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and dashes
    final cleanedNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it contains only digits and optional + prefix
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(cleanedNumber)) {
      return 'Invalid phone number format';
    }

    return null;
  }

  /// Validate OTP code
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength, [
    String fieldName = 'Field',
  ]) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, [
    String fieldName = 'Field',
  ]) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }

  /// Validate price
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Invalid price format';
    }

    if (price < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  /// Validate date range
  static String? validateDateRange(DateTime? start, DateTime? end) {
    if (start == null) {
      return 'Start date is required';
    }

    if (end == null) {
      return 'End date is required';
    }

    if (end.isBefore(start)) {
      return 'End date must be after start date';
    }

    return null;
  }

  /// Validate future date
  static String? validateFutureDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }

    if (date.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }

    return null;
  }

  /// Combine multiple validators
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
