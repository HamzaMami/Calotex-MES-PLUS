/// Abstract base class for all failures.
/// Used to map exceptions from data layer to domain layer.
abstract class Failure {
  final String message;

  Failure(this.message);

  /// Get user-friendly error message.
  String get userMessage => message;

  @override
  String toString() => '$runtimeType: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Server/API error failure.
class ServerFailure extends Failure {
  final int? statusCode;

  ServerFailure({
    required String message,
    this.statusCode,
  }) : super(message);

  @override
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return message;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ServerFailure &&
          statusCode == other.statusCode;

  @override
  int get hashCode => super.hashCode ^ statusCode.hashCode;
}

/// Network connectivity failure.
class NetworkFailure extends Failure {
  NetworkFailure({String? message})
      : super(message ?? 'Network error. Please check your connection.');

  @override
  String get userMessage =>
      'No internet connection. Please check your network and try again.';
}

/// Local cache/storage failure.
class CacheFailure extends Failure {
  CacheFailure({String? message})
      : super(message ?? 'Cache operation failed.');

  @override
  String get userMessage => 'Failed to load cached data. Please try again.';
}

/// Authentication/authorization failure.
class AuthFailure extends Failure {
  final int? statusCode;

  AuthFailure({
    required String message,
    this.statusCode,
  }) : super(message);

  @override
  String get userMessage {
    if (message.isNotEmpty && message != 'Unauthorized' && message != 'An error occurred') {
      return message;
    }
    switch (statusCode) {
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You do not have permission to access this resource.';
      default:
        return message;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is AuthFailure &&
          statusCode == other.statusCode;

  @override
  int get hashCode => super.hashCode ^ statusCode.hashCode;
}

/// Token validation/refresh failure.
class TokenFailure extends Failure {
  TokenFailure({String? message})
      : super(message ?? 'Token operation failed.');

  @override
  String get userMessage => 'Authentication token expired. Please log in again.';
}

/// Validation error failure.
class ValidationFailure extends Failure {
  final Map<String, dynamic>? fieldErrors;

  ValidationFailure({
    required String message,
    this.fieldErrors,
  }) : super(message);

  @override
  String get userMessage => fieldErrors != null && fieldErrors!.isNotEmpty
      ? fieldErrors!.values.first.toString()
      : message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ValidationFailure &&
          fieldErrors == other.fieldErrors;

  @override
  int get hashCode => super.hashCode ^ fieldErrors.hashCode;
}

/// Generic/unexpected failure.
class UnknownFailure extends Failure {
  UnknownFailure({String? message})
      : super(message ?? 'An unexpected error occurred.');

  @override
  String get userMessage => 'Something went wrong. Please try again later.';
}
