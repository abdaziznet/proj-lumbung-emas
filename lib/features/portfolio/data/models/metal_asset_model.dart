import 'package:json_annotation/json_annotation.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';

part 'metal_asset_model.g.dart';

/// Metal asset data model for JSON serialization
@JsonSerializable()
class MetalAssetModel {
  @JsonKey(name: 'transaction_id')
  final String transactionId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'brand')
  final String brand;

  @JsonKey(name: 'metal_type')
  final String metalType;

  @JsonKey(name: 'weight_gram')
  final double weightGram;

  @JsonKey(name: 'purchase_price_per_gram')
  final double purchasePricePerGram;

  @JsonKey(name: 'total_purchase_value')
  final double totalPurchaseValue;

  @JsonKey(name: 'purchase_date')
  final int purchaseDate;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'created_at')
  final int createdAt;

  @JsonKey(name: 'updated_at')
  final int updatedAt;

  @JsonKey(name: 'is_deleted')
  final bool isDeleted;

  @JsonKey(name: 'current_price_per_gram')
  final double? currentPricePerGram;

  @JsonKey(name: 'current_market_value')
  final double? currentMarketValue;

  @JsonKey(name: 'profit_loss')
  final double? profitLoss;

  @JsonKey(name: 'profit_loss_percentage')
  final double? profitLossPercentage;

  const MetalAssetModel({
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

  /// Convert to domain entity
  MetalAsset toEntity() {
    return MetalAsset(
      transactionId: transactionId,
      userId: userId,
      brand: brand,
      metalType: MetalType.fromString(metalType),
      weightGram: weightGram,
      purchasePricePerGram: purchasePricePerGram,
      totalPurchaseValue: totalPurchaseValue,
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(purchaseDate),
      notes: notes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      isDeleted: isDeleted,
      currentPricePerGram: currentPricePerGram,
      currentMarketValue: currentMarketValue,
      profitLoss: profitLoss,
      profitLossPercentage: profitLossPercentage,
    );
  }

  /// Create from domain entity
  factory MetalAssetModel.fromEntity(MetalAsset entity) {
    return MetalAssetModel(
      transactionId: entity.transactionId,
      userId: entity.userId,
      brand: entity.brand,
      metalType: entity.metalType.apiValue,
      weightGram: entity.weightGram,
      purchasePricePerGram: entity.purchasePricePerGram,
      totalPurchaseValue: entity.totalPurchaseValue,
      purchaseDate: entity.purchaseDate.millisecondsSinceEpoch,
      notes: entity.notes,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
      isDeleted: entity.isDeleted,
      currentPricePerGram: entity.currentPricePerGram,
      currentMarketValue: entity.currentMarketValue,
      profitLoss: entity.profitLoss,
      profitLossPercentage: entity.profitLossPercentage,
    );
  }

  /// Create from Google Sheets row
  factory MetalAssetModel.fromSheetRow(List<Object?> row) {
    return MetalAssetModel(
      transactionId: row[0]?.toString() ?? '',
      userId: row[1]?.toString() ?? '',
      brand: row[2]?.toString() ?? '',
      metalType: row[3]?.toString() ?? 'GOLD',
      weightGram: double.tryParse(row[4]?.toString() ?? '0') ?? 0,
      purchasePricePerGram: double.tryParse(row[5]?.toString() ?? '0') ?? 0,
      totalPurchaseValue: double.tryParse(row[6]?.toString() ?? '0') ?? 0,
      purchaseDate: int.tryParse(row[7]?.toString() ?? '0') ?? 0,
      notes: row.length > 8 ? row[8]?.toString() : null,
      createdAt: row.length > 9
          ? int.tryParse(row[9]?.toString() ?? '0') ?? 0
          : DateTime.now().millisecondsSinceEpoch,
      updatedAt: row.length > 10
          ? int.tryParse(row[10]?.toString() ?? '0') ?? 0
          : DateTime.now().millisecondsSinceEpoch,
      isDeleted: row.length > 11
          ? (row[11]?.toString().toUpperCase() == 'TRUE')
          : false,
    );
  }

  /// Convert to Google Sheets row
  List<Object?> toSheetRow() {
    return [
      transactionId,
      userId,
      brand,
      metalType,
      weightGram.toString(),
      purchasePricePerGram.toString(),
      totalPurchaseValue.toString(),
      purchaseDate.toString(),
      notes ?? '',
      createdAt.toString(),
      updatedAt.toString(),
      isDeleted ? 'TRUE' : 'FALSE',
    ];
  }

  /// JSON serialization
  factory MetalAssetModel.fromJson(Map<String, dynamic> json) =>
      _$MetalAssetModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetalAssetModelToJson(this);

  MetalAssetModel copyWith({
    String? transactionId,
    String? userId,
    String? brand,
    String? metalType,
    double? weightGram,
    double? purchasePricePerGram,
    double? totalPurchaseValue,
    int? purchaseDate,
    String? notes,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    double? currentPricePerGram,
    double? currentMarketValue,
    double? profitLoss,
    double? profitLossPercentage,
  }) {
    return MetalAssetModel(
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
}
