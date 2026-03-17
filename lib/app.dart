import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/theme/app_theme.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/auth/presentation/providers/biometric_provider.dart';
import 'package:lumbungemas/features/auth/presentation/screens/login_screen.dart';
import 'package:lumbungemas/features/portfolio/presentation/screens/dashboard_screen.dart';

class LumbungEmasApp extends ConsumerStatefulWidget {
  const LumbungEmasApp({super.key});

  @override
  ConsumerState<LumbungEmasApp> createState() => _LumbungEmasAppState();
}

class _LumbungEmasAppState extends ConsumerState<LumbungEmasApp> {
  @override
  void initState() {
    super.initState();
    // Initialize biometric on app startup
    _initializeBiometric();
  }

  Future<void> _initializeBiometric() async {
    await ref.read(biometricProvider.notifier).initializeBiometric();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bioState = ref.watch(biometricProvider);

    // Reset unlock state when user logs out.
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user == null) {
        ref.read(biometricProvider.notifier).resetSessionUnlock();
      }
    });

    // Reset unlock state when biometric is disabled.
    ref.listen<BiometricState>(biometricProvider, (previous, next) {
      final wasEnabled = previous?.isEnabled ?? false;
      if (wasEnabled && !next.isEnabled) {
        ref.read(biometricProvider.notifier).resetSessionUnlock();
      }
    });

    return MaterialApp(
      title: 'LumbungEmas',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: _getHome(authState, bioState),
    );
  }

  Widget _getHome(AuthState authState, BiometricState bioState) {
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.user != null) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}
