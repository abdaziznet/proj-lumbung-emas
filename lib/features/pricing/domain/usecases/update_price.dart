import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/pricing/domain/entities/daily_price.dart';
import 'package:lumbungemas/features/pricing/domain/repositories/pricing_repository.dart';

class UpdatePriceUseCase {
  final PricingRepository repository;

  UpdatePriceUseCase(this.repository);

  Future<Either<Failure, DailyPrice>> call(DailyPrice price) {
    return repository.updatePrice(price);
  }
}
