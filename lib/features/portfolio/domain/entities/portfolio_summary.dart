import 'package:equatable/equatable.dart';

/// Portfolio summary entity with aggregated statistics
class PortfolioSummary extends Equatable {
  final String userId;
  final double totalAssetsValue;
  final double totalInvested;
  final double totalProfitLoss;
  final double profitLossPercentage;
  final double goldValue;
  final double silverValue;
  final int totalTransactions;
  final DateTime lastCalculated;

  const PortfolioSummary({
    required this.userId,
    required this.totalAssetsValue,
    required this.totalInvested,
    required this.totalProfitLoss,
    required this.profitLossPercentage,
    required this.goldValue,
    required this.silverValue,
    required this.totalTransactions,
    required this.lastCalculated,
  });

  /// Create an empty portfolio summary
  factory PortfolioSummary.empty(String userId) {
    return PortfolioSummary(
      userId: userId,
      totalAssetsValue: 0,
      totalInvested: 0,
      totalProfitLoss: 0,
      profitLossPercentage: 0,
      goldValue: 0,
      silverValue: 0,
      totalTransactions: 0,
      lastCalculated: DateTime.now(),
    );
  }

  /// Calculate gold allocation percentage
  double get goldAllocationPercentage {
    if (totalAssetsValue == 0) return 0;
    return (goldValue / totalAssetsValue) * 100;
  }

  /// Calculate silver allocation percentage
  double get silverAllocationPercentage {
    if (totalAssetsValue == 0) return 0;
    return (silverValue / totalAssetsValue) * 100;
  }

  bool get isProfitable => totalProfitLoss > 0;
  bool get isLoss => totalProfitLoss < 0;
  bool get isBreakEven => totalProfitLoss == 0;

  PortfolioSummary copyWith({
    String? userId,
    double? totalAssetsValue,
    double? totalInvested,
    double? totalProfitLoss,
    double? profitLossPercentage,
    double? goldValue,
    double? silverValue,
    int? totalTransactions,
    DateTime? lastCalculated,
  }) {
    return PortfolioSummary(
      userId: userId ?? this.userId,
      totalAssetsValue: totalAssetsValue ?? this.totalAssetsValue,
      totalInvested: totalInvested ?? this.totalInvested,
      totalProfitLoss: totalProfitLoss ?? this.totalProfitLoss,
      profitLossPercentage: profitLossPercentage ?? this.profitLossPercentage,
      goldValue: goldValue ?? this.goldValue,
      silverValue: silverValue ?? this.silverValue,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      lastCalculated: lastCalculated ?? this.lastCalculated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        totalAssetsValue,
        totalInvested,
        totalProfitLoss,
        profitLossPercentage,
        goldValue,
        silverValue,
        totalTransactions,
        lastCalculated,
      ];

  @override
  String toString() {
    return 'PortfolioSummary(value: $totalAssetsValue, profit: $totalProfitLoss, transactions: $totalTransactions)';
  }
}
