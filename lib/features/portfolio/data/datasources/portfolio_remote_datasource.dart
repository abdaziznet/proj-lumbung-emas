import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/features/portfolio/data/models/metal_asset_model.dart';
import 'package:lumbungemas/features/portfolio/data/models/portfolio_summary_model.dart';
import 'package:lumbungemas/shared/data/services/google_sheets_service.dart';

/// Data source interface for remote portfolio data
abstract class PortfolioRemoteDataSource {
  /// Get all assets for a user from Transactions sheet
  Future<List<MetalAssetModel>> getPortfolio(String userId);

  /// Get portfolio summary for a user
  Future<PortfolioSummaryModel?> getPortfolioSummary(String userId);

  /// Save transaction to Transactions sheet
  Future<MetalAssetModel> saveTransaction(MetalAssetModel model);

  /// Delete transaction from Transactions sheet (soft delete)
  Future<void> deleteTransaction(String transactionId);
}

/// Implementation of PortfolioRemoteDataSource using Google Sheets
class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  final GoogleSheetsService _sheetsService;

  PortfolioRemoteDataSourceImpl(this._sheetsService);

  @override
  Future<List<MetalAssetModel>> getPortfolio(String userId) async {
    final rows = await _sheetsService.read('${AppConstants.sheetTransactions}!A:M');
    
    // Skip header row and filter by user ID and not deleted
    return rows
        .skip(1)
        .where((row) => row.length > 1 && row[1].toString() == userId)
        .map((row) => MetalAssetModel.fromSheetRow(row))
        .where((model) => !model.isDeleted)
        .toList();
  }

  @override
  Future<PortfolioSummaryModel?> getPortfolioSummary(String userId) async {
    final rowIndex = await _sheetsService.findRowByValue(
      AppConstants.sheetPortfolioSummary,
      0, // user_id column
      userId,
    );

    if (rowIndex == null) return null;

    final rows = await _sheetsService.read(
      '${AppConstants.sheetPortfolioSummary}!A$rowIndex:I$rowIndex',
    );

    if (rows.isEmpty) return null;
    return PortfolioSummaryModel.fromSheetRow(rows[0]);
  }

  @override
  Future<MetalAssetModel> saveTransaction(MetalAssetModel model) async {
    final rowIndex = await _sheetsService.findRowByValue(
      AppConstants.sheetTransactions,
      0, // transaction_id column
      model.transactionId,
    );

    if (rowIndex != null) {
      // Update existing
      await _sheetsService.updateRow(
        AppConstants.sheetTransactions,
        rowIndex,
        model.toSheetRow(),
      );
    } else {
      // Append new
      await _sheetsService.append(
        '${AppConstants.sheetTransactions}!A1',
        [model.toSheetRow()],
      );
    }

    return model;
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    final rowIndex = await _sheetsService.findRowByValue(
      AppConstants.sheetTransactions,
      0,
      transactionId,
    );

    if (rowIndex != null) {
      await _sheetsService.softDeleteRow(
        AppConstants.sheetTransactions,
        rowIndex,
        11, // is_deleted column index
      );
    }
  }
}
