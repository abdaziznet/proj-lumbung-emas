import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/presentation/providers/portfolio_provider.dart';
import 'package:lumbungemas/features/portfolio/presentation/screens/add_transaction_screen.dart';
import 'package:lumbungemas/shared/presentation/widgets/asset_item_card.dart';

class AllAssetsScreen extends ConsumerWidget {
  const AllAssetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Semua Aset (${portfolioState.assets.length})'),
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
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    itemCount: portfolioState.assets.length,
                    itemBuilder: (context, index) {
                      final asset = portfolioState.assets[index];
                      return AssetItemCard(
                        asset: asset,
                        onEdit: () => _editAsset(context, ref, asset),
                        onDelete: () => _confirmDeleteAsset(context, ref, asset),
                      );
                    },
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
        title: const Text('Hapus Aset'),
        content: Text('Hapus transaksi ${asset.brand} ${asset.metalType.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
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
        content: Text(error ?? 'Aset berhasil dihapus'),
      ),
    );
  }
}
