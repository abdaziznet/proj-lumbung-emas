// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metal_asset_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetalAssetModel _$MetalAssetModelFromJson(Map<String, dynamic> json) =>
    MetalAssetModel(
      transactionId: json['transaction_id'] as String,
      userId: json['user_id'] as String,
      brand: json['brand'] as String,
      metalType: json['metal_type'] as String,
      weightGram: (json['weight_gram'] as num).toDouble(),
      purchasePricePerGram: (json['purchase_price_per_gram'] as num).toDouble(),
      totalPurchaseValue: (json['total_purchase_value'] as num).toDouble(),
      purchaseDate: (json['purchase_date'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      isDeleted: json['is_deleted'] as bool? ?? false,
      currentPricePerGram: (json['current_price_per_gram'] as num?)?.toDouble(),
      currentMarketValue: (json['current_market_value'] as num?)?.toDouble(),
      profitLoss: (json['profit_loss'] as num?)?.toDouble(),
      profitLossPercentage: (json['profit_loss_percentage'] as num?)
          ?.toDouble(),
    );

Map<String, dynamic> _$MetalAssetModelToJson(MetalAssetModel instance) =>
    <String, dynamic>{
      'transaction_id': instance.transactionId,
      'user_id': instance.userId,
      'brand': instance.brand,
      'metal_type': instance.metalType,
      'weight_gram': instance.weightGram,
      'purchase_price_per_gram': instance.purchasePricePerGram,
      'total_purchase_value': instance.totalPurchaseValue,
      'purchase_date': instance.purchaseDate,
      'notes': instance.notes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'is_deleted': instance.isDeleted,
      'current_price_per_gram': instance.currentPricePerGram,
      'current_market_value': instance.currentMarketValue,
      'profit_loss': instance.profitLoss,
      'profit_loss_percentage': instance.profitLossPercentage,
    };
