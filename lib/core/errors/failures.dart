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
    super.message = 'Server error occurred',
    super.code,
    super.details,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code,
    super.details,
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
    super.details,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed',
    super.code,
    super.details,
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Google Sheets API failures
class SheetsFailure extends Failure {
  const SheetsFailure({
    super.message = 'Google Sheets operation failed',
    super.code,
    super.details,
  });
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied',
    super.code,
    super.details,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.code,
    super.details,
  });
}

/// Sync failures
class SyncFailure extends Failure {
  const SyncFailure({
    super.message = 'Synchronization failed',
    super.code,
    super.details,
  });
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    super.code,
    super.details,
  });
}
