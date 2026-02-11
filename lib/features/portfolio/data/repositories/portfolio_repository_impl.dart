import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:lumbungemas/features/portfolio/data/models/metal_asset_model.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';

/// Implementation of PortfolioRepository
class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource _remoteDataSource;
  // LocalDataSource _localDataSource; // Add later for offline support

  PortfolioRepositoryImpl({
    required PortfolioRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<MetalAsset>>> getPortfolio(String userId) async {
    try {
      final models = await _remoteDataSource.getPortfolio(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(SheetsFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PortfolioSummary>> getPortfolioSummary(String userId) async {
    try {
      final model = await _remoteDataSource.getPortfolioSummary(userId);
      if (model == null) {
        // Return empty summary if not found
        return Right(PortfolioSummary.empty(userId));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(SheetsFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MetalAsset>> addTransaction(MetalAsset asset) async {
    try {
      final model = MetalAssetModel.fromEntity(asset);
      final savedModel = await _remoteDataSource.saveTransaction(model);
      return Right(savedModel.toEntity());
    } catch (e) {
      return Left(SheetsFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MetalAsset>> updateTransaction(MetalAsset asset) async {
    try {
      final model = MetalAssetModel.fromEntity(asset);
      final updatedModel = await _remoteDataSource.saveTransaction(model);
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(SheetsFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    try {
      await _remoteDataSource.deleteTransaction(transactionId);
      return const Right(null);
    } catch (e) {
      return Left(SheetsFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPortfolio(String userId) async {
    // Basic sync: just reload from remote
    return const Right(null);
  }
}
