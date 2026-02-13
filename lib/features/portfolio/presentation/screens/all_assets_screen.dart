import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/presentation/providers/portfolio_provider.dart';
import 'package:lumbungemas/features/portfolio/presentation/screens/add_transaction_screen.dart';
import 'package:lumbungemas/shared/presentation/widgets/asset_item_card.dart';

class AllAssetsScreen extends ConsumerStatefulWidget {
  const AllAssetsScreen({super.key});

  @override
  ConsumerState<AllAssetsScreen> createState() => _AllAssetsScreenState();
}

class _AllAssetsScreenState extends ConsumerState<AllAssetsScreen> {
  static const int _pageSize = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioProvider);
    final sortedAssets = List<MetalAsset>.from(portfolioState.assets)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final totalPages = sortedAssets.isEmpty
        ? 0
        : (sortedAssets.length / _pageSize).ceil();
    final safePage = totalPages == 0
        ? 0
        : _currentPage.clamp(0, totalPages - 1).toInt();
    if (safePage != _currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _currentPage = safePage);
      });
    }

    final startIndex = safePage * _pageSize;
    final endIndex = math.min(startIndex + _pageSize, sortedAssets.length);
    final pagedAssets = sortedAssets.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Semua Aset (${sortedAssets.length})'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.secondary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(portfolioProvider.notifier).loadPortfolio(),
        child: portfolioState.isLoading && portfolioState.assets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : portfolioState.assets.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 140),
                      Center(
                        child: Text(
                          'Belum ada aset.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                          itemCount: pagedAssets.length,
                          itemBuilder: (context, index) {
                            final asset = pagedAssets[index];
                            return AssetItemCard(
                              asset: asset,
                              onEdit: () => _editAsset(context, ref, asset),
                              onDelete: () =>
                                  _confirmDeleteAsset(context, ref, asset),
                            );
                          },
                        ),
                      ),
                      if (totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: safePage > 0
                                      ? () => setState(() => _currentPage--)
                                      : null,
                                  child: const Text('Sebelumnya'),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Halaman ${safePage + 1}/$totalPages',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: safePage < totalPages - 1
                                      ? () => setState(() => _currentPage++)
                                      : null,
                                  child: const Text('Berikutnya'),
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

  Future<void> _editAsset(BuildContext context, WidgetRef ref, MetalAsset asset) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(editingAsset: asset),
      ),
    );
  }

  Future<void> _confirmDeleteAsset(
    BuildContext context,
    WidgetRef ref,
    MetalAsset asset,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jual Aset'),
        content: Text('Jual transaksi ${asset.brand} ${asset.metalType.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Jual', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(portfolioProvider.notifier).deleteTransaction(asset.transactionId);
    if (!context.mounted) return;

    final error = ref.read(portfolioProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Aset berhasil dijual'),
      ),
    );
  }
}
