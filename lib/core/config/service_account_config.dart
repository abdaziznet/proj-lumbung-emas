import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration for Google Service Account credentials
/// Used for server-to-server authentication with Google Sheets API
class ServiceAccountConfig {
  ServiceAccountConfig._();

  /// Get service account credentials as Map
  /// 
  /// Supports two methods:
  /// 1. From file path (GOOGLE_SERVICE_ACCOUNT_FILE in .env) - loaded from assets
  /// 2. From base64 encoded string (GOOGLE_SERVICE_ACCOUNT_JSON_BASE64 in .env)
  static Future<Map<String, dynamic>?> getCredentials() async {
    try {
      // Method 1: From file path (recommended for development)
      final filePath = dotenv.env['GOOGLE_SERVICE_ACCOUNT_FILE'];
      if (filePath != null && filePath.isNotEmpty) {
        return await _loadFromAsset(filePath);
      }

      // Method 2: From base64 encoded string (recommended for production/CI-CD)
      final base64Json = dotenv.env['GOOGLE_SERVICE_ACCOUNT_JSON_BASE64'];
      if (base64Json != null && base64Json.isNotEmpty) {
        return _loadFromBase64(base64Json);
      }
    } catch (e) {
      debugPrint('Error loading credentials: $e');
    }
    return null;
  }

  /// Load credentials from asset file
  static Future<Map<String, dynamic>?> _loadFromAsset(String filePath) async {
    try {
      final jsonString = await rootBundle.loadString(filePath);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception(
        'Service account file not found in assets: $filePath\n'
        'Please ensure:\n'
        '1. The file exists\n'
        '2. The path in .env is correct\n'
        '3. The folder is added to pubspec.yaml assets',
      );
    }
  }

  /// Load credentials from base64 encoded string
  static Map<String, dynamic>? _loadFromBase64(String base64String) {
    try {
      final jsonString = utf8.decode(base64.decode(base64String));
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception(
        'Failed to decode service account from base64: $e\n'
        'Please ensure the base64 string in .env is valid.',
      );
    }
  }

  /// Get client email from credentials
  /// This is the email address of the service account
  static Future<String?> getClientEmail() async {
    final credentials = await getCredentials();
    return credentials?['client_email'] as String?;
  }

  /// Get project ID from credentials
  static Future<String?> getProjectId() async {
    final credentials = await getCredentials();
    return credentials?['project_id'] as String?;
  }

  /// Get private key from credentials
  static Future<String?> getPrivateKey() async {
    final credentials = await getCredentials();
    return credentials?['private_key'] as String?;
  }

  /// Get private key ID from credentials
  static Future<String?> getPrivateKeyId() async {
    final credentials = await getCredentials();
    return credentials?['private_key_id'] as String?;
  }

  /// Check if service account is configured
  static Future<bool> isConfigured() async {
    return (await getCredentials()) != null;
  }

  /// Validate service account credentials
  /// Returns true if all required fields are present
  static Future<bool> validate() async {
    final credentials = await getCredentials();
    if (credentials == null) return false;

    final requiredFields = [
      'type',
      'project_id',
      'private_key_id',
      'private_key',
      'client_email',
      'client_id',
      'auth_uri',
      'token_uri',
    ];

    for (final field in requiredFields) {
      if (!credentials.containsKey(field) || credentials[field] == null) {
        return false;
      }
    }

    // Validate type
    if (credentials['type'] != 'service_account') {
      return false;
    }

    return true;
  }

  /// Print configuration info (for debugging, without sensitive data)
  static Future<void> printInfo() async {
    if (!await isConfigured()) {
      debugPrint('Service Account: Not configured');
      return;
    }

    debugPrint('=== Service Account Configuration ===');
    debugPrint('Project ID: ${await getProjectId()}');
    debugPrint('Client Email: ${await getClientEmail()}');
    debugPrint('Private Key ID: ${(await getPrivateKeyId())?.substring(0, 10)}...');
    debugPrint('Valid: ${await validate()}');
    debugPrint('====================================');
  }
}
