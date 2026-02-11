import 'package:intl/intl.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';

/// Currency formatter utility for Indonesian Rupiah
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static final NumberFormat _formatterWithDecimals = NumberFormat.currency(
    locale: 'id_ID',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  /// Format currency without decimals (default)
  /// Example: 1000000 -> Rp 1.000.000
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format currency with decimals
  /// Example: 1000000.50 -> Rp 1.000.000,50
  static String formatWithDecimals(double amount) {
    return _formatterWithDecimals.format(amount);
  }

  /// Format currency in compact form
  /// Example: 1000000 -> Rp 1M
  static String formatCompact(double amount) {
    return _compactFormatter.format(amount);
  }

  /// Format profit/loss with sign and color indication
  /// Returns a formatted string with + or - prefix
  static String formatProfitLoss(double amount) {
    final formatted = format(amount.abs());
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Format percentage
  /// Example: 10.5 -> +10.5%
  static String formatPercentage(double percentage) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(2)}%';
  }

  /// Parse currency string to double
  /// Example: "Rp 1.000.000" -> 1000000.0
  static double? parse(String value) {
    try {
      // Remove currency symbol and whitespace
      String cleaned = value
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Format weight in grams
  /// Example: 1.5 -> 1.5g
  static String formatWeight(double grams) {
    return '${grams.toStringAsFixed(2)}g';
  }

  /// Format price per gram
  /// Example: 1000000 -> Rp 1.000.000/g
  static String formatPricePerGram(double price) {
    return '${format(price)}/g';
  }
}
