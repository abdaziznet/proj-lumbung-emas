import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';

/// Use case to add a new precious metal transaction
class AddTransactionUseCase {
  final PortfolioRepository _repository;

  AddTransactionUseCase(this._repository);

  Future<Either<Failure, MetalAsset>> call(MetalAsset asset) async {
    return await _repository.addTransaction(asset);
  }
}
