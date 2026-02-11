import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';

/// Use case to fetch user portfolio
class GetPortfolioUseCase {
  final PortfolioRepository _repository;

  GetPortfolioUseCase(this._repository);

  Future<Either<Failure, List<MetalAsset>>> call(String userId) async {
    return await _repository.getPortfolio(userId);
  }
}
