// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_price_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyPriceModel _$DailyPriceModelFromJson(Map<String, dynamic> json) =>
    DailyPriceModel(
      priceId: json['price_id'] as String,
      brand: json['brand'] as String,
      metalType: json['metal_type'] as String,
      buyPrice: (json['buy_price'] as num).toDouble(),
      sellPrice: (json['sell_price'] as num).toDouble(),
      priceDate: (json['price_date'] as num).toInt(),
      createdAt: (json['created_at'] as num).toInt(),
      updatedBy: json['updated_by'] as String?,
    );

Map<String, dynamic> _$DailyPriceModelToJson(DailyPriceModel instance) =>
    <String, dynamic>{
      'price_id': instance.priceId,
      'brand': instance.brand,
      'metal_type': instance.metalType,
      'buy_price': instance.buyPrice,
      'sell_price': instance.sellPrice,
      'price_date': instance.priceDate,
      'created_at': instance.createdAt,
      'updated_by': instance.updatedBy,
    };
