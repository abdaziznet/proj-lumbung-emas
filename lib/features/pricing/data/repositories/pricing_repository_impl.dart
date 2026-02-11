import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/pricing/data/datasources/pricing_remote_datasource.dart';
import 'package:lumbungemas/features/pricing/data/models/daily_price_model.dart';
import 'package:lumbungemas/features/pricing/domain/entities/daily_price.dart';
import 'package:lumbungemas/features/pricing/domain/repositories/pricing_repository.dart';

/// Implementation of PricingRepository
class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource _remoteDataSource;

  PricingRepositoryImpl({
    required PricingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<DailyPrice>>> getCurrentPrices() async {
    try {
      final models = await _remoteDataSource.getCurrentPrices();
      
      // Filter to get only the latest price for each brand + metalType
      final latestPricesMap = <String, DailyPriceModel>{};
      
      for (final model in models) {
        final key = '${model.brand}_${model.metalType}';
        final existing = latestPricesMap[key];
        
        if (existing == null || model.priceDate > existing.priceDate) {
          latestPricesMap[key] = model;
        }
      }
      
      return Right(latestPricesMap.values.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(SheetsFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyPrice>>> getPriceHistory({
    required String brand,
    required String metalType,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final models = await _remoteDataSource.getCurrentPrices();
      
      var filtered = models.where((m) => m.brand == brand && m.metalType == metalType);
      
      if (from != null) {
        filtered = filtered.where((m) => m.priceDate >= from.millisecondsSinceEpoch);
      }
      
      if (to != null) {
        filtered = filtered.where((m) => m.priceDate <= to.millisecondsSinceEpoch);
      }
      
      final result = filtered.map((m) => m.toEntity()).toList();
      result.sort((a, b) => b.priceDate.compareTo(a.priceDate)); // Newest first
      
      return Right(result);
    } catch (e) {
      return Left(SheetsFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DailyPrice>> updatePrice(DailyPrice price) async {
    try {
      final model = DailyPriceModel.fromEntity(price);
      final savedModel = await _remoteDataSource.savePrice(model);
      return Right(savedModel.toEntity());
    } catch (e) {
      return Left(SheetsFailure(message: e.toString()));
    }
  }
}
