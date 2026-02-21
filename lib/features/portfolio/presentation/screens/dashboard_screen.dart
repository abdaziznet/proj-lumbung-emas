import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/presentation/providers/portfolio_provider.dart';
import 'package:lumbungemas/features/portfolio/presentation/screens/add_transaction_screen.dart';
import 'package:lumbungemas/features/portfolio/presentation/screens/analytics_dashboard_screen.dart';
import 'package:lumbungemas/features/portfolio/presentation/screens/all_assets_screen.dart';
import 'package:lumbungemas/features/pricing/domain/entities/daily_price.dart';
import 'package:lumbungemas/features/pricing/presentation/providers/pricing_provider.dart';
import 'package:lumbungemas/shared/presentation/widgets/asset_item_card.dart';
import 'package:lumbungemas/shared/presentation/widgets/summary_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const List<_TickerItem> _defaultTickerItems = [
    _TickerItem(brand: 'Antam', metalType: MetalType.gold),
    _TickerItem(brand: 'UBS', metalType: MetalType.gold),
    _TickerItem(brand: 'EmasKu', metalType: MetalType.gold),
    _TickerItem(brand: 'Galeri 24', metalType: MetalType.gold),
    _TickerItem(brand: 'Antam', metalType: MetalType.silver),
  ];

  final List<_TickerItem> _manualTickerItems = [];
  bool _isAssetValueHidden = true;

  String _priceKey(String brand, MetalType metalType) {
    return '${brand.trim().toLowerCase()}_${metalType.apiValue.toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final portfolioState = ref.watch(portfolioProvider);
    final pricingState = ref.watch(pricingProvider);
    final displayedAssets = List<MetalAsset>.from(portfolioState.assets)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final limitedAssets = displayedAssets.take(5).toList();
    final latestPriceByKey = <String, double>{};
    final latestSellByKey = <String, double>{};
    for (final price in pricingState.prices) {
      final key = _priceKey(price.brand, price.metalType);
      latestPriceByKey[key] = price.buyPrice;
      latestSellByKey[key] = price.sellPrice;
    }

    final tickerItems = _mergeTickerItems(
      _defaultTickerItems,
      _manualTickerItems,
      pricingState.prices
          .map((price) => _TickerItem(brand: price.brand, metalType: price.metalType))
          .toList(),
    );

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(portfolioProvider.notifier).loadPortfolio();
          await ref.read(pricingProvider.notifier).loadPrices();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: user?.photoUrl == null
                            ? const Icon(Icons.person, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Halo,',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            user?.displayName ?? 'Investor',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_outlined,
                          color: AppColors.error,
                        ),
                        onPressed: () => _showLogoutDialog(context, ref),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Market Price Ticker
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Row(
                  children: [
                    const Text(
                      'Buyback Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _latestUpdateLabel(pricingState.prices),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: tickerItems.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == tickerItems.length) {
                      return SizedBox(
                        width: 90,
                        child: _buildAddTickerButton(
                          context,
                          onTap: () async {
                            final newItem = await _showAddTickerDialog(context);
                            if (newItem == null || !context.mounted) return;

                            final exists = tickerItems.any(
                              (item) =>
                                  _priceKey(item.brand, item.metalType) ==
                                  _priceKey(newItem.brand, newItem.metalType),
                            );

                            if (exists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ticker sudah ada'),
                                ),
                              );
                              return;
                            }

                            final saved = await _showPriceManagementDialog(
                              context,
                              ref,
                              brand: newItem.brand,
                              metalType: newItem.metalType,
                            );
                            if (!saved || !context.mounted) return;

                            setState(() {
                              _manualTickerItems.add(newItem);
                            });
                          },
                        ),
                      );
                    }

                    final item = tickerItems[index];
                    final key = _priceKey(item.brand, item.metalType);
                    final buyPrice = latestPriceByKey[key];
                    final sellPrice = latestSellByKey[key];
                    final style = _tickerStyleFor(index);
                    final isDefaultItem = _defaultTickerItems.any(
                      (defaultItem) =>
                          _priceKey(defaultItem.brand, defaultItem.metalType) ==
                          _priceKey(item.brand, item.metalType),
                    );

                    return SizedBox(
                      width: 155,
                      child: _buildPriceTicker(
                        context,
                        item.brand,
                        '${item.brand} ${item.metalType.displayName}',
                        sellPrice,
                        currencyFormat,
                        style: style,
                        onTap: () => _showPriceManagementDialog(
                          context,
                          ref,
                          brand: item.brand,
                          metalType: item.metalType,
                          initialBuyPrice: buyPrice,
                          initialSellPrice: sellPrice,
                        ),
                        onLongPress: isDefaultItem
                            ? null
                            : () => _confirmDeleteTicker(context, item),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Portfolio Summary Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryCard(
                      title: 'Total Nilai Aset',
                      value: portfolioState.totalMarketValue,
                      subtitleValue: portfolioState.totalProfitLoss,
                      subtitleLabel: _profitLossLabel(
                        portfolioState.totalProfitLoss,
                      ),
                      isProfit: portfolioState.totalProfitLoss >= 0,
                      icon: Icons.account_balance_wallet_outlined,
                      obscureValues: _isAssetValueHidden,
                      onToggleObscure: () {
                        setState(() {
                          _isAssetValueHidden = !_isAssetValueHidden;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats Row
                    Row(
                      children: [
                        _buildQuickStat(
                          context,
                          'Total Emas',
                          '${_formatWeight(portfolioState.totalGoldWeight)} gram',
                          'assets/images/ic-gold.svg',
                          AppColors.primaryDark,
                        ),
                        const SizedBox(width: 16),
                        _buildQuickStat(
                          context,
                          'Total Perak',
                          '${_formatWeight(portfolioState.totalSilverWeight)} gram',
                          'assets/images/ic-silver.svg',
                          const Color(0xFF6B7280),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsMenu(context),
                    const SizedBox(height: 32),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aset Saya',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllAssetsScreen(),
                            ),
                          ),
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Assets List
            if (portfolioState.isLoading && portfolioState.assets.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (portfolioState.assets.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada aset.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddTransactionScreen(),
                            ),
                          ),
                          child: const Text('Tambah Aset Pertama'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final asset = limitedAssets[index];
                    return AssetItemCard(
                      asset: asset,
                      onEdit: () => _editAsset(context, ref, asset),
                      onDelete: () => _confirmDeleteAsset(context, ref, asset),
                    );
                  }, childCount: limitedAssets.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
        ),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editAsset(
    BuildContext context,
    WidgetRef ref,
    MetalAsset asset,
  ) async {
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
        content: Text(
          'Jual transaksi ${asset.brand} ${asset.metalType.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Jual',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(portfolioProvider.notifier)
        .deleteTransaction(asset.transactionId);
    if (!context.mounted) return;

    final error = ref.read(portfolioProvider).error;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Aset berhasil dijual')));
  }

  Widget _buildPriceTicker(
    BuildContext context,
    String brand,
    String label,
    double? price,
    NumberFormat format, {
    required _TickerStyle style,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return Material(
      color: style.backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: style.borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTickerBrandLogo(brand),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: style.labelColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                price != null ? format.format(price) : '---',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: style.valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTicker(BuildContext context, _TickerItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Price Ticker'),
        content: Text('Hapus ticker ${item.brand} ${item.metalType.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref.read(pricingProvider.notifier).deletePrice(
          brand: item.brand,
          metalType: item.metalType,
        );

    if (!context.mounted) return;

    if (!success) {
      final error = ref.read(pricingProvider).error ?? 'Gagal menghapus ticker';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() {
      _manualTickerItems.removeWhere(
        (manual) =>
            _priceKey(manual.brand, manual.metalType) ==
            _priceKey(item.brand, item.metalType),
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ticker berhasil dihapus')));
  }

  Widget _buildTickerBrandLogo(String brand) {
    final logoPath = _brandLogoPath(brand);
    return SizedBox(
      width: 14,
      height: 14,
      child: SvgPicture.asset(
        logoPath ?? 'assets/icons/gold.svg',
        fit: BoxFit.contain,
      ),
    );
  }

  String? _brandLogoPath(String brand) {
    final normalized = brand.trim().toLowerCase();
    switch (normalized) {
      case 'antam':
        return 'assets/images/antam-logo.svg';
      case 'ubs':
        return 'assets/images/ubs-logo.svg';
      case 'emasku':
        return 'assets/images/emasku-logo.svg';
      case 'galeri 24':
      case 'galeri24':
        return 'assets/images/galeri24.svg';
      case 'bsi':
        return 'assets/images/bsi-logo.svg';
      default:
        return 'assets/icons/gold.svg';
    }
  }

  Widget _buildAddTickerButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.secondary),
              SizedBox(height: 4),
              Text(
                'Tambah',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<_TickerItem?> _showAddTickerDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final brandController = TextEditingController();
    var metalType = MetalType.gold;

    return showDialog<_TickerItem>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Price Ticker'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand (contoh: UBS)',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Brand wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MetalType>(
                      initialValue: metalType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Logam',
                      ),
                      items: MetalType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => metalType = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(
                      dialogContext,
                      _TickerItem(
                        brand: brandController.text.trim(),
                        metalType: metalType,
                      ),
                    );
                  },
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _showPriceManagementDialog(
    BuildContext context,
    WidgetRef ref, {
    required String brand,
    required MetalType metalType,
    double? initialBuyPrice,
    double? initialSellPrice,
  }) async {
    final formKey = GlobalKey<FormState>();
    final formatter = NumberFormat.decimalPattern('id_ID');
    final buyController = TextEditingController(
      text: initialBuyPrice != null && initialBuyPrice > 0
          ? formatter.format(initialBuyPrice.toInt())
          : '',
    );
    final sellController = TextEditingController(
      text: initialSellPrice != null && initialSellPrice > 0
          ? formatter.format(initialSellPrice.toInt())
          : '',
    );

    var isSubmitting = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Update Harga $brand ${metalType.displayName}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: buyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _RupiahTextInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Harga Beli (Rp)',
                      ),
                      validator: (value) {
                        final parsed = _parseRupiah(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Harga beli wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: sellController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _RupiahTextInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Harga Jual (Rp)',
                      ),
                      validator: (value) {
                        final parsed = _parseRupiah(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Harga jual wajib diisi';
                        }
                        return null;
                      },
                    ),
                    if (isSubmitting) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(minHeight: 3),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (isSubmitting) return;
                    if (!formKey.currentState!.validate()) return;

                    final buyPrice = _parseRupiah(buyController.text);
                    final sellPrice = _parseRupiah(sellController.text);
                    if (buyPrice == null || sellPrice == null) return;
                    if (sellPrice > buyPrice) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Harga jual tidak boleh lebih besar dari harga beli',
                            ),
                          ),
                        );
                      }
                      return;
                    }

                    setDialogState(() => isSubmitting = true);
                    try {
                      final user = ref.read(currentUserProvider);
                      final isSuccess = await ref
                          .read(pricingProvider.notifier)
                          .updateTodayPrice(
                            brand: brand,
                            metalType: metalType,
                            buyPrice: buyPrice,
                            sellPrice: sellPrice,
                            updatedBy: user?.email,
                          );

                      if (!dialogContext.mounted) return;

                      if (isSuccess) {
                        await ref.read(portfolioProvider.notifier).loadPortfolio();
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext, true);
                        return;
                      }

                      final message =
                          ref.read(pricingProvider).error ??
                          'Gagal menyimpan harga. Silakan coba lagi.';
                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    } catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('Terjadi error saat menyimpan: $e'),
                          ),
                        );
                      }
                    } finally {
                      if (dialogContext.mounted) {
                        setDialogState(() => isSubmitting = false);
                      }
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted) return false;

    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga hari ini berhasil diperbarui')),
      );
    }
    return saved == true;
  }

  double? _parseRupiah(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;
    return double.tryParse(digitsOnly);
  }

  String _formatWeight(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    final text = value.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _profitLossLabel(double totalProfitLoss) {
    if (totalProfitLoss > 0) {
      return 'Keuntungan Total';
    }
    if (totalProfitLoss < 0) {
      return 'Kerugian Total';
    }
    return 'Impas';
  }

  _TickerStyle _tickerStyleFor(int index) {
    const palettes = <_TickerStyle>[
      _TickerStyle(
        backgroundColor: Color(0xFFFFF4D8),
        borderColor: Color(0xFFF1D48A),
        labelColor: Color(0xFF8A6A1A),
        valueColor: Color(0xFF5A430C),
      ),
      _TickerStyle(
        backgroundColor: Color(0xFFE8F4FF),
        borderColor: Color(0xFFAED2F5),
        labelColor: Color(0xFF2E5A7F),
        valueColor: Color(0xFF163954),
      ),
      _TickerStyle(
        backgroundColor: Color(0xFFE8FFF3),
        borderColor: Color(0xFF9CDCB9),
        labelColor: Color(0xFF2D6B4A),
        valueColor: Color(0xFF13422A),
      ),
      _TickerStyle(
        backgroundColor: Color(0xFFFFEDEF),
        borderColor: Color(0xFFF2B3BA),
        labelColor: Color(0xFF8A3F4A),
        valueColor: Color(0xFF5C1F29),
      ),
      _TickerStyle(
        backgroundColor: Color(0xFFF3EDFF),
        borderColor: Color(0xFFCBB8F8),
        labelColor: Color(0xFF5D4B88),
        valueColor: Color(0xFF35255F),
      ),
      _TickerStyle(
        backgroundColor: Color(0xFFFFF1E8),
        borderColor: Color(0xFFF2C6A5),
        labelColor: Color(0xFF8D5A2E),
        valueColor: Color(0xFF633A1A),
      ),
      _TickerStyle(
        backgroundColor: Color(0xFFEAFBFF),
        borderColor: Color(0xFFA9DBE8),
        labelColor: Color(0xFF2E6673),
        valueColor: Color(0xFF16424D),
      ),
      _TickerStyle(
        backgroundColor: Color(0xFFF4FFE8),
        borderColor: Color(0xFFCAE7A0),
        labelColor: Color(0xFF58732E),
        valueColor: Color(0xFF364D16),
      ),
      _TickerStyle(
        backgroundColor: Color(0xFFFFF0FA),
        borderColor: Color(0xFFF0C0DE),
        labelColor: Color(0xFF7A3D65),
        valueColor: Color(0xFF4E1F3F),
      ),
      _TickerStyle(
        backgroundColor: Color(0xFFEDF2FF),
        borderColor: Color(0xFFB9C8F2),
        labelColor: Color(0xFF415B8F),
        valueColor: Color(0xFF223A67),
      ),
    ];

    return palettes[index % palettes.length];
  }

  String _latestUpdateLabel(List<DailyPrice> prices) {
    if (prices.isEmpty) return 'Update: -';
    final latest = prices
        .map((p) => p.priceDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final formatted = DateFormat('dd MMM yyyy HH:mm:ss').format(latest);
    return 'Update: $formatted';
  }

  List<_TickerItem> _mergeTickerItems(
    List<_TickerItem> defaults,
    List<_TickerItem> manual,
    List<_TickerItem> fromPrices,
  ) {
    final merged = <_TickerItem>[
      ...defaults,
      ...manual,
      ...fromPrices,
    ];
    final seen = <String>{};
    final result = <_TickerItem>[];
    for (final item in merged) {
      final key = _priceKey(item.brand, item.metalType);
      if (seen.add(key)) {
        result.add(item);
      }
    }
    return result;
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    String iconAsset,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: SvgPicture.asset(
                    iconAsset,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsMenu(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnalyticsDashboardScreen(),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart_outline,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Statistik, komposisi, dan performa portofolio',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RupiahTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final value = int.parse(digitsOnly);
    final newText = _formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class _TickerItem {
  final String brand;
  final MetalType metalType;

  const _TickerItem({required this.brand, required this.metalType});
}

class _TickerStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color labelColor;
  final Color valueColor;

  const _TickerStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.labelColor,
    required this.valueColor,
  });
}
