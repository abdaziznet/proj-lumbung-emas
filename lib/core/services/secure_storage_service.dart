import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Service for securely storing sensitive data
/// Uses platform-specific secure storage (Keychain on iOS, KeyStore on Android)
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Storage keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyGoogleCredentials = 'google_credentials';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Save Google credentials as JSON
  Future<void> saveGoogleCredentials(Map<String, dynamic> credentials) async {
    final json = jsonEncode(credentials);
    await _storage.write(key: _keyGoogleCredentials, value: json);
  }

  /// Get Google credentials as JSON
  Future<Map<String, dynamic>?> getGoogleCredentials() async {
    final json = await _storage.read(key: _keyGoogleCredentials);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// Save custom key-value pair
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Get value by key
  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all stored data (use on logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }

  /// Get all keys
  Future<Map<String, String>> getAll() async {
    return await _storage.readAll();
  }
}
