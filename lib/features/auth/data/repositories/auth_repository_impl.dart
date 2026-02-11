import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumbungemas/core/errors/exceptions.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';
import 'package:lumbungemas/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Authentication failed', code: e.code));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _remoteDataSource.authStateChanges().map((model) => model?.toEntity());
  }
}
