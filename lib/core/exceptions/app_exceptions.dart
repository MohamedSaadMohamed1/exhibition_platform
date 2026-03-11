import 'package:equatable/equatable.dart';

/// Base class for all app failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthFailure.invalidPhoneNumber() => const AuthFailure(
        message: 'Invalid phone number format',
        code: 'invalid-phone-number',
      );

  factory AuthFailure.invalidOtp() => const AuthFailure(
        message: 'Invalid OTP code',
        code: 'invalid-verification-code',
      );

  factory AuthFailure.otpExpired() => const AuthFailure(
        message: 'OTP code has expired',
        code: 'otp-expired',
      );

  factory AuthFailure.tooManyRequests() => const AuthFailure(
        message: 'Too many requests. Please try again later',
        code: 'too-many-requests',
      );

  factory AuthFailure.userDisabled() => const AuthFailure(
        message: 'This account has been disabled',
        code: 'user-disabled',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Session expired. Please login again',
        code: 'session-expired',
      );

  factory AuthFailure.unknown([String? message]) => AuthFailure(
        message: message ?? 'An unknown authentication error occurred',
        code: 'unknown',
      );
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'No internet connection',
        code: 'no-connection',
      );

  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Connection timed out',
        code: 'timeout',
      );

  factory NetworkFailure.serverError() => const NetworkFailure(
        message: 'Server error. Please try again later',
        code: 'server-error',
      );
}

/// Firestore related failures
class FirestoreFailure extends Failure {
  const FirestoreFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory FirestoreFailure.notFound([String? entity]) => FirestoreFailure(
        message: '${entity ?? 'Document'} not found',
        code: 'not-found',
      );

  factory FirestoreFailure.permissionDenied() => const FirestoreFailure(
        message: 'You do not have permission to perform this action',
        code: 'permission-denied',
      );

  factory FirestoreFailure.alreadyExists([String? entity]) => FirestoreFailure(
        message: '${entity ?? 'Document'} already exists',
        code: 'already-exists',
      );

  factory FirestoreFailure.transactionFailed() => const FirestoreFailure(
        message: 'Transaction failed. Please try again',
        code: 'transaction-failed',
      );

  factory FirestoreFailure.unknown([String? message]) => FirestoreFailure(
        message: message ?? 'An unknown database error occurred',
        code: 'unknown',
      );
}

/// Storage related failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory StorageFailure.uploadFailed() => const StorageFailure(
        message: 'Failed to upload file',
        code: 'upload-failed',
      );

  factory StorageFailure.downloadFailed() => const StorageFailure(
        message: 'Failed to download file',
        code: 'download-failed',
      );

  factory StorageFailure.fileTooLarge() => const StorageFailure(
        message: 'File size exceeds the limit',
        code: 'file-too-large',
      );

  factory StorageFailure.invalidFileType() => const StorageFailure(
        message: 'Invalid file type',
        code: 'invalid-file-type',
      );
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });

  /// Convenience factory with positional message
  factory ValidationFailure.withMessage(String message) => ValidationFailure(
        message: message,
        code: 'validation-error',
      );

  factory ValidationFailure.emptyField(String fieldName) => ValidationFailure(
        message: '$fieldName cannot be empty',
        code: 'empty-field',
      );

  factory ValidationFailure.invalidFormat(String fieldName) => ValidationFailure(
        message: 'Invalid $fieldName format',
        code: 'invalid-format',
      );

  factory ValidationFailure.tooLong(String fieldName, int maxLength) =>
      ValidationFailure(
        message: '$fieldName cannot exceed $maxLength characters',
        code: 'too-long',
      );
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found',
    super.code = 'not-found',
  });

  /// Convenience factory with positional message
  factory NotFoundFailure.withMessage(String message) => NotFoundFailure(
        message: message,
      );
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code = 'server-error',
    super.originalError,
  });

  /// Convenience factory with positional message
  factory ServerFailure.withMessage(String message) => ServerFailure(
        message: message,
      );
}

/// Booking related failures
class BookingFailure extends Failure {
  const BookingFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory BookingFailure.boothNotAvailable() => const BookingFailure(
        message: 'This booth is no longer available',
        code: 'booth-not-available',
      );

  factory BookingFailure.alreadyBooked() => const BookingFailure(
        message: 'You have already booked this booth',
        code: 'already-booked',
      );

  factory BookingFailure.reservationExpired() => const BookingFailure(
        message: 'Your reservation has expired',
        code: 'reservation-expired',
      );

  factory BookingFailure.cannotCancel() => const BookingFailure(
        message: 'This booking cannot be cancelled',
        code: 'cannot-cancel',
      );
}

/// Permission related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });

  factory PermissionFailure.unauthorized() => const PermissionFailure(
        message: 'You are not authorized to perform this action',
        code: 'unauthorized',
      );

  factory PermissionFailure.insufficientRole() => const PermissionFailure(
        message: 'Your role does not allow this action',
        code: 'insufficient-role',
      );

  factory PermissionFailure.notOwner() => const PermissionFailure(
        message: 'You can only modify your own resources',
        code: 'not-owner',
      );
}

/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Extension to convert Firebase exceptions to app failures
extension FirebaseExceptionMapper on Object {
  Failure toFailure() {
    final error = this;
    if (error is Failure) return error;

    // Handle Firebase Auth errors
    if (error.toString().contains('firebase_auth')) {
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('invalid-verification-code')) {
        return AuthFailure.invalidOtp();
      }
      if (errorString.contains('session-expired')) {
        return AuthFailure.otpExpired();
      }
      if (errorString.contains('too-many-requests')) {
        return AuthFailure.tooManyRequests();
      }
      if (errorString.contains('user-disabled')) {
        return AuthFailure.userDisabled();
      }
      return AuthFailure.unknown(error.toString());
    }

    // Handle Firestore errors
    if (error.toString().contains('cloud_firestore')) {
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('not-found')) {
        return FirestoreFailure.notFound();
      }
      if (errorString.contains('permission-denied')) {
        return FirestoreFailure.permissionDenied();
      }
      if (errorString.contains('already-exists')) {
        return FirestoreFailure.alreadyExists();
      }
      return FirestoreFailure.unknown(error.toString());
    }

    // Default network error
    if (error.toString().contains('SocketException') ||
        error.toString().contains('ClientException')) {
      return NetworkFailure.noConnection();
    }

    return FirestoreFailure.unknown(error.toString());
  }
}
