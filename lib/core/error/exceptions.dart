/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exception - API/Firebase errors
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Network exception - connectivity issues
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
  });
}

/// Cache exception - local storage errors
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error',
    super.code = 'CACHE_ERROR',
    super.originalException,
  });
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Permission denied',
    super.code = 'PERMISSION_DENIED',
  });
}

/// Validation exception
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code = 'NOT_FOUND',
  });
}

/// Upload exception
class UploadException extends AppException {
  const UploadException({
    required super.message,
    super.code = 'UPLOAD_ERROR',
    super.originalException,
  });

  /// Factory for file too large error
  factory UploadException.fileTooLarge() {
    return const UploadException(
      message: 'File size exceeds maximum allowed limit',
      code: 'FILE_TOO_LARGE',
    );
  }

  /// Factory for invalid file type error
  factory UploadException.invalidFileType() {
    return const UploadException(
      message: 'Invalid file type',
      code: 'INVALID_FILE_TYPE',
    );
  }
}
