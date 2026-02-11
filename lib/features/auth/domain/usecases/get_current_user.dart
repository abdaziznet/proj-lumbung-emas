import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';
import 'package:lumbungemas/features/auth/domain/repositories/auth_repository.dart';

/// Use case to get current user
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, UserEntity?>> call() async {
    return await _repository.getCurrentUser();
  }
}
