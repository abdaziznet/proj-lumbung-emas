import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';

class GetPortfolioSummaryUseCase {
  final PortfolioRepository repository;

  GetPortfolioSummaryUseCase(this.repository);

  Future<Either<Failure, PortfolioSummary>> call(String userId) {
    return repository.getPortfolioSummary(userId);
  }
}
