import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'failures.dart';
import 'exceptions.dart';

/// Global error handler for converting exceptions to failures
class ErrorHandler {
  ErrorHandler._();

  /// Handle any exception and convert to appropriate Failure
  static Failure handleException(dynamic exception) {
    if (exception is Failure) {
      return exception;
    }

    if (exception is FirebaseAuthException) {
      return _handleFirebaseAuthException(exception);
    }

    if (exception is FirebaseException) {
      return _handleFirebaseException(exception);
    }

    if (exception is AppException) {
      return _handleAppException(exception);
    }

    return UnknownFailure(
      message: exception.toString(),
      originalError: exception,
    );
  }

  /// Handle Firebase Auth exceptions
  static Failure _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return const AuthFailure(
          message: 'The phone number is invalid.',
          code: 'INVALID_PHONE',
        );
      case 'invalid-verification-code':
        return AuthFailure.invalidOtp();
      case 'session-expired':
        return AuthFailure.otpExpired();
      case 'too-many-requests':
        return AuthFailure.tooManyRequests();
      case 'user-disabled':
        return const AuthFailure(
          message: 'This account has been disabled.',
          code: 'USER_DISABLED',
        );
      case 'quota-exceeded':
        return const AuthFailure(
          message: 'SMS quota exceeded. Please try again later.',
          code: 'QUOTA_EXCEEDED',
        );
      case 'network-request-failed':
        return const NetworkFailure();
      default:
        return AuthFailure(
          message: e.message ?? 'Authentication error occurred.',
          code: e.code,
          originalError: e,
        );
    }
  }

  /// Handle Firebase exceptions
  static Failure _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const PermissionFailure();
      case 'not-found':
        return const NotFoundFailure();
      case 'unavailable':
        return const NetworkFailure(
          message: 'Service temporarily unavailable. Please try again later.',
        );
      case 'cancelled':
        return const ServerFailure(
          message: 'Operation was cancelled.',
          code: 'CANCELLED',
        );
      case 'deadline-exceeded':
        return const ServerFailure(
          message: 'Request timed out. Please try again.',
          code: 'TIMEOUT',
        );
      case 'already-exists':
        return const ServerFailure(
          message: 'Resource already exists.',
          code: 'ALREADY_EXISTS',
        );
      default:
        return ServerFailure(
          message: e.message ?? 'Server error occurred.',
          code: e.code,
          originalError: e,
        );
    }
  }

  /// Handle app exceptions
  static Failure _handleAppException(AppException e) {
    if (e is NetworkException) {
      return const NetworkFailure();
    }
    if (e is CacheException) {
      return CacheFailure(
        message: e.message,
        originalError: e.originalException,
      );
    }
    if (e is AuthException) {
      return AuthFailure(
        message: e.message,
        code: e.code,
        originalError: e.originalException,
      );
    }
    if (e is PermissionException) {
      return PermissionFailure(message: e.message);
    }
    if (e is ValidationException) {
      return ValidationFailure(
        message: e.message,
        fieldErrors: e.fieldErrors,
      );
    }
    if (e is NotFoundException) {
      return NotFoundFailure(message: e.message);
    }
    if (e is UploadException) {
      return UploadFailure(
        message: e.message,
        originalError: e.originalException,
      );
    }
    if (e is ServerException) {
      return ServerFailure(
        message: e.message,
        code: e.code,
        originalError: e.originalException,
      );
    }

    return UnknownFailure(
      message: e.message,
      originalError: e,
    );
  }

  /// Get user-friendly message from failure
  static String getErrorMessage(Failure failure) {
    return failure.message;
  }
}
