import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/auth/presentation/providers/biometric_provider.dart';

/// Dialog for biometric setup after successful login
class BiometricSetupDialog extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;

  const BiometricSetupDialog({super.key, this.onSuccess});

  @override
  ConsumerState<BiometricSetupDialog> createState() =>
      _BiometricSetupDialogState();
}

class _BiometricSetupDialogState extends ConsumerState<BiometricSetupDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bioState = ref.watch(biometricProvider);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getBiometricIcon(bioState.availableBiometrics),
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Setup Biometric Lock',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Aktifkan ${_getBiometricTypeName(bioState.availableBiometrics)} untuk akses lebih cepat',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Verifikasi biometric hanya dilakukan di perangkat ini',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Tidak Sekarang'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);

                  // Get session token from auth provider
                  final sessionToken = ref.read(authSessionTokenProvider);
                  final user = ref.read(authProvider).user;
                  if (sessionToken == null) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session token tidak ditemukan'),
                        ),
                      );
                    }
                    return;
                  }
                  if (user == null) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User tidak ditemukan'),
                        ),
                      );
                    }
                    return;
                  }

                  final success = await ref
                      .read(biometricProvider.notifier)
                      .enableBiometric(sessionToken, user);

                  if (!mounted) return;

                  setState(() => _isLoading = false);

                  if (success) {
                    widget.onSuccess?.call();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Biometric berhasil diaktifkan'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Aktifkan', style: TextStyle(color: Colors.white)),
        ),
      ],
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

  String _getBiometricTypeName(List biometrics) {
    if (biometrics.isEmpty) {
      return 'Biometric';
    }

    final bioType = biometrics.first.toString();
    if (bioType.contains('face')) {
      return 'Face ID';
    } else if (bioType.contains('iris')) {
      return 'Iris';
    }
    return 'Fingerprint';
  }
}
