import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/auth/presentation/providers/biometric_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure biometric is initialized
    Future.microtask(() {
      ref.read(biometricProvider.notifier).initializeBiometric();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bioState = ref.watch(biometricProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'Keamanan',
                    subtitle: 'Lindungi akun dan perangkat Anda',
                    icon: Icons.shield_outlined,
                  ),
                  const SizedBox(height: 18),

                  // Biometric Lock Card
                  _buildGlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getBiometricIcon(
                                  bioState.availableBiometrics,
                                ),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getBiometricTypeName(
                                      bioState.availableBiometrics,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textBody,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    bioState.isAvailable
                                        ? (bioState.isEnabled
                                              ? 'Biometric aktif'
                                              : 'Biometric tersedia')
                                        : 'Tidak didukung perangkat ini',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (bioState.isAvailable)
                              Switch(
                                value: bioState.isEnabled,
                                onChanged: (value) async {
                                  if (value) {
                                    // First, verify with biometric before enabling
                                    final isVerified = await ref
                                        .read(biometricProvider.notifier)
                                        .authenticate();

                                    if (!isVerified) {
                                      if (mounted) {
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

                                    // Now enable biometric with session token
                                    final sessionToken = ref.read(
                                      authSessionTokenProvider,
                                    );
                                    final user = authState.user;
                                    if (sessionToken == null) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Session token tidak ditemukan',
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    if (user == null) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'User tidak ditemukan',
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    await ref
                                        .read(biometricProvider.notifier)
                                        .enableBiometric(
                                          sessionToken,
                                          user,
                                        );
                                    ref
                                        .read(biometricProvider.notifier)
                                        .markSessionUnlocked();

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Biometric berhasil diaktifkan',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } else {
                                    // Disable biometric
                                    await ref
                                        .read(biometricProvider.notifier)
                                        .disableBiometric();

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Biometric berhasil dinonaktifkan',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                                activeColor: AppColors.secondary,
                                activeTrackColor: AppColors.secondary.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                          ],
                        ),
                        if (bioState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      bioState.error!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Account Section
                  _buildSectionHeader(
                    title: 'Akun',
                    subtitle: 'Informasi profil dan kredensial',
                    icon: Icons.account_circle_outlined,
                  ),
                  const SizedBox(height: 18),

                  // Account Info Card
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Nama',
                          authState.user?.displayName ?? '-',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow('Email', authState.user?.email ?? '-'),
                        const SizedBox(height: 14),
                        _buildInfoRow('UID', authState.user?.userId ?? '-'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE53935),
                            Color(0xFFD32F2F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutDialog(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.logout_outlined),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textBody,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  IconData _getBiometricIcon(List biometrics) {
    if (biometrics.isEmpty) {
      return Icons.fingerprint;
    }

    final types = biometrics.map((b) => b.toString()).toList();
    if (types.any((t) => t.contains('face'))) {
      return Icons.face;
    } else if (types.any((t) => t.contains('iris'))) {
      return Icons.remove_red_eye;
    }
    return Icons.fingerprint;
  }

  String _getBiometricTypeName(List biometrics) {
    if (biometrics.isEmpty) {
      return 'Biometric';
    }

    final types = biometrics.map((b) => b.toString()).toList();
    final hasFace = types.any((t) => t.contains('face'));
    final hasFingerprint = types.any((t) => t.contains('finger'));
    final hasIris = types.any((t) => t.contains('iris'));

    if (hasFace && hasFingerprint) {
      return 'Face ID & Fingerprint';
    }
    if (hasFace) return 'Face ID';
    if (hasIris) return 'Iris';
    if (hasFingerprint) return 'Fingerprint';
    return 'Biometric';
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
