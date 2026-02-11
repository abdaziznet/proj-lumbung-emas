import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/portfolio_summary.dart';

/// Repository interface for portfolio and transaction operations
abstract class PortfolioRepository {
  /// Get all assets for a user
  Future<Either<Failure, List<MetalAsset>>> getPortfolio(String userId);

  /// Get portfolio summary for a user
  Future<Either<Failure, PortfolioSummary>> getPortfolioSummary(String userId);

  /// Add a new transaction
  Future<Either<Failure, MetalAsset>> addTransaction(MetalAsset asset);

  /// Update an existing transaction
  Future<Either<Failure, MetalAsset>> updateTransaction(MetalAsset asset);

  /// Delete a transaction (soft delete)
  Future<Either<Failure, void>> deleteTransaction(String transactionId);

  /// Sync local changes with remote
  Future<Either<Failure, void>> syncPortfolio(String userId);
}
