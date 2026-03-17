import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lumbungemas/features/auth/data/datasources/biometric_local_datasource.dart';
import 'package:lumbungemas/features/auth/data/repositories/biometric_repository_impl.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';
import 'package:lumbungemas/features/auth/domain/repositories/biometric_repository.dart';

/// State of biometric
class BiometricState {
  final bool isAvailable;
  final bool isEnabled;
  final bool isSessionUnlocked;
  final bool hasStoredSession;
  final List<BiometricType> availableBiometrics;
  final bool isAuthenticating;
  final String? error;
  final String? successMessage;

  BiometricState({
    this.isAvailable = false,
    this.isEnabled = false,
    this.isSessionUnlocked = false,
    this.hasStoredSession = false,
    this.availableBiometrics = const [],
    this.isAuthenticating = false,
    this.error,
    this.successMessage,
  });

  BiometricState copyWith({
    bool? isAvailable,
    bool? isEnabled,
    bool? isSessionUnlocked,
    bool? hasStoredSession,
    List<BiometricType>? availableBiometrics,
    bool? isAuthenticating,
    String? error,
    String? successMessage,
  }) {
    return BiometricState(
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      isSessionUnlocked: isSessionUnlocked ?? this.isSessionUnlocked,
      hasStoredSession: hasStoredSession ?? this.hasStoredSession,
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Biometric repository provider
final biometricRepositoryProvider = Provider<BiometricRepository>((ref) {
  const secureStorage = FlutterSecureStorage();
  final localDataSource = BiometricLocalDataSourceImpl(
    localAuth: LocalAuthentication(),
    secureStorage: secureStorage,
  );
  return BiometricRepositoryImpl(localDataSource: localDataSource);
});

/// Biometric state notifier
class BiometricNotifier extends StateNotifier<BiometricState> {
  final BiometricRepository _repository;

  BiometricNotifier({required BiometricRepository repository})
    : _repository = repository,
      super(BiometricState());

  /// Initialize biometric state
  Future<void> initializeBiometric() async {
    final availableResult = await _repository.isBiometricAvailable();
    final enabledResult = await _repository.isBiometricEnabled();
    final biometricsResult = await _repository.getAvailableBiometrics();
    final tokenResult = await _repository.getBiometricSessionToken();
    final userResult = await _repository.getBiometricUser();

    final hasToken = tokenResult.getOrElse(() => null) != null;
    final hasUser = userResult.getOrElse(() => null) != null;

    state = state.copyWith(
      isAvailable: availableResult.getOrElse(() => false),
      isEnabled: enabledResult.getOrElse(() => false),
      availableBiometrics: biometricsResult.getOrElse(() => []),
      hasStoredSession: hasToken && hasUser,
    );
  }

  /// Authenticate with biometric
  Future<bool> authenticate() async {
    state = state.copyWith(
      isAuthenticating: true,
      error: null,
      successMessage: null,
    );

    try {
      final result = await _repository.authenticate(
        localizedReason: 'Scan fingerprint untuk akses Lumbung Emas',
      );

      final isSuccess = result.fold((failure) => false, (success) => success);

      if (isSuccess) {
        state = state.copyWith(
          isAuthenticating: false,
          successMessage: 'Authentikasi berhasil',
          error: null,
        );
      } else {
        state = state.copyWith(
          isAuthenticating: false,
          error: 'Pemindaian biometric gagal atau dibatalkan',
          successMessage: null,
        );
      }

      return isSuccess;
    } catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        error: 'Error: $e',
        successMessage: null,
      );
      return false;
    }
  }

  /// Enable biometric with session token
  Future<bool> enableBiometric(String sessionToken, UserEntity user) async {
    try {
      // Check if biometric available first
      final availableResult = await _repository.isBiometricAvailable();
      final isAvailable = availableResult.fold(
        (failure) => false,
        (success) => success,
      );

      if (!isAvailable) {
        state = state.copyWith(
          error: 'Biometric tidak didukung di perangkat ini',
        );
        return false;
      }

      // Just save the token, no authentication needed for setup
      final result = await _repository.enableBiometric(sessionToken, user);

      final isSuccess = result.fold((failure) => false, (_) => true);

      if (isSuccess) {
        state = state.copyWith(
          isEnabled: true,
          hasStoredSession: true,
          error: null,
          successMessage: 'Biometric berhasil diaktifkan',
        );
      } else {
        state = state.copyWith(error: 'Gagal menyimpan konfigurasi biometric');
      }

      return isSuccess;
    } catch (e) {
      state = state.copyWith(error: 'Error: $e');
      return false;
    }
  }

  /// Disable biometric
  Future<bool> disableBiometric() async {
    try {
      final result = await _repository.disableBiometric();

      final isSuccess = result.fold((failure) => false, (_) => true);

      if (isSuccess) {
        state = state.copyWith(
          isEnabled: false,
          hasStoredSession: false,
          successMessage: 'Biometric berhasil dinonaktifkan',
        );
      } else {
        state = state.copyWith(error: 'Gagal menonaktifkan biometric');
      }

      return isSuccess;
    } catch (e) {
      state = state.copyWith(error: 'Error: $e');
      return false;
    }
  }

  /// Get biometric session token
  Future<String?> getBiometricSessionToken() async {
    final result = await _repository.getBiometricSessionToken();
    return result.fold((failure) => null, (token) => token);
  }

  /// Get biometric user
  Future<UserEntity?> getBiometricUser() async {
    final result = await _repository.getBiometricUser();
    return result.fold((failure) => null, (user) => user);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  /// Mark current session as unlocked (skip biometric lock)
  void markSessionUnlocked() {
    if (!state.isSessionUnlocked) {
      state = state.copyWith(isSessionUnlocked: true);
    }
  }

  /// Reset session unlock flag
  void resetSessionUnlock() {
    if (state.isSessionUnlocked) {
      state = state.copyWith(isSessionUnlocked: false);
    }
  }
}

/// Biometric state provider
final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
      final repository = ref.watch(biometricRepositoryProvider);
      return BiometricNotifier(repository: repository);
    });

/// Provider to check if biometric setup should be offered
/// (available but not yet enabled)
final shouldOfferBiometricSetupProvider = Provider<bool>((ref) {
  final bioState = ref.watch(biometricProvider);
  return bioState.isAvailable && !bioState.isEnabled;
});
