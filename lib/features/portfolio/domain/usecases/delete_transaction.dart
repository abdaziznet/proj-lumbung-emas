import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';

class DeleteTransactionUseCase {
  final PortfolioRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<Either<Failure, void>> call(String transactionId) {
    return repository.deleteTransaction(transactionId);
  }
}
