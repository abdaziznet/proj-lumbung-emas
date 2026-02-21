import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/features/pricing/data/models/daily_price_model.dart';
import 'package:lumbungemas/shared/data/services/google_sheets_service.dart';

/// Data source interface for remote price data
abstract class PricingRemoteDataSource {
  /// Get current prices from Daily_Prices sheet
  Future<List<DailyPriceModel>> getCurrentPrices();

  /// Save/Update price in Daily_Prices sheet
  Future<DailyPriceModel> savePrice(DailyPriceModel model);

  /// Delete price entry from Daily_Prices sheet
  Future<void> deletePrice({
    required String brand,
    required String metalType,
  });
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
    final rows = await _sheetsService.read('${AppConstants.sheetDailyPrices}!A:H');
    final targetBrand = model.brand.trim().toLowerCase();
    final targetMetal = model.metalType.trim().toLowerCase();

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final firstCell = row.first.toString().trim().toLowerCase();
      if (firstCell == 'price_id') continue;

      final rowBrand = row.length > 1 ? row[1]?.toString().trim().toLowerCase() : '';
      final rowMetal = row.length > 2 ? row[2]?.toString().trim().toLowerCase() : '';
      if (rowBrand == targetBrand && rowMetal == targetMetal) {
        final existing = DailyPriceModel.fromSheetRow(row);
        final updated = model.copyWith(
          priceId: existing.priceId,
          createdAt: existing.createdAt,
        );
        await _sheetsService.updateRow(
          AppConstants.sheetDailyPrices,
          i + 1,
          updated.toSheetRow(),
        );
        return updated;
      }
    }

    // If not found, append new row (for new brand/metal).
    await _sheetsService.append(
      '${AppConstants.sheetDailyPrices}!A1',
      [model.toSheetRow()],
    );

    return model;
  }

  @override
  Future<void> deletePrice({
    required String brand,
    required String metalType,
  }) async {
    final rows = await _sheetsService.read('${AppConstants.sheetDailyPrices}!A:H');
    final targetBrand = brand.trim().toLowerCase();
    final targetMetal = metalType.trim().toLowerCase();

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final firstCell = row.first.toString().trim().toLowerCase();
      if (firstCell == 'price_id') continue;

      final rowBrand = row.length > 1 ? row[1]?.toString().trim().toLowerCase() : '';
      final rowMetal = row.length > 2 ? row[2]?.toString().trim().toLowerCase() : '';
      if (rowBrand == targetBrand && rowMetal == targetMetal) {
        await _sheetsService.updateRow(
          AppConstants.sheetDailyPrices,
          i + 1,
          List<Object?>.filled(8, ''),
        );
        return;
      }
    }
  }
}
