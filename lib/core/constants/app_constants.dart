/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'LumbungEmas';
  static const String appVersion = '1.0.0';

  // Metal Types
  static const String metalTypeGold = 'GOLD';
  static const String metalTypeSilver = 'SILVER';

  // Supported Brands
  static const List<String> supportedBrands = [
    'Antam',
    'UBS',
    'EmasKu',
    'Galeri 24',
  ];

  // Currency
  static const String currency = 'IDR';
  static const String currencySymbol = 'Rp';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration priceCacheDuration = Duration(minutes: 30);

  // Sync Settings
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxRetryAttempts = 3;

  // Validation Limits
  static const double minWeight = 0.01; // 0.01 gram
  static const double maxWeight = 1000.0; // 1 kg
  static const double minPrice = 1000.0; // Rp 1,000
  static const double maxPrice = 100000000.0; // Rp 100 million

  // Google Sheets - Loaded from environment variables
  // Configure in .env file: GOOGLE_SHEETS_SPREADSHEET_ID=your_id
  // See SETUP.md for instructions
  static String get spreadsheetId {
    // This will be loaded from .env via AppConfig
    // Import: import 'package:lumbungemas/core/config/app_config.dart';
    // Then use: AppConfig.spreadsheetId
    // For now, return placeholder to avoid import cycle
    return 'CONFIGURE_IN_ENV_FILE';
  }

  static const String usersSheetName = 'Users';
  static const String transactionsSheetName = 'Transactions';
  static const String dailyPricesSheetName = 'Daily_Prices';
  static const String portfolioSummarySheetName = 'Portfolio_Summary';

  // Aliases for shorter access
  static const String sheetUsers = usersSheetName;
  static const String sheetTransactions = transactionsSheetName;
  static const String sheetDailyPrices = dailyPricesSheetName;
  static const String sheetPortfolioSummary = portfolioSummarySheetName;

  // Notification Channels
  static const String priceAlertChannelId = 'price_alerts';
  static const String priceAlertChannelName = 'Price Alerts';
  static const String syncChannelId = 'sync_notifications';
  static const String syncChannelName = 'Sync Notifications';

  // Shared Preferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyEnablePriceAlerts = 'enable_price_alerts';
  static const String keyEnableNotifications = 'enable_notifications';

  // Secure Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyGoogleCredentials = 'google_credentials';
}

/// Metal type enumeration
enum MetalType {
  gold,
  silver;

  String get displayName {
    switch (this) {
      case MetalType.gold:
        return 'Gold';
      case MetalType.silver:
        return 'Silver';
    }
  }

  String get apiValue {
    switch (this) {
      case MetalType.gold:
        return AppConstants.metalTypeGold;
      case MetalType.silver:
        return AppConstants.metalTypeSilver;
    }
  }

  static MetalType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'GOLD':
        return MetalType.gold;
      case 'SILVER':
        return MetalType.silver;
      default:
        throw ArgumentError('Invalid metal type: $value');
    }
  }
}

/// Brand enumeration
enum Brand {
  antam,
  ubs,
  emasku,
  galeri24;

  String get displayName {
    switch (this) {
      case Brand.antam:
        return 'Antam';
      case Brand.ubs:
        return 'UBS';
      case Brand.emasku:
        return 'EmasKu';
      case Brand.galeri24:
        return 'Galeri 24';
    }
  }

  static Brand fromString(String value) {
    switch (value.toLowerCase()) {
      case 'antam':
        return Brand.antam;
      case 'ubs':
        return Brand.ubs;
      case 'emasku':
        return Brand.emasku;
      case 'galeri 24':
        return Brand.galeri24;
      default:
        return Brand.antam;
    }
  }
}
