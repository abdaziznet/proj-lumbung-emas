import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';

class AssetItemCard extends StatelessWidget {
  final MetalAsset asset;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssetItemCard({
    super.key,
    required this.asset,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon based on metal type
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: asset.metalType.apiValue == 'GOLD'
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.blueGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    asset.metalType.apiValue == 'GOLD'
                        ? Icons.workspace_premium
                        : Icons.circle,
                    color: asset.metalType.apiValue == 'GOLD'
                        ? AppColors.primary
                        : Colors.blueGrey,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${asset.brand} ${asset.metalType.displayName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatWeight(asset.weightGram)} gram',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Value info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(asset.totalPurchaseValue),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (asset.profitLoss != null)
                    Text(
                      '${asset.profitLoss! >= 0 ? '+' : ''}${currencyFormat.format(asset.profitLoss)}',
                      style: TextStyle(
                        color: asset.profitLoss! >= 0
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWeight(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    final text = value.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
