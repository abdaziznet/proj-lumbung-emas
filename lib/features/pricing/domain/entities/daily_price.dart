import 'package:equatable/equatable.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';

/// Daily price entity for a specific brand and metal type
class DailyPrice extends Equatable {
  final String priceId;
  final String brand;
  final MetalType metalType;
  final double buyPrice;
  final double sellPrice;
  final DateTime priceDate;
  final DateTime createdAt;
  final String? updatedBy;

  const DailyPrice({
    required this.priceId,
    required this.brand,
    required this.metalType,
    required this.buyPrice,
    required this.sellPrice,
    required this.priceDate,
    required this.createdAt,
    this.updatedBy,
  });

  /// Calculate spread (difference between buy and sell price)
  double get spread => buyPrice - sellPrice;

  /// Calculate spread percentage
  double get spreadPercentage => (spread / buyPrice) * 100;

  DailyPrice copyWith({
    String? priceId,
    String? brand,
    MetalType? metalType,
    double? buyPrice,
    double? sellPrice,
    DateTime? priceDate,
    DateTime? createdAt,
    String? updatedBy,
  }) {
    return DailyPrice(
      priceId: priceId ?? this.priceId,
      brand: brand ?? this.brand,
      metalType: metalType ?? this.metalType,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      priceDate: priceDate ?? this.priceDate,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        priceId,
        brand,
        metalType,
        buyPrice,
        sellPrice,
        priceDate,
        createdAt,
        updatedBy,
      ];

  @override
  String toString() {
    return 'DailyPrice(brand: $brand, type: $metalType, sell: $sellPrice, date: $priceDate)';
  }
}
