import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/pricing/domain/entities/daily_price.dart';

/// Repository interface for gold/silver price operations
abstract class PricingRepository {
  /// Get current prices for all brands
  Future<Either<Failure, List<DailyPrice>>> getCurrentPrices();

  /// Get price history for a specific brand and metal type
  Future<Either<Failure, List<DailyPrice>>> getPriceHistory({
    required String brand,
    required String metalType,
    DateTime? from,
    DateTime? to,
  });

  /// Update price for a brand (usually by admin/automated task)
  Future<Either<Failure, DailyPrice>> updatePrice(DailyPrice price);

  /// Delete price entry for a brand and metal type
  Future<Either<Failure, void>> deletePrice({
    required String brand,
    required String metalType,
  });
}
