import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/auth/presentation/providers/biometric_provider.dart';
import 'package:lumbungemas/features/auth/presentation/screens/biometric_setup_dialog.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    final bioState = ref.watch(biometricProvider);
    final shouldOfferBiometric = ref.watch(shouldOfferBiometricSetupProvider);

    // Show biometric setup dialog after successful login
    ref.listen(authProvider, (prev, next) async {
      if (prev == null ||
          prev.user == null ||
          next.user == null ||
          next.isLoading) {
        return;
      }

      // Check if user just logged in (has session token now)
      if (prev.user != next.user && next.sessionToken != null) {
        ref.read(biometricProvider.notifier).markSessionUnlocked();

        // Wait for biometric provider to update
        await Future.delayed(const Duration(milliseconds: 500));

        if (context.mounted && shouldOfferBiometric) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => BiometricSetupDialog(
              onSuccess: () {
                // Dialog closed after successful setup
              },
            ),
          );
        }
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo/Illustration
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/gold.svg',
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  'Lumbung Emasku',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola & Pantau Portofolio Emas Anda',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Login Card
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Mulai Kelola Investasi Emasmu',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // Login buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: state.isLoading
                                    ? null
                                    : () => ref
                                          .read(authProvider.notifier)
                                          .signInWithGoogle(),
                                icon: state.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login),
                                label: Text(
                                  state.isLoading
                                      ? 'Menghubungkan...'
                                      : 'Masuk dengan Google',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                              ),
                            ),
                            if (bioState.isEnabled &&
                                bioState.hasStoredSession) ...[
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 48,
                                width: 56,
                                child: ElevatedButton(
                                  onPressed: state.isLoading ||
                                          bioState.isAuthenticating
                                      ? null
                                      : () async {
                                          final bioNotifier = ref.read(
                                            biometricProvider.notifier,
                                          );
                                          final authNotifier = ref.read(
                                            authProvider.notifier,
                                          );

                                          final isVerified = await bioNotifier
                                              .authenticate();
                                          if (!isVerified) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Verifikasi biometric gagal',
                                                  ),
                                                ),
                                              );
                                            }
                                            return;
                                          }

                                          final sessionToken = await bioNotifier
                                              .getBiometricSessionToken();
                                          final user =
                                              await bioNotifier
                                                  .getBiometricUser();

                                          if (sessionToken == null ||
                                              user == null) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Data biometric tidak lengkap, silakan login dengan Google',
                                                  ),
                                                ),
                                              );
                                            }
                                            return;
                                          }

                                          authNotifier.signInWithBiometric(
                                            user,
                                            sessionToken,
                                          );
                                          bioNotifier.markSessionUnlocked();

                                          if (!context.mounted) return;
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: bioState.isAuthenticating
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.fingerprint,
                                          size: 26,
                                        ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (state.error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            state.error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Footer
                Text(
                  'Amankan masa depan finansialmu\nhari ini.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
