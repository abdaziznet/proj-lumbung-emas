import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/features/pricing/data/models/daily_price_model.dart';
import 'package:lumbungemas/shared/data/services/google_sheets_service.dart';

/// Data source interface for remote price data
abstract class PricingRemoteDataSource {
  /// Get current prices from Daily_Prices sheet
  Future<List<DailyPriceModel>> getCurrentPrices();

  /// Save/Update price in Daily_Prices sheet
  Future<DailyPriceModel> savePrice(DailyPriceModel model);
}

/// Implementation of PricingRemoteDataSource using Google Sheets
class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final GoogleSheetsService _sheetsService;

  PricingRemoteDataSourceImpl(this._sheetsService);

  @override
  Future<List<DailyPriceModel>> getCurrentPrices() async {
    final rows = await _sheetsService.read('${AppConstants.sheetDailyPrices}!A:H');

    if (rows.isEmpty) return [];

    final result = <DailyPriceModel>[];
    for (final row in rows) {
      if (row.isEmpty) continue;

      // Skip header row if present
      final firstCell = row.first.toString().trim().toLowerCase();
      if (firstCell == 'price_id') continue;

      try {
        final model = DailyPriceModel.fromSheetRow(row);
        if (model.brand.trim().isEmpty) continue;
        result.add(model);
      } catch (_) {
        // Skip malformed rows, keep remaining valid data
      }
    }

    return result;
  }

  @override
  Future<DailyPriceModel> savePrice(DailyPriceModel model) async {
    // Check if price for this brand/metal/date already exists
    // (Simplification: just append new prices for history)
    await _sheetsService.append(
      '${AppConstants.sheetDailyPrices}!A1',
      [model.toSheetRow()],
    );
    
    return model;
  }
}
