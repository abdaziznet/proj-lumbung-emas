import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lumbungemas/core/config/app_config.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/core/config/service_account_config.dart';
import 'package:lumbungemas/core/errors/exceptions.dart';
import 'package:logger/logger.dart';

/// Google Sheets API service for data persistence
/// This service handles all interactions with Google Sheets as the primary database
class GoogleSheetsService {
  final GoogleSignIn _googleSignIn;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  sheets.SheetsApi? _sheetsApi;
  String? _spreadsheetId;

  GoogleSheetsService({
    required GoogleSignIn googleSignIn,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  })  : _googleSignIn = googleSignIn,
        _secureStorage = secureStorage,
        _logger = logger {
    _spreadsheetId = AppConfig.spreadsheetId;
  }

  /// Initialize the Sheets API with authenticated credentials
  Future<void> initialize() async {
    try {
      final account = _googleSignIn.currentUser;
      if (account == null) {
        throw AuthException(
          message: 'No authenticated user found',
          code: 'NO_USER',
        );
      }

      final authHeaders = await account.authHeaders;
      final credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          authHeaders['Authorization']!.replaceAll('Bearer ', ''),
          DateTime.now().add(const Duration(hours: 1)).toUtc(),
        ),
        null,
        [sheets.SheetsApi.spreadsheetsScope],
      );

      final client = authenticatedClient(
        http.Client(),
        credentials,
      );

      _sheetsApi = sheets.SheetsApi(client);
      _logger.i('Google Sheets API initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Google Sheets API', error: e);
      throw SheetsException(
        message: 'Failed to initialize Google Sheets API',
        details: e,
      );
    }
  }

  /// Authenticate using Service Account (for production)
  /// This method doesn't require user login
  Future<void> authenticateWithServiceAccount() async {
    try {
      _logger.i('Authenticating with service account...');
      
      // Get service account credentials
      final credentials = await ServiceAccountConfig.getCredentials();
      
      if (credentials == null) {
        throw SheetsException(
          message: 'Service account credentials not configured.\n'
              'Please check SERVICE_ACCOUNT_QUICK_GUIDE.md for setup instructions.',
        );
      }

      // Validate credentials
      if (!await ServiceAccountConfig.validate()) {
        throw SheetsException(
          message: 'Invalid service account credentials.\n'
              'Please ensure the JSON file is valid.',
        );
      }

      // Create service account credentials
      final accountCredentials = ServiceAccountCredentials.fromJson(credentials);
      
      // Define scopes
      final scopes = [sheets.SheetsApi.spreadsheetsScope];
      
      // Get authenticated HTTP client
      final authClient = await clientViaServiceAccount(
        accountCredentials,
        scopes,
      );
      
      // Create Sheets API client
      _sheetsApi = sheets.SheetsApi(authClient);
      
      _logger.i('✅ Authenticated with service account: ${await ServiceAccountConfig.getClientEmail()}');
    } catch (e) {
      _logger.e('❌ Service account authentication failed', error: e);
      throw SheetsException(
        message: 'Failed to authenticate with service account: ${e.toString()}',
        details: e,
      );
    }
  }

  /// Read data from a specific range
  Future<List<List<Object?>>> read(String range) async {
    try {
      _ensureInitialized();

      final response = await _sheetsApi!.spreadsheets.values.get(
        _spreadsheetId!,
        range,
      );

      return response.values ?? [];
    } catch (e) {
      _logger.e('Failed to read from Google Sheets', error: e);
      throw SheetsException(
        message: 'Failed to read data from Google Sheets',
        code: 'READ_ERROR',
        details: e,
      );
    }
  }

  /// Batch read from multiple ranges
  Future<List<List<List<Object?>>>> batchRead(List<String> ranges) async {
    try {
      _ensureInitialized();

      final response = await _sheetsApi!.spreadsheets.values.batchGet(
        _spreadsheetId!,
        ranges: ranges,
        majorDimension: 'ROWS',
      );

      return response.valueRanges
              ?.map((vr) => vr.values ?? <List<Object?>>[])
              .toList() ??
          [];
    } catch (e) {
      _logger.e('Failed to batch read from Google Sheets', error: e);
      throw SheetsException(
        message: 'Failed to batch read data',
        code: 'BATCH_READ_ERROR',
        details: e,
      );
    }
  }

  /// Write data to a specific range
  Future<void> write(String range, List<List<Object?>> values) async {
    try {
      _ensureInitialized();

      final valueRange = sheets.ValueRange.fromJson({
        'range': range,
        'values': values,
      });

      await _sheetsApi!.spreadsheets.values.update(
        valueRange,
        _spreadsheetId!,
        range,
        valueInputOption: 'USER_ENTERED',
      );

      _logger.i('Successfully wrote data to range: $range');
    } catch (e) {
      _logger.e('Failed to write to Google Sheets', error: e);
      throw SheetsException(
        message: 'Failed to write data to Google Sheets',
        code: 'WRITE_ERROR',
        details: e,
      );
    }
  }

  /// Append data to a sheet
  Future<void> append(String range, List<List<Object?>> values) async {
    try {
      _ensureInitialized();

      final valueRange = sheets.ValueRange.fromJson({
        'range': range,
        'values': values,
      });

      await _sheetsApi!.spreadsheets.values.append(
        valueRange,
        _spreadsheetId!,
        range,
        valueInputOption: 'USER_ENTERED',
      );

      _logger.i('Successfully appended data to range: $range');
    } catch (e) {
      _logger.e('Failed to append to Google Sheets', error: e);
      throw SheetsException(
        message: 'Failed to append data to Google Sheets',
        code: 'APPEND_ERROR',
        details: e,
      );
    }
  }

  /// Batch write to multiple ranges
  Future<void> batchWrite(Map<String, List<List<Object?>>> updates) async {
    try {
      _ensureInitialized();

      final data = updates.entries.map((entry) {
        return sheets.ValueRange.fromJson({
          'range': entry.key,
          'values': entry.value,
        });
      }).toList();

      final request = sheets.BatchUpdateValuesRequest(
        data: data,
        valueInputOption: 'USER_ENTERED',
      );

      await _sheetsApi!.spreadsheets.values.batchUpdate(
        request,
        _spreadsheetId!,
      );

      _logger.i('Successfully batch wrote data to ${updates.length} ranges');
    } catch (e) {
      _logger.e('Failed to batch write to Google Sheets', error: e);
      throw SheetsException(
        message: 'Failed to batch write data',
        code: 'BATCH_WRITE_ERROR',
        details: e,
      );
    }
  }

  /// Clear a range
  Future<void> clear(String range) async {
    try {
      _ensureInitialized();

      await _sheetsApi!.spreadsheets.values.clear(
        sheets.ClearValuesRequest(),
        _spreadsheetId!,
        range,
      );

      _logger.i('Successfully cleared range: $range');
    } catch (e) {
      _logger.e('Failed to clear Google Sheets range', error: e);
      throw SheetsException(
        message: 'Failed to clear data',
        code: 'CLEAR_ERROR',
        details: e,
      );
    }
  }

  /// Find row by column value (simple search)
  Future<int?> findRowByValue(
    String sheetName,
    int columnIndex,
    String searchValue,
  ) async {
    try {
      final data = await read('$sheetName!A:Z');

      for (int i = 0; i < data.length; i++) {
        if (data[i].length > columnIndex &&
            data[i][columnIndex].toString() == searchValue) {
          return i + 1; // Sheets are 1-indexed
        }
      }

      return null;
    } catch (e) {
      _logger.e('Failed to find row', error: e);
      throw SheetsException(
        message: 'Failed to search data',
        code: 'SEARCH_ERROR',
        details: e,
      );
    }
  }

  /// Update specific row
  Future<void> updateRow(
    String sheetName,
    int rowNumber,
    List<Object?> values,
  ) async {
    try {
      final range = '$sheetName!A$rowNumber:Z$rowNumber';
      await write(range, [values]);
    } catch (e) {
      _logger.e('Failed to update row', error: e);
      throw SheetsException(
        message: 'Failed to update row',
        code: 'UPDATE_ROW_ERROR',
        details: e,
      );
    }
  }

  /// Delete row (by setting is_deleted flag)
  Future<void> softDeleteRow(
    String sheetName,
    int rowNumber,
    int deletedColumnIndex,
  ) async {
    try {
      final data = await read('$sheetName!A$rowNumber:Z$rowNumber');
      if (data.isEmpty) {
        throw NotFoundException(message: 'Row not found');
      }

      final row = List<Object?>.from(data[0]);
      while (row.length <= deletedColumnIndex) {
        row.add('');
      }
      row[deletedColumnIndex] = 'TRUE';

      await updateRow(sheetName, rowNumber, row);
    } catch (e) {
      _logger.e('Failed to soft delete row', error: e);
      throw SheetsException(
        message: 'Failed to delete row',
        code: 'DELETE_ROW_ERROR',
        details: e,
      );
    }
  }

  /// Get all sheet names in the spreadsheet
  Future<List<String>> getSheetNames() async {
    try {
      _ensureInitialized();

      final spreadsheet = await _sheetsApi!.spreadsheets.get(_spreadsheetId!);
      return spreadsheet.sheets
              ?.map((sheet) => sheet.properties?.title ?? '')
              .where((title) => title.isNotEmpty)
              .toList() ??
          [];
    } catch (e) {
      _logger.e('Failed to get sheet names', error: e);
      throw SheetsException(
        message: 'Failed to get sheet names',
        code: 'GET_SHEETS_ERROR',
        details: e,
      );
    }
  }

  /// Set spreadsheet ID (for testing or switching spreadsheets)
  void setSpreadsheetId(String spreadsheetId) {
    _spreadsheetId = spreadsheetId;
    _logger.i('Spreadsheet ID updated to: $spreadsheetId');
  }

  /// Check if API is initialized
  bool get isInitialized => _sheetsApi != null;

  /// Ensure API is initialized before operations
  void _ensureInitialized() {
    if (_sheetsApi == null) {
      throw SheetsException(
        message: 'Google Sheets API not initialized',
        code: 'NOT_INITIALIZED',
      );
    }

    if (_spreadsheetId == null || _spreadsheetId!.isEmpty) {
      throw SheetsException(
        message: 'Spreadsheet ID not configured',
        code: 'NO_SPREADSHEET_ID',
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _sheetsApi = null;
    _logger.i('Google Sheets Service disposed');
  }
}
