/// Custom exception hierarchy for type-safe error handling.
///
/// All app-specific exceptions extend [AppException] for consistent
/// error handling throughout the application.
library;

/// Base exception class for all application-specific exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception for network-related errors.
class NetworkException extends AppException {
  final int? statusCode;
  final bool isTimeout;

  const NetworkException(
    super.message, {
    this.statusCode,
    this.isTimeout = false,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.noConnection() {
    return const NetworkException(
      'No internet connection',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      'Request timed out',
      isTimeout: true,
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.fromStatusCode(int statusCode, [String? message]) {
    final defaultMessage = switch (statusCode) {
      400 => 'Bad request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not found',
      408 => 'Request timeout',
      429 => 'Too many requests',
      500 => 'Internal server error',
      502 => 'Bad gateway',
      503 => 'Service unavailable',
      504 => 'Gateway timeout',
      _ => 'Network error',
    };

    return NetworkException(
      message ?? defaultMessage,
      statusCode: statusCode,
      code: 'HTTP_$statusCode',
    );
  }
}

/// Exception for authentication-related errors.
/// Named AppAuthException to avoid conflict with Supabase's AuthException.
class AppAuthException extends AppException {
  final AuthErrorType type;

  const AppAuthException(
    super.message, {
    required this.type,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AppAuthException.invalidCredentials() {
    return const AppAuthException(
      'Invalid email or password',
      type: AuthErrorType.invalidCredentials,
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AppAuthException.sessionExpired() {
    return const AppAuthException(
      'Your session has expired',
      type: AuthErrorType.sessionExpired,
      code: 'SESSION_EXPIRED',
    );
  }

  factory AppAuthException.emailNotVerified() {
    return const AppAuthException(
      'Please verify your email address',
      type: AuthErrorType.emailNotVerified,
      code: 'EMAIL_NOT_VERIFIED',
    );
  }

  factory AppAuthException.userNotFound() {
    return const AppAuthException(
      'No account found with this email',
      type: AuthErrorType.userNotFound,
      code: 'USER_NOT_FOUND',
    );
  }

  factory AppAuthException.weakPassword() {
    return const AppAuthException(
      'Password is too weak',
      type: AuthErrorType.weakPassword,
      code: 'WEAK_PASSWORD',
    );
  }

  factory AppAuthException.emailAlreadyInUse() {
    return const AppAuthException(
      'An account with this email already exists',
      type: AuthErrorType.emailAlreadyInUse,
      code: 'EMAIL_IN_USE',
    );
  }
}

/// Types of authentication errors.
enum AuthErrorType {
  invalidCredentials,
  sessionExpired,
  emailNotVerified,
  userNotFound,
  weakPassword,
  emailAlreadyInUse,
  unknown,
}

/// Exception for form validation errors.
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
  });

  factory ValidationException.field(String field, String error) {
    return ValidationException(
      error,
      fieldErrors: {field: error},
      code: 'VALIDATION_ERROR',
    );
  }

  factory ValidationException.fields(Map<String, String> errors) {
    final firstError = errors.values.firstOrNull ?? 'Validation error';
    return ValidationException(
      firstError,
      fieldErrors: errors,
      code: 'VALIDATION_ERROR',
    );
  }
}

/// Exception for API-related errors.
class ApiException extends AppException {
  final int? statusCode;
  final String? endpoint;

  const ApiException(
    super.message, {
    this.statusCode,
    this.endpoint,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception for caching-related errors.
class CacheException extends AppException {
  final String? key;

  const CacheException(
    super.message, {
    this.key,
    super.code,
    super.originalError,
  });
}

/// Exception for database-related errors.
class DatabaseException extends AppException {
  final String? table;

  const DatabaseException(
    super.message, {
    this.table,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception for permission-related errors.
class PermissionException extends AppException {
  final String? permission;

  const PermissionException(
    super.message, {
    this.permission,
    super.code,
  });
}

/// Exception for data parsing errors.
class ParsingException extends AppException {
  final String? dataType;

  const ParsingException(
    super.message, {
    this.dataType,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}
