import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Security utilities for the app
class SecurityUtils {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Generate a random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Generate a secure token
  static String generateSecureToken() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Hash a string using SHA256
  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash password with salt
  static String hashPassword(String password, String salt) {
    return hashSha256('$password$salt');
  }

  /// Generate a salt
  static String generateSalt() {
    return generateRandomString(32);
  }

  /// Secure storage operations
  static Future<void> secureWrite(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> secureRead(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> secureDelete(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> secureDeleteAll() async {
    await _secureStorage.deleteAll();
  }

  static Future<Map<String, String>> secureReadAll() async {
    return await _secureStorage.readAll();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^\+?[\d\s-]{10,}$');
    return regex.hasMatch(phone);
  }

  /// Validate password strength
  static PasswordStrength validatePasswordStrength(String password) {
    if (password.length < 6) {
      return PasswordStrength.weak;
    }

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) score++;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) score++;

    // Contains numbers
    if (password.contains(RegExp(r'[0-9]'))) score++;

    // Contains special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// Mask sensitive data
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 2) {
      return '***@$domain';
    }

    final visibleChars = localPart.substring(0, 2);
    return '$visibleChars***@$domain';
  }

  static String maskPhoneNumber(String phone) {
    if (phone.length < 4) return '****';
    return '****${phone.substring(phone.length - 4)}';
  }

  static String maskCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length < 4) return '****';
    return '**** **** **** ${cleaned.substring(cleaned.length - 4)}';
  }

  /// Sanitize user input
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp('[<>"\']'), '') // Remove special chars
        .trim();
  }

  /// Check for SQL injection patterns
  static bool containsSqlInjection(String input) {
    final patterns = [
      RegExp(r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE)\b)', caseSensitive: false),
      RegExp('(--|;|\'|"|/\\*|\\*/)', caseSensitive: false),
      RegExp(r'(\bOR\b|\bAND\b)\s*\d+\s*=\s*\d+', caseSensitive: false),
    ];

    return patterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Check for XSS patterns
  static bool containsXss(String input) {
    final patterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
    ];

    return patterns.any((pattern) => pattern.hasMatch(input));
  }
}

enum PasswordStrength { weak, medium, strong }

/// Secure storage keys
class SecureStorageKeys {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String biometricEnabled = 'biometric_enabled';
  static const String pinCode = 'pin_code';
  static const String deviceId = 'device_id';
}
