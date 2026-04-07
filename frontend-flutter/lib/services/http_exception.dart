/// Custom exception classes for API and network operations
/// Comprehensive error handling with typed exceptions for different error scenarios

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Exception for API errors (4xx, 5xx responses)
class ApiException extends AppException {
  final int? statusCode;
  final dynamic responseBody;

  ApiException({
    required String message,
    this.statusCode,
    this.responseBody,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'API_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );

  /// Check if error is due to invalid credentials
  bool get isUnauthorized => statusCode == 401;

  /// Check if error is due to forbidden access
  bool get isForbidden => statusCode == 403;

  /// Check if error is due to not found
  bool get isNotFound => statusCode == 404;

  /// Check if error is due to validation
  bool get isValidationError => statusCode == 422;

  /// Check if error is server error
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Check if error is rate limited
  bool get isRateLimited => statusCode == 429;

  /// Check if error is client error
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
}

/// Exception for network-related errors (no internet, DNS failure, etc.)
class NetworkException extends AppException {
  NetworkException({
    String message = 'Network error occurred. Please check your internet connection.',
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'NETWORK_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Exception for request timeout
class TimeoutException extends AppException {
  TimeoutException({
    String message = 'Request timeout. Please try again.',
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'TIMEOUT_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Exception for unauthorized access (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException({
    String message = 'Unauthorized. Please login again.',
    int? statusCode = 401,
    dynamic responseBody,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    statusCode: statusCode,
    responseBody: responseBody,
    code: code ?? 'UNAUTHORIZED',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Exception for server errors (5xx)
class ServerException extends ApiException {
  ServerException({
    String message = 'Server error. Please try again later.',
    int? statusCode,
    dynamic responseBody,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    statusCode: statusCode,
    responseBody: responseBody,
    code: code ?? 'SERVER_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Exception for validation errors (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? fieldErrors;

  ValidationException({
    String message = 'Validation error occurred.',
    this.fieldErrors,
    int? statusCode = 422,
    dynamic responseBody,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    statusCode: statusCode,
    responseBody: responseBody,
    code: code ?? 'VALIDATION_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );

  /// Get specific field error
  String? getFieldError(String fieldName) => fieldErrors?[fieldName];

  /// Get all field errors as formatted string
  String? get fieldErrorsString {
    if (fieldErrors == null || fieldErrors!.isEmpty) return null;
    final errors = fieldErrors!.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    return errors;
  }
}

/// Exception for cache-related errors
class CacheException extends AppException {
  CacheException({
    String message = 'Cache error occurred.',
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'CACHE_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Exception for local storage errors
class StorageException extends AppException {
  StorageException({
    String message = 'Storage operation failed.',
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'STORAGE_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}
