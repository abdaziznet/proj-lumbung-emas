import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';

class UpdateTransactionUseCase {
  final PortfolioRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<Either<Failure, MetalAsset>> call(MetalAsset asset) {
    return repository.updateTransaction(asset);
  }
}
