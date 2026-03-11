import 'package:equatable/equatable.dart';

/// Base failure class for all failures in the app
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

/// Server failure - API/Firebase errors
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory ServerFailure.fromException(dynamic exception) {
    return ServerFailure(
      message: exception.toString(),
      originalError: exception,
    );
  }

  /// Convenience factory with positional message
  factory ServerFailure.withMessage(String message) {
    return ServerFailure(message: message);
  }
}

/// Network failure - connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Cache failure - local storage errors
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred.',
    super.code = 'CACHE_ERROR',
    super.originalError,
  });
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthFailure.invalidCredentials() {
    return const AuthFailure(
      message: 'Invalid phone number or OTP.',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthFailure.sessionExpired() {
    return const AuthFailure(
      message: 'Your session has expired. Please login again.',
      code: 'SESSION_EXPIRED',
    );
  }

  factory AuthFailure.userNotFound() {
    return const AuthFailure(
      message: 'User not found.',
      code: 'USER_NOT_FOUND',
    );
  }

  factory AuthFailure.tooManyRequests() {
    return const AuthFailure(
      message: 'Too many requests. Please try again later.',
      code: 'TOO_MANY_REQUESTS',
    );
  }

  factory AuthFailure.invalidOtp() {
    return const AuthFailure(
      message: 'Invalid OTP. Please check and try again.',
      code: 'INVALID_OTP',
    );
  }

  factory AuthFailure.otpExpired() {
    return const AuthFailure(
      message: 'OTP has expired. Please request a new one.',
      code: 'OTP_EXPIRED',
    );
  }
}

/// Permission failure - insufficient permissions
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'PERMISSION_DENIED',
  });
}

/// Validation failure - input validation errors
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
}

/// Not found failure - resource not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 'NOT_FOUND',
  });

  /// Convenience factory for custom message
  factory NotFoundFailure.withMessage(String message) {
    return NotFoundFailure(message: message);
  }
}

/// Upload failure - file upload errors
class UploadFailure extends Failure {
  const UploadFailure({
    required super.message,
    super.code = 'UPLOAD_ERROR',
    super.originalError,
  });

  factory UploadFailure.fileTooLarge() {
    return const UploadFailure(
      message: 'File size exceeds the maximum allowed limit.',
      code: 'FILE_TOO_LARGE',
    );
  }

  factory UploadFailure.invalidFileType() {
    return const UploadFailure(
      message: 'Invalid file type. Please upload a supported file format.',
      code: 'INVALID_FILE_TYPE',
    );
  }
}

/// Unknown failure - unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNKNOWN_ERROR',
    super.originalError,
  });
}
