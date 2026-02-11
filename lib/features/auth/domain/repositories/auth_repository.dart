import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with Google account
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Get currently signed-in user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Listen to auth state changes
  Stream<UserEntity?> authStateChanges();
}
