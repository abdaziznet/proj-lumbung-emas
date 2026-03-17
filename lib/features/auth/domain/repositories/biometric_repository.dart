import 'package:dartz/dartz.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';

/// Repository interface for biometric operations
abstract class BiometricRepository {
  /// Check if device supports biometric authentication
  Future<Either<Failure, bool>> isBiometricAvailable();

  /// Get list of available biometric types
  Future<Either<Failure, List<BiometricType>>> getAvailableBiometrics();

  /// Authenticate user with biometric
  Future<Either<Failure, bool>> authenticate({required String localizedReason});

  /// Check if biometric is enabled
  Future<Either<Failure, bool>> isBiometricEnabled();

  /// Enable biometric with session token
  Future<Either<Failure, void>> enableBiometric(
    String sessionToken,
    UserEntity user,
  );

  /// Disable biometric
  Future<Either<Failure, void>> disableBiometric();

  /// Get stored biometric session token
  Future<Either<Failure, String?>> getBiometricSessionToken();

  /// Get stored biometric user
  Future<Either<Failure, UserEntity?>> getBiometricUser();

  /// Clear all biometric data
  Future<Either<Failure, void>> clearBiometricData();
}
