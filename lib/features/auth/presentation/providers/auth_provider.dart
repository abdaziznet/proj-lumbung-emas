import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/features/auth/domain/entities/user_entity.dart';
import 'package:lumbungemas/features/auth/domain/repositories/auth_repository.dart';
import 'package:lumbungemas/features/auth/domain/usecases/get_current_user.dart';
import 'package:lumbungemas/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:lumbungemas/features/auth/domain/usecases/sign_out.dart';
import 'package:lumbungemas/shared/data/providers/dependency_injection.dart';

/// State of authentication
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
  })  : _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(AuthState()) {
    _init();
    // Listen to auth state changes
    authRepository.authStateChanges().listen((user) {
      state = state.copyWith(user: user, isLoading: false);
    });
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _signInWithGoogleUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    final result = await _signOutUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, user: null),
    );
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
