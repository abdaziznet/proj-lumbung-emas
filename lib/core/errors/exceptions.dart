/// Custom exceptions for the application
class ServerException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  ServerException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

class CacheException implements Exception {
  final String message;
  final String? code;

  CacheException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({
    this.message = 'No internet connection',
  });

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  ValidationException({
    required this.message,
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class SheetsException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  SheetsException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'SheetsException: $message (code: $code)';
}

class PermissionException implements Exception {
  final String message;

  PermissionException({
    this.message = 'Permission denied',
  });

  @override
  String toString() => 'PermissionException: $message';
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException({
    this.message = 'Resource not found',
  });

  @override
  String toString() => 'NotFoundException: $message';
}
