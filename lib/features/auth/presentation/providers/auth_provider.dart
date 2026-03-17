import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/services/notification_service.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';
import 'package:lumbungemas/features/auth/domain/repositories/auth_repository.dart';
import 'package:lumbungemas/features/auth/domain/usecases/get_current_user.dart';
import 'package:lumbungemas/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:lumbungemas/features/auth/domain/usecases/sign_out.dart';
import 'package:lumbungemas/shared/data/providers/dependency_injection.dart';
import 'package:uuid/uuid.dart';

/// State of authentication
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;
  final String? sessionToken;
  final bool isLocalSession;

  static const Object _noChange = Object();

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.sessionToken,
    this.isLocalSession = false,
  });

  AuthState copyWith({
    Object? user = _noChange,
    bool? isLoading,
    Object? error = _noChange,
    Object? sessionToken = _noChange,
    bool? isLocalSession,
  }) {
    return AuthState(
      user: identical(user, _noChange) ? this.user : user as UserEntity?,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _noChange) ? this.error : error as String?,
      sessionToken: identical(sessionToken, _noChange)
          ? this.sessionToken
          : sessionToken as String?,
      isLocalSession: isLocalSession ?? this.isLocalSession,
    );
  }
}

/// Authentication controller notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthNotifier({
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthRepository authRepository, // Add this
  }) : _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signOutUseCase = signOutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(AuthState()) {
    _init();
    // Listen to auth state changes
    authRepository.authStateChanges().listen((user) {
      if (state.isLocalSession && user == null) {
        return;
      }
      state = state.copyWith(
        user: user,
        isLoading: false,
        isLocalSession: user == null ? false : false,
      );
      if (user != null) {
        Future.microtask(() async {
          await NotificationService.instance.showPriceUpdateReminderIfNeeded();
        });
      }
    });
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        // Generate session token if user exists
        if (user != null) {
          final sessionToken = _generateSessionToken(user.userId);
          state = state.copyWith(
            isLoading: false,
            user: user,
            sessionToken: sessionToken,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _signInWithGoogleUseCase();
    await result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (user) async {
        // Generate session token for biometric use
        final sessionToken = _generateSessionToken(user.userId);
        state = state.copyWith(
          isLoading: false,
          user: user,
          sessionToken: sessionToken,
          isLocalSession: false,
        );
        await NotificationService.instance.showPriceUpdateReminderIfNeeded();
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    final result = await _signOutUseCase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(
        isLoading: false,
        user: null,
        sessionToken: null,
        isLocalSession: false,
      ),
    );
  }

  /// Sign in using biometric local session data
  void signInWithBiometric(UserEntity user, String sessionToken) {
    state = state.copyWith(
      isLoading: false,
      user: user,
      sessionToken: sessionToken,
      isLocalSession: true,
      error: null,
    );
  }

  /// Refresh current user (e.g., after biometric unlock)
  Future<void> refreshCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        if (user != null) {
          final sessionToken = _generateSessionToken(user.userId);
          state = state.copyWith(
            isLoading: false,
            user: user,
            sessionToken: sessionToken,
            isLocalSession: false,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
    );
  }

  /// Generate session token for biometric authentication
  String _generateSessionToken(String userId) {
    // Combine user ID with UUID for unique session token
    const uuid = Uuid();
    final uniqueId = uuid.v4();
    return '$userId:$uniqueId';
  }

  /// Get current session token
  String? getSessionToken() {
    return state.sessionToken;
  }
}

/// Provider for auth state notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(
    signInWithGoogleUseCase: SignInWithGoogleUseCase(authRepository),
    signOutUseCase: SignOutUseCase(authRepository),
    getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
    authRepository: authRepository, // Add this
  );
});

/// Provider for current user entity
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider for auth status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user != null;
});

/// Provider for session token
final authSessionTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).sessionToken;
});
