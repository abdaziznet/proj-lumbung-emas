import 'package:equatable/equatable.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';

/// Metal asset entity representing a precious metal transaction/holding
class MetalAsset extends Equatable {
  final String transactionId;
  final String userId;
  final String brand;
  final MetalType metalType;
  final double weightGram;
  final double purchasePricePerGram;
  final double totalPurchaseValue;
  final DateTime purchaseDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // Calculated fields (not stored, computed from current prices)
  final double? currentPricePerGram;
  final double? currentMarketValue;
  final double? profitLoss;
  final double? profitLossPercentage;

  const MetalAsset({
    required this.transactionId,
    required this.userId,
    required this.brand,
    required this.metalType,
    required this.weightGram,
    required this.purchasePricePerGram,
    required this.totalPurchaseValue,
    required this.purchaseDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.currentPricePerGram,
    this.currentMarketValue,
    this.profitLoss,
    this.profitLossPercentage,
  });

  /// Calculate profit/loss with current price
  MetalAsset withCurrentPrice(double currentPrice) {
    final marketValue = weightGram * currentPrice;
    final profit = marketValue - totalPurchaseValue;
    final profitPercent = (profit / totalPurchaseValue) * 100;

    return copyWith(
      currentPricePerGram: currentPrice,
      currentMarketValue: marketValue,
      profitLoss: profit,
      profitLossPercentage: profitPercent,
    );
  }

  bool get isProfitable => (profitLoss ?? 0) > 0;
  bool get isLoss => (profitLoss ?? 0) < 0;
  bool get isBreakEven => (profitLoss ?? 0) == 0;

  MetalAsset copyWith({
    String? transactionId,
    String? userId,
    String? brand,
    MetalType? metalType,
    double? weightGram,
    double? purchasePricePerGram,
    double? totalPurchaseValue,
    DateTime? purchaseDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    double? currentPricePerGram,
    double? currentMarketValue,
    double? profitLoss,
    double? profitLossPercentage,
  }) {
    return MetalAsset(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      metalType: metalType ?? this.metalType,
      weightGram: weightGram ?? this.weightGram,
      purchasePricePerGram: purchasePricePerGram ?? this.purchasePricePerGram,
      totalPurchaseValue: totalPurchaseValue ?? this.totalPurchaseValue,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      currentPricePerGram: currentPricePerGram ?? this.currentPricePerGram,
      currentMarketValue: currentMarketValue ?? this.currentMarketValue,
      profitLoss: profitLoss ?? this.profitLoss,
      profitLossPercentage: profitLossPercentage ?? this.profitLossPercentage,
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        userId,
        brand,
        metalType,
        weightGram,
        purchasePricePerGram,
        totalPurchaseValue,
        purchaseDate,
        notes,
        createdAt,
        updatedAt,
        isDeleted,
        currentPricePerGram,
        currentMarketValue,
        profitLoss,
        profitLossPercentage,
      ];

  @override
  String toString() {
    return 'MetalAsset(id: $transactionId, brand: $brand, type: $metalType, weight: ${weightGram}g, profit: $profitLoss)';
  }
}
