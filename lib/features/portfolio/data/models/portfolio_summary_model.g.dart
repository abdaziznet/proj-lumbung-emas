// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortfolioSummaryModel _$PortfolioSummaryModelFromJson(
  Map<String, dynamic> json,
) => PortfolioSummaryModel(
  userId: json['user_id'] as String,
  totalAssetsValue: (json['total_assets_value'] as num).toDouble(),
  totalInvested: (json['total_invested'] as num).toDouble(),
  totalProfitLoss: (json['total_profit_loss'] as num).toDouble(),
  profitLossPercentage: (json['profit_loss_percentage'] as num).toDouble(),
  goldValue: (json['gold_value'] as num).toDouble(),
  silverValue: (json['silver_value'] as num).toDouble(),
  totalTransactions: (json['total_transactions'] as num).toInt(),
  lastCalculated: (json['last_calculated'] as num).toInt(),
);

Map<String, dynamic> _$PortfolioSummaryModelToJson(
  PortfolioSummaryModel instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'total_assets_value': instance.totalAssetsValue,
  'total_invested': instance.totalInvested,
  'total_profit_loss': instance.totalProfitLoss,
  'profit_loss_percentage': instance.profitLossPercentage,
  'gold_value': instance.goldValue,
  'silver_value': instance.silverValue,
  'total_transactions': instance.totalTransactions,
  'last_calculated': instance.lastCalculated,
};
