import 'package:dartz/dartz.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/auth/data/datasources/biometric_local_datasource.dart';
import 'package:lumbungemas/features/auth/domain/repositories/biometric_repository.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricLocalDataSource localDataSource;

  BiometricRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() async {
    try {
      final result = await localDataSource.isBiometricAvailable();
      return Right(result);
    } catch (e) {
      return Left(BiometricFailure('Failed to check biometric availability'));
    }
  }

  @override
  Future<Either<Failure, List<BiometricType>>> getAvailableBiometrics() async {
    try {
      final result = await localDataSource.getAvailableBiometrics();
      return Right(result);
    } catch (e) {
      return Left(BiometricFailure('Failed to get available biometrics'));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticate({
    required String localizedReason,
  }) async {
    try {
      final result = await localDataSource.authenticate(
        localizedReason: localizedReason,
      );
      return Right(result);
    } catch (e) {
      return Left(BiometricFailure('Biometric authentication failed'));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricEnabled() async {
    try {
      final result = await localDataSource.isBiometricEnabled();
      return Right(result);
    } catch (e) {
      return Left(BiometricFailure('Failed to check biometric status'));
    }
  }

  @override
  Future<Either<Failure, void>> enableBiometric(
    String sessionToken,
    UserEntity user,
  ) async {
    try {
      await localDataSource.enableBiometric(sessionToken, user);
      return const Right(null);
    } catch (e) {
      return Left(BiometricFailure('Failed to enable biometric'));
    }
  }

  @override
  Future<Either<Failure, void>> disableBiometric() async {
    try {
      await localDataSource.disableBiometric();
      return const Right(null);
    } catch (e) {
      return Left(BiometricFailure('Failed to disable biometric'));
    }
  }

  @override
  Future<Either<Failure, String?>> getBiometricSessionToken() async {
    try {
      final result = await localDataSource.getBiometricSessionToken();
      return Right(result);
    } catch (e) {
      return Left(BiometricFailure('Failed to get biometric session token'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getBiometricUser() async {
    try {
      final result = await localDataSource.getBiometricUser();
      return Right(result);
    } catch (e) {
      return Left(BiometricFailure('Failed to get biometric user'));
    }
  }

  @override
  Future<Either<Failure, void>> clearBiometricData() async {
    try {
      await localDataSource.clearBiometricData();
      return const Right(null);
    } catch (e) {
      return Left(BiometricFailure('Failed to clear biometric data'));
    }
  }
}

class BiometricFailure extends Failure {
  BiometricFailure(String message) : super(message: message);
}
