import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/auth/domain/repositories/auth_repository.dart';

/// Use case to sign out
class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    return await _repository.signOut();
  }
}
