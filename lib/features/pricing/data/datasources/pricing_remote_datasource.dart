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
    
    // Skip header and map to models
    if (rows.length <= 1) return [];
    
    // We usually want the most recent prices per brand/metal type
    // For now, just return all rows (logic to filter for latest can be in repo or here)
    return rows
        .skip(1)
        .where((row) => row.isNotEmpty)
        .map((row) => DailyPriceModel.fromSheetRow(row))
        .toList();
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
