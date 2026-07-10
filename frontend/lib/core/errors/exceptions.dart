
/// Base exception for server/API errors.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ServerException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

/// Exception for network connectivity errors.
class NetworkException implements Exception {
  final String message;
  final dynamic originalError;

  NetworkException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for local cache/storage errors.
class CacheException implements Exception {
  final String message;
  final dynamic originalError;

  CacheException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Exception for authentication/authorization errors.
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  AuthException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'AuthException(statusCode: $statusCode, message: $message)';
}

/// Exception for token-related errors (invalid, expired, etc).
class TokenException implements Exception {
  final String message;
  final dynamic originalError;

  TokenException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'TokenException: $message';
}

/// Exception for validation errors.
class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  ValidationException({
    required this.message,
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception for unknown/unexpected errors.
class UnknownException implements Exception {
  final String message;
  final dynamic originalError;

  UnknownException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'UnknownException: $message';
}
