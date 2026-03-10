/// Input validation utilities
class InputValidator {
  InputValidator._();

  /// Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validate strong password
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Please enter a valid phone number';
    }
    if (!RegExp(r'^\+?[\d]+$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate name
  static String? validateName(String? value, {int minLength = 2, int maxLength = 50}) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    if (value.trim().length > maxLength) {
      return 'Name must be less than $maxLength characters';
    }
    if (!RegExp(r'^[a-zA-Z\s\-\']+$').hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, hyphens and apostrophes';
    }
    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    final regex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validate min length
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  /// Validate max length
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be less than $maxLength characters';
    }
    return null;
  }

  /// Validate number
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    final numberError = validateNumber(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final number = double.parse(value!);
    if (number <= 0) {
      return '${fieldName ?? 'Value'} must be greater than 0';
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
      return 'Please enter a valid price';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  /// Validate date is in future
  static String? validateFutureDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return '${fieldName ?? 'Date'} is required';
    }
    if (date.isBefore(DateTime.now())) {
      return '${fieldName ?? 'Date'} must be in the future';
    }
    return null;
  }

  /// Validate date range
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) {
      return 'Start date is required';
    }
    if (endDate == null) {
      return 'End date is required';
    }
    if (endDate.isBefore(startDate)) {
      return 'End date must be after start date';
    }
    return null;
  }

  /// Validate OTP
  static String? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter the verification code';
    }
    if (value.length != length) {
      return 'Code must be $length digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Code must contain only numbers';
    }
    return null;
  }

  /// Validate credit card number (Luhn algorithm)
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Please enter a valid card number';
    }
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Card number must contain only digits';
    }

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }

    if (sum % 10 != 0) {
      return 'Please enter a valid card number';
    }

    return null;
  }

  /// Validate CVV
  static String? validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (value.length < 3 || value.length > 4) {
      return 'Please enter a valid CVV';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'CVV must contain only digits';
    }
    return null;
  }

  /// Validate expiry date (MM/YY)
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Please use MM/YY format';
    }

    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || month < 1 || month > 12) {
      return 'Invalid month';
    }

    final currentYear = DateTime.now().year % 100;
    final currentMonth = DateTime.now().month;

    if (year == null || year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }

    return null;
  }
}
