import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/pricing/domain/repositories/pricing_repository.dart';

class DeletePriceUseCase {
  final PricingRepository repository;

  DeletePriceUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String brand,
    required String metalType,
  }) {
    return repository.deletePrice(
      brand: brand,
      metalType: metalType,
    );
  }
}
