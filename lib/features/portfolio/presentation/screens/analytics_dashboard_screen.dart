import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/presentation/providers/portfolio_provider.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioProvider);
    final assets = List<MetalAsset>.from(portfolioState.assets)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final totalValue = assets.fold<double>(
      0,
      (sum, item) => sum + (item.currentMarketValue ?? item.totalPurchaseValue),
    );
    final totalInvested =
        assets.fold<double>(0, (sum, item) => sum + item.totalPurchaseValue);
    final totalProfit =
        assets.fold<double>(0, (sum, item) => sum + (item.profitLoss ?? 0));
    final profitableCount = assets.where((a) => (a.profitLoss ?? 0) > 0).length;
    final winRate = assets.isEmpty ? 0 : (profitableCount / assets.length) * 100;
    final returnPct = totalInvested <= 0 ? 0 : (totalProfit / totalInvested) * 100;

    final goldValue = assets
        .where((a) => a.metalType == MetalType.gold)
        .fold<double>(
          0,
          (sum, item) => sum + (item.currentMarketValue ?? item.totalPurchaseValue),
        );
    final silverValue = assets
        .where((a) => a.metalType == MetalType.silver)
        .fold<double>(
          0,
          (sum, item) => sum + (item.currentMarketValue ?? item.totalPurchaseValue),
        );

    final brandPerformance = <String, double>{};
    for (final asset in assets) {
      brandPerformance.update(
        asset.brand,
        (value) => value + (asset.profitLoss ?? 0),
        ifAbsent: () => (asset.profitLoss ?? 0),
      );
    }
                    final brandCounts = <String, int>{};
                    for (final asset in assets) {
                      brandCounts.update(asset.brand, (value) => value + 1, ifAbsent: () => 1);
                    }
    final brandCountEntries = brandCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalBrandCount = brandCountEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.value,
    );
    final perfEntries = brandPerformance.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final topPerfEntries = perfEntries.take(6).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.secondary,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(portfolioProvider.notifier).loadPortfolio(),
        child: portfolioState.isLoading && assets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : assets.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 140),
                      Center(
                        child: Text(
                          'Belum ada data aset untuk dianalisis.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    children: [
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.36,
                        children: [
                          _StatCard(
                            title: 'Nilai Portofolio',
                            value: currencyFormat.format(totalValue),
                            icon: Icons.account_balance_wallet_outlined,
                            accent: const Color(0xFFD6A741),
                          ),
                          _StatCard(
                            title: 'Total Profit/Loss',
                            value: currencyFormat.format(totalProfit),
                            icon: totalProfit >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            accent: totalProfit >= 0
                                ? const Color(0xFF18864B)
                                : const Color(0xFFBE3C3C),
                          ),
                          _StatCard(
                            title: 'Win Rate',
                            value: '${winRate.toStringAsFixed(1)}%',
                            icon: Icons.track_changes_outlined,
                            accent: const Color(0xFF3B82F6),
                          ),
                          _StatCard(
                            title: 'Return',
                            value: '${returnPct.toStringAsFixed(2)}%',
                            icon: Icons.insights_outlined,
                            accent: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _CardSection(
                        title: 'Komposisi Portofolio',
                        subtitle: 'Distribusi nilai pasar berdasarkan jenis logam',
                        child: SizedBox(
                          height: 250,
                          child: Row(
                            children: [
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 42,
                                    sections: _buildPieSections(
                                      goldValue: goldValue,
                                      silverValue: silverValue,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 120,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _LegendItem(
                                      color: const Color(0xFFD6A741),
                                      label: 'Gold',
                                      value: _percentLabel(goldValue, totalValue),
                                    ),
                                    const SizedBox(height: 10),
                                    _LegendItem(
                                      color: const Color(0xFF93A3B8),
                                      label: 'Silver',
                                      value: _percentLabel(silverValue, totalValue),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _CardSection(
                        title: 'Jumlah Aset per Brand',
                        subtitle: 'Jumlah transaksi yang dimiliki per brand',
                        child: SizedBox(
                          height: 260,
                          child: Row(
                            children: [
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 42,
                                    sections: _buildBrandPieSections(
                                      entries: brandCountEntries,
                                      total: totalBrandCount,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 140,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: brandCountEntries.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final entry = brandCountEntries[index];
                                    final color = _brandPieColor(index);
                                    final percent = totalBrandCount == 0
                                        ? '0%'
                                        : '${((entry.value / totalBrandCount) * 100).toStringAsFixed(1)}%';
                                    return _LegendItem(
                                      color: color,
                                      label: entry.key,
                                      value: percent,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _CardSection(
                        title: 'Performa per Brand',
                        subtitle: 'Akumulasi profit/loss per brand',
                        child: SizedBox(
                          height: 280,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= topPerfEntries.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final brand = topPerfEntries[idx].key;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          brand,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (int i = 0; i < topPerfEntries.length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: topPerfEntries[i].value,
                                        width: 18,
                                        borderRadius: BorderRadius.circular(6),
                                        color: topPerfEntries[i].value >= 0
                                            ? const Color(0xFF18864B)
                                            : const Color(0xFFBE3C3C),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections({
    required double goldValue,
    required double silverValue,
  }) {
    final total = goldValue + silverValue;
    if (total <= 0) {
      return [
        PieChartSectionData(
          color: const Color(0xFFE5E7EB),
          value: 1,
          title: '0%',
          radius: 60,
          titleStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: const Color(0xFFD6A741),
        value: goldValue,
        title: '${((goldValue / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFF93A3B8),
        value: silverValue,
        title: '${((silverValue / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    ];
  }

  String _percentLabel(double value, double total) {
    if (total <= 0) return '0%';
    return '${((value / total) * 100).toStringAsFixed(1)}%';
  }

  List<PieChartSectionData> _buildBrandPieSections({
    required List<MapEntry<String, int>> entries,
    required int total,
  }) {
    if (total <= 0 || entries.isEmpty) {
      return [
        PieChartSectionData(
          color: const Color(0xFFE5E7EB),
          value: 1,
          title: '0%',
          radius: 60,
          titleStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ];
    }

    return [
      for (int i = 0; i < entries.length; i++)
        PieChartSectionData(
          color: _brandPieColor(i),
          value: entries[i].value.toDouble(),
          title: '${((entries[i].value / total) * 100).toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
    ];
  }

  Color _brandPieColor(int index) {
    const palette = <Color>[
      Color(0xFFD6A741),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFF14B8A6),
      Color(0xFFEF4444),
    ];
    return palette[index % palette.length];
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CardSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textBody,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
