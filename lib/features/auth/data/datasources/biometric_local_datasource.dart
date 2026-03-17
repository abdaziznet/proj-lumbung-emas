import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';
import 'dart:convert';

/// Local data source untuk biometric authentication
abstract class BiometricLocalDataSource {
  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable();

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Authenticate user with biometric (fingerprint/face)
  Future<bool> authenticate({required String localizedReason});

  /// Check if biometric is enabled for current user
  Future<bool> isBiometricEnabled();

  /// Enable biometric for current user (save auth token)
  Future<void> enableBiometric(String sessionToken, UserEntity user);

  /// Disable biometric for current user (delete auth token)
  Future<void> disableBiometric();

  /// Get stored biometric session token
  Future<String?> getBiometricSessionToken();

  /// Get stored biometric user
  Future<UserEntity?> getBiometricUser();

  /// Clear all biometric data
  Future<void> clearBiometricData();
}

class BiometricLocalDataSourceImpl implements BiometricLocalDataSource {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger = Logger();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _sessionTokenKey = 'biometric_session_token';
  static const String _biometricTypeKey = 'biometric_type';
  static const String _biometricUserKey = 'biometric_user';

  BiometricLocalDataSourceImpl({
    required LocalAuthentication localAuth,
    required FlutterSecureStorage secureStorage,
  }) : _localAuth = localAuth,
       _secureStorage = secureStorage;

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final hasHardware = await _localAuth.canCheckBiometrics;
      return hasHardware;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      _logger.i('Starting biometric authentication...');

      final isAvailable = await isBiometricAvailable();
      _logger.i('Biometric available: $isAvailable');
      if (!isAvailable) {
        _logger.w('Biometric not available');
        return false;
      }

      // Get available biometrics to ensure device has it
      final availableBiometrics = await getAvailableBiometrics();
      _logger.i('Available biometrics: $availableBiometrics');
      if (availableBiometrics.isEmpty) {
        _logger.w('No biometric types available');
        return false;
      }

      _logger.i('Launching native biometric dialog...');

      // Try to authenticate - if it fails with FragmentActivity error,
      // it's likely an Android configuration issue
      try {
        final result = await _localAuth.authenticate(
          localizedReason: localizedReason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false, // Allow device credential fallback
            useErrorDialogs: true,
          ),
        );

        _logger.i('Biometric authentication result: $result');
        return result;
      } on PlatformException catch (pe) {
        if (pe.code.contains('no_fragment_activity')) {
          _logger.e('Android FragmentActivity Error: ${pe.message}');
          _logger.w('This is usually a Flutter Android configuration issue');
          _logger.w('Ensure AndroidManifest has enableOnBackInvokedCallback');
          return false;
        }
        rethrow;
      }
    } catch (e) {
      _logger.e('Exception during biometric auth: $e');
      return false;
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> enableBiometric(String sessionToken, UserEntity user) async {
    try {
      _logger.i('Enabling biometric...');

      // Save biometric enabled flag
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');

      // Save the session token securely
      await _secureStorage.write(key: _sessionTokenKey, value: sessionToken);

      // Get and save the biometric type
      final biometrics = await _localAuth.getAvailableBiometrics();
      final biometricType = biometrics.isNotEmpty
          ? biometrics.first.name
          : 'fingerprint';
      await _secureStorage.write(key: _biometricTypeKey, value: biometricType);

      final userJson = jsonEncode({
        'userId': user.userId,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'createdAt': user.createdAt.millisecondsSinceEpoch,
        'lastLogin': user.lastLogin.millisecondsSinceEpoch,
      });
      await _secureStorage.write(key: _biometricUserKey, value: userJson);

      _logger.i('Biometric enabled successfully');
    } catch (e) {
      _logger.e('Failed to enable biometric: $e');
      throw Exception('Failed to enable biometric: $e');
    }
  }

  @override
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _sessionTokenKey);
      await _secureStorage.delete(key: _biometricTypeKey);
      await _secureStorage.delete(key: _biometricUserKey);
    } catch (e) {
      throw Exception('Failed to disable biometric: $e');
    }
  }

  @override
  Future<String?> getBiometricSessionToken() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return null;
      }
      return await _secureStorage.read(key: _sessionTokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity?> getBiometricUser() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return null;
      }
      final raw = await _secureStorage.read(key: _biometricUserKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final data = jsonDecode(raw);
      return UserEntity(
        userId: data['userId'] as String? ?? '',
        email: data['email'] as String? ?? '',
        displayName: data['displayName'] as String?,
        photoUrl: data['photoUrl'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          data['createdAt'] as int? ??
              DateTime.now().millisecondsSinceEpoch,
        ),
        lastLogin: DateTime.fromMillisecondsSinceEpoch(
          data['lastLogin'] as int? ??
              DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearBiometricData() async {
    try {
      await disableBiometric();
    } catch (e) {
      throw Exception('Failed to clear biometric data: $e');
    }
  }
}
