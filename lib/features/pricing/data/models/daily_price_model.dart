import 'package:json_annotation/json_annotation.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/features/pricing/domain/entities/daily_price.dart';

part 'daily_price_model.g.dart';

/// Daily price data model for JSON serialization
@JsonSerializable()
class DailyPriceModel {
  @JsonKey(name: 'price_id')
  final String priceId;

  @JsonKey(name: 'brand')
  final String brand;

  @JsonKey(name: 'metal_type')
  final String metalType;

  @JsonKey(name: 'buy_price')
  final double buyPrice;

  @JsonKey(name: 'sell_price')
  final double sellPrice;

  @JsonKey(name: 'price_date')
  final int priceDate;

  @JsonKey(name: 'created_at')
  final int createdAt;

  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  const DailyPriceModel({
    required this.priceId,
    required this.brand,
    required this.metalType,
    required this.buyPrice,
    required this.sellPrice,
    required this.priceDate,
    required this.createdAt,
    this.updatedBy,
  });

  /// Convert to domain entity
  DailyPrice toEntity() {
    return DailyPrice(
      priceId: priceId,
      brand: brand,
      metalType: MetalType.fromString(metalType),
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      priceDate: DateTime.fromMillisecondsSinceEpoch(priceDate),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedBy: updatedBy,
    );
  }

  /// Create from domain entity
  factory DailyPriceModel.fromEntity(DailyPrice entity) {
    return DailyPriceModel(
      priceId: entity.priceId,
      brand: entity.brand,
      metalType: entity.metalType.apiValue,
      buyPrice: entity.buyPrice,
      sellPrice: entity.sellPrice,
      priceDate: entity.priceDate.millisecondsSinceEpoch,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedBy: entity.updatedBy,
    );
  }

  /// Create from Google Sheets row
  factory DailyPriceModel.fromSheetRow(List<Object?> row) {
    return DailyPriceModel(
      priceId: row[0]?.toString() ?? '',
      brand: row[1]?.toString() ?? '',
      metalType: row[2]?.toString() ?? 'GOLD',
      buyPrice: double.tryParse(row[3]?.toString() ?? '0') ?? 0,
      sellPrice: double.tryParse(row[4]?.toString() ?? '0') ?? 0,
      priceDate: int.tryParse(row[5]?.toString() ?? '0') ?? 0,
      createdAt: row.length > 6
          ? int.tryParse(row[6]?.toString() ?? '0') ?? 0
          : DateTime.now().millisecondsSinceEpoch,
      updatedBy: row.length > 7 ? row[7]?.toString() : null,
    );
  }

  /// Convert to Google Sheets row
  List<Object?> toSheetRow() {
    return [
      priceId,
      brand,
      metalType,
      buyPrice.toString(),
      sellPrice.toString(),
      priceDate.toString(),
      createdAt.toString(),
      updatedBy ?? '',
    ];
  }

  /// JSON serialization
  factory DailyPriceModel.fromJson(Map<String, dynamic> json) =>
      _$DailyPriceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyPriceModelToJson(this);

  DailyPriceModel copyWith({
    String? priceId,
    String? brand,
    String? metalType,
    double? buyPrice,
    double? sellPrice,
    int? priceDate,
    int? createdAt,
    String? updatedBy,
  }) {
    return DailyPriceModel(
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
}
