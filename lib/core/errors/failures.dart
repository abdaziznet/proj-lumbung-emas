import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Server error occurred',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Cache error occurred',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Authentication failed',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Google Sheets API failures
class SheetsFailure extends Failure {
  const SheetsFailure({
    String message = 'Google Sheets operation failed',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'Permission denied',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Resource not found',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Sync failures
class SyncFailure extends Failure {
  const SyncFailure({
    String message = 'Synchronization failed',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'An unknown error occurred',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}
