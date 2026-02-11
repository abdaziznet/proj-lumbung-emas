import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/pricing/domain/entities/daily_price.dart';
import 'package:lumbungemas/features/pricing/domain/repositories/pricing_repository.dart';

class GetCurrentPricesUseCase {
  final PricingRepository repository;

  GetCurrentPricesUseCase(this.repository);

  Future<Either<Failure, List<DailyPrice>>> call() {
    return repository.getCurrentPrices();
  }
}
