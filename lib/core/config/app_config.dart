import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Application configuration loaded from environment variables
class AppConfig {
  AppConfig._();

  /// Get Google Sheets Spreadsheet ID from environment
  static String get spreadsheetId {
    var id = dotenv.env['GOOGLE_SHEETS_SPREADSHEET_ID'];
    if (id == null || id.isEmpty) {
      throw Exception(
        'GOOGLE_SHEETS_SPREADSHEET_ID not found in .env file.\n'
        'Please follow these steps:\n'
        '1. Copy .env.example to .env\n'
        '2. Edit .env and add your Google Sheets Spreadsheet ID\n'
        '3. Get the ID from your spreadsheet URL:\n'
        '   https://docs.google.com/spreadsheets/d/[SPREADSHEET_ID]/edit',
      );
    }
    // Clean up ID (remove spaces and quotes)
    id = id.trim();
    if (id.startsWith('"') && id.endsWith('"')) {
      id = id.substring(1, id.length - 1);
    }
    if (id.startsWith("'") && id.endsWith("'")) {
      id = id.substring(1, id.length - 1);
    }
    return id;
  }

  /// Get environment-specific spreadsheet ID
  static String getSpreadsheetId(String environment) {
    final key = 'GOOGLE_SHEETS_SPREADSHEET_ID_${environment.toUpperCase()}';
    return dotenv.env[key] ?? spreadsheetId;
  }

  /// Get current environment
  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }

  /// Check if running in production
  static bool get isProduction {
    return environment == 'production';
  }

  /// Check if running in development
  static bool get isDevelopment {
    return environment == 'development';
  }

  /// Check if running in staging
  static bool get isStaging {
    return environment == 'staging';
  }

  /// Check if analytics is enabled
  static bool get isAnalyticsEnabled {
    return dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  }

  /// Check if crash reporting is enabled
  static bool get isCrashReportingEnabled {
    return dotenv.env['ENABLE_CRASH_REPORTING']?.toLowerCase() == 'true';
  }

  /// Check if debug logging is enabled
  static bool get isDebugLoggingEnabled {
    return dotenv.env['ENABLE_DEBUG_LOGGING']?.toLowerCase() == 'true' ||
        isDevelopment;
  }

  /// Validate all required configuration
  static void validate() {
    try {
      // This will throw if spreadsheet ID is not configured
      final _ = spreadsheetId;
    } catch (e) {
      rethrow;
    }
  }

  /// Print configuration (for debugging, without sensitive data)
  static void printConfig() {
    if (!isDebugLoggingEnabled) return;

    debugPrint('=== App Configuration ===');
    debugPrint('Environment: $environment');
    debugPrint('Spreadsheet ID: ${spreadsheetId.substring(0, 10)}...');
    debugPrint('Analytics: $isAnalyticsEnabled');
    debugPrint('Crash Reporting: $isCrashReportingEnabled');
    debugPrint('Debug Logging: $isDebugLoggingEnabled');
    debugPrint('========================');
  }
}
