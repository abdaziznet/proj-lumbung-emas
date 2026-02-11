import 'package:json_annotation/json_annotation.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/portfolio_summary.dart';

part 'portfolio_summary_model.g.dart';

@JsonSerializable()
class PortfolioSummaryModel {
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'total_assets_value')
  final double totalAssetsValue;
  
  @JsonKey(name: 'total_invested')
  final double totalInvested;
  
  @JsonKey(name: 'total_profit_loss')
  final double totalProfitLoss;
  
  @JsonKey(name: 'profit_loss_percentage')
  final double profitLossPercentage;
  
  @JsonKey(name: 'gold_value')
  final double goldValue;
  
  @JsonKey(name: 'silver_value')
  final double silverValue;

  @JsonKey(name: 'total_transactions')
  final int totalTransactions;
  
  @JsonKey(name: 'last_calculated')
  final int lastCalculated;

  const PortfolioSummaryModel({
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

  PortfolioSummary toEntity() {
    return PortfolioSummary(
      userId: userId,
      totalAssetsValue: totalAssetsValue,
      totalInvested: totalInvested,
      totalProfitLoss: totalProfitLoss,
      profitLossPercentage: profitLossPercentage,
      goldValue: goldValue,
      silverValue: silverValue,
      totalTransactions: totalTransactions,
      lastCalculated: DateTime.fromMillisecondsSinceEpoch(lastCalculated),
    );
  }

  factory PortfolioSummaryModel.fromSheetRow(List<Object?> row) {
    return PortfolioSummaryModel(
      userId: row[0]?.toString() ?? '',
      totalAssetsValue: double.tryParse(row[1]?.toString() ?? '0') ?? 0,
      totalInvested: double.tryParse(row[2]?.toString() ?? '0') ?? 0,
      totalProfitLoss: double.tryParse(row[3]?.toString() ?? '0') ?? 0,
      profitLossPercentage: double.tryParse(row[4]?.toString() ?? '0') ?? 0,
      goldValue: double.tryParse(row[5]?.toString() ?? '0') ?? 0,
      silverValue: double.tryParse(row[6]?.toString() ?? '0') ?? 0,
      totalTransactions: int.tryParse(row.length > 7 ? row[7]?.toString() ?? '0' : '0') ?? 0,
      lastCalculated: int.tryParse(row.length > 8 ? row[8]?.toString() ?? '0' : '0') ?? 0,
    );
  }

  List<Object?> toSheetRow() {
    return [
      userId,
      totalAssetsValue.toString(),
      totalInvested.toString(),
      totalProfitLoss.toString(),
      profitLossPercentage.toString(),
      goldValue.toString(),
      silverValue.toString(),
      totalTransactions.toString(),
      lastCalculated.toString(),
    ];
  }

  factory PortfolioSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$PortfolioSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioSummaryModelToJson(this);
}
