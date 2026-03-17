import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/auth/presentation/providers/biometric_provider.dart';

/// Screen for biometric authentication lock
class BiometricLockScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onFailure;

  const BiometricLockScreen({
    super.key,
    required this.onSuccess,
    this.onFailure,
  });

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _showAuthFallback = false;
  bool _isSessionTokenValid = false;
  bool _isGoogleAuthLoading = false;

  @override
  void initState() {
    super.initState();
    _initiateBiometricAuth();
    _checkSessionTokenValidity();
  }

  Future<void> _checkSessionTokenValidity() async {
    final token = await ref
        .read(biometricProvider.notifier)
        .getBiometricSessionToken();
    if (mounted && token != null) {
      setState(() {
        _isSessionTokenValid = true;
      });
    }
  }

  Future<void> _initiateBiometricAuth() async {
    // Clear previous error
    ref.read(biometricProvider.notifier).clearError();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final result = await ref.read(biometricProvider.notifier).authenticate();

    if (!mounted) return;

    if (result) {
      // Success - unlock and navigate
      widget.onSuccess();
      if (mounted) {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    } else {
      // Failure - show fallback option after delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Biometric gagal, silakan coba lagi atau gunakan Google Sign-In',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _googleSignInFallback() async {
    setState(() => _isGoogleAuthLoading = true);

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();

      if (mounted) {
        setState(() => _isGoogleAuthLoading = false);
        widget.onSuccess();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGoogleAuthLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bioState = ref.watch(biometricProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),

                  // Biometric Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getBiometricIcon(bioState.availableBiometrics),
                      size: 80,
                      color: AppColors.secondary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  if (!_showAuthFallback)
                    Text(
                      'Biometric Lock',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBody,
                          ),
                    )
                  else
                    Text(
                      'Sign In Required',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBody,
                          ),
                    ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    !_showAuthFallback
                        ? 'Scan fingerprint untuk akses'
                        : 'Gunakan Google untuk lanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Error message
                  if (bioState.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bioState.error!,
                        style: TextStyle(fontSize: 12, color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Password field (if fallback)
                  if (_showAuthFallback)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Session Token Option
                        if (_isSessionTokenValid)
                          ElevatedButton(
                            onPressed: () {
                              // Use existing session token
                              widget.onSuccess();
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Lanjutkan dengan Session Tersimpan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (_isSessionTokenValid) const SizedBox(height: 12),
                        // Google Sign-In Fallback
                        ElevatedButton.icon(
                          onPressed: _isGoogleAuthLoading
                              ? null
                              : _googleSignInFallback,
                          icon: _isGoogleAuthLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.g_translate),
                          label: const Text('Google Sign-In'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Colors.blue.withValues(alpha: 0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 30),

                  // Loading indicator or action button
                  if (bioState.isAuthenticating && !_showAuthFallback)
                    const Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.secondary),
                        SizedBox(height: 16),
                        Text(
                          'Menunggu pemindaian biometric...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  else if (!_showAuthFallback)
                    ElevatedButton(
                      onPressed: _initiateBiometricAuth,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Fallback button
                  if (!_showAuthFallback)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAuthFallback = true;
                        });
                        ref.read(biometricProvider.notifier).clearError();
                      },
                      child: const Text(
                        'Gunakan Google Sign-In',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAuthFallback = false;
                        });
                        _initiateBiometricAuth();
                      },
                      child: const Text(
                        'Kembali ke biometric',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon(List biometrics) {
    if (biometrics.isEmpty) {
      return Icons.fingerprint;
    }

    final bioType = biometrics.first.toString();
    if (bioType.contains('face')) {
      return Icons.face;
    } else if (bioType.contains('iris')) {
      return Icons.remove_red_eye;
    }
    return Icons.fingerprint;
  }
}
