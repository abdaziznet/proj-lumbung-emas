import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/theme/app_theme.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/auth/presentation/screens/login_screen.dart';
import 'package:lumbungemas/features/portfolio/presentation/screens/dashboard_screen.dart';

class LumbungEmasApp extends ConsumerWidget {
  const LumbungEmasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'LumbungEmas',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: _getHome(authState),
    );
  }

  Widget _getHome(AuthState state) {
    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.user != null) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}
