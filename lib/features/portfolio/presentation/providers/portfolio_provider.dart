import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:lumbungemas/features/portfolio/domain/usecases/add_transaction.dart';
import 'package:lumbungemas/features/portfolio/domain/usecases/delete_transaction.dart';
import 'package:lumbungemas/features/portfolio/domain/usecases/get_portfolio.dart';
import 'package:lumbungemas/features/portfolio/domain/usecases/get_portfolio_summary.dart';
import 'package:lumbungemas/features/portfolio/domain/usecases/update_transaction.dart';
import 'package:lumbungemas/features/pricing/domain/entities/daily_price.dart';
import 'package:lumbungemas/features/pricing/domain/usecases/get_current_prices.dart';
import 'package:lumbungemas/shared/data/providers/dependency_injection.dart';

/// State of the portfolio feature
class PortfolioState {
  final List<MetalAsset> assets;
  final PortfolioSummary? summary;
  final bool isLoading;
  final String? error;

  PortfolioState({
    this.assets = const [],
    this.summary,
    this.isLoading = false,
    this.error,
  });

  PortfolioState copyWith({
    List<MetalAsset>? assets,
    PortfolioSummary? summary,
    bool? isLoading,
    String? error,
  }) {
    return PortfolioState(
      assets: assets ?? this.assets,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Handy getters
  double get totalWeight => assets.fold(0, (sum, item) => sum + item.weightGram);
  double get totalInvested => assets.fold(0, (sum, item) => sum + item.totalPurchaseValue);
  double get totalMarketValue => assets.fold(0, (sum, item) => sum + (item.currentMarketValue ?? item.totalPurchaseValue));
  double get totalProfitLoss => assets.fold(0, (sum, item) => sum + (item.profitLoss ?? 0));
  
  double get totalGoldWeight => assets
      .where((a) => a.metalType == MetalType.gold)
      .fold(0, (sum, item) => sum + item.weightGram);
  double get totalSilverWeight => assets
      .where((a) => a.metalType == MetalType.silver)
      .fold(0, (sum, item) => sum + item.weightGram);
}

/// Portfolio controller notifier
class PortfolioNotifier extends StateNotifier<PortfolioState> {
  final GetPortfolioUseCase _getPortfolioUseCase;
  final AddTransactionUseCase _addTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;
  final GetPortfolioSummaryUseCase _getPortfolioSummaryUseCase;
  final GetCurrentPricesUseCase _getCurrentPricesUseCase;
  final Ref _ref;

  PortfolioNotifier({
    required GetPortfolioUseCase getPortfolioUseCase,
    required AddTransactionUseCase addTransactionUseCase,
    required UpdateTransactionUseCase updateTransactionUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
    required GetPortfolioSummaryUseCase getPortfolioSummaryUseCase,
    required GetCurrentPricesUseCase getCurrentPricesUseCase,
    required Ref ref,
  })  : _getPortfolioUseCase = getPortfolioUseCase,
        _addTransactionUseCase = addTransactionUseCase,
        _updateTransactionUseCase = updateTransactionUseCase,
        _deleteTransactionUseCase = deleteTransactionUseCase,
        _getPortfolioSummaryUseCase = getPortfolioSummaryUseCase,
        _getCurrentPricesUseCase = getCurrentPricesUseCase,
        _ref = ref,
        super(PortfolioState());

  void reset() {
    state = PortfolioState();
  }

  Future<void> loadPortfolio() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final sheetsService = _ref.read(googleSheetsServiceProvider);
      if (!sheetsService.isInitialized) {
        await sheetsService.authenticateWithServiceAccount();
      }
      
      final assetsResult = await _getPortfolioUseCase(user.userId);
      final summaryResult = await _getPortfolioSummaryUseCase(user.userId);
      final pricesResult = await _getCurrentPricesUseCase();
      
      // Load current prices to update asset valuations
      final currentPrices = pricesResult.getOrElse(() => []);
      
      assetsResult.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (assets) {
          // Apply current prices to assets
          final updatedAssets = assets.map((asset) {
            // 1. Try to find exact match: brand + metalType
            DailyPrice? latestPrice;
            try {
              latestPrice = currentPrices.firstWhere(
                (p) => p.brand.toLowerCase() == asset.brand.toLowerCase() && 
                       p.metalType == asset.metalType,
              );
            } catch (_) {
              // 2. Fallback to any price for the same metalType (e.g. Antam as benchmark)
              try {
                latestPrice = currentPrices.firstWhere(
                  (p) => p.metalType == asset.metalType,
                );
              } catch (_) {
                latestPrice = null;
              }
            }
            
            if (latestPrice != null && latestPrice.sellPrice > 0) {
              return asset.withCurrentPrice(latestPrice.sellPrice);
            }
            return asset;
          }).toList();

          summaryResult.fold(
            (failure) => state = state.copyWith(isLoading: false, assets: updatedAssets),
            (summary) => state = state.copyWith(isLoading: false, assets: updatedAssets, summary: summary),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Koneksi gagal: $e');
    }
  }

  Future<void> addTransaction(MetalAsset asset) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _addTransactionUseCase(asset);
      
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (newAsset) {
          state = state.copyWith(
            isLoading: false,
            assets: [...state.assets, newAsset],
          );
          // Reload portfolio to update summary (simplified)
          loadPortfolio();
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateTransaction(MetalAsset asset) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _updateTransactionUseCase(asset);
      
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (updatedAsset) {
          state = state.copyWith(
            isLoading: false,
            assets: state.assets.map((a) => a.transactionId == updatedAsset.transactionId ? updatedAsset : a).toList(),
          );
          loadPortfolio();
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _deleteTransactionUseCase(transactionId);
      
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (_) {
          state = state.copyWith(
            isLoading: false,
            assets: state.assets.where((a) => a.transactionId != transactionId).toList(),
          );
          loadPortfolio();
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Provider for portfolio notifier
final portfolioProvider = StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  final portfolioRepository = ref.watch(portfolioRepositoryProvider);
  final pricingRepository = ref.watch(pricingRepositoryProvider);
  
  final notifier = PortfolioNotifier(
    getPortfolioUseCase: GetPortfolioUseCase(portfolioRepository),
    addTransactionUseCase: AddTransactionUseCase(portfolioRepository),
    updateTransactionUseCase: UpdateTransactionUseCase(portfolioRepository),
    deleteTransactionUseCase: DeleteTransactionUseCase(portfolioRepository),
    getPortfolioSummaryUseCase: GetPortfolioSummaryUseCase(portfolioRepository),
    getCurrentPricesUseCase: GetCurrentPricesUseCase(pricingRepository),
    ref: ref,
  );

  // Listen for auth state changes to reload portfolio
  ref.listen(isAuthenticatedProvider, (previous, next) {
    if (next) {
      notifier.loadPortfolio();
    } else {
      notifier.reset();
    }
  }, fireImmediately: true);

  return notifier;
});

/// Provider for filtered assets (e.g. only gold)
final goldAssetsProvider = Provider<List<MetalAsset>>((ref) {
  final assets = ref.watch(portfolioProvider).assets;
  return assets.where((a) => a.metalType.apiValue == 'GOLD').toList();
});

/// Provider for filtered assets (e.g. only silver)
final silverAssetsProvider = Provider<List<MetalAsset>>((ref) {
  final assets = ref.watch(portfolioProvider).assets;
  return assets.where((a) => a.metalType.apiValue == 'SILVER').toList();
});
