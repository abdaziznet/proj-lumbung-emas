import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/features/pricing/domain/entities/daily_price.dart';
import 'package:lumbungemas/features/pricing/domain/usecases/get_current_prices.dart';
import 'package:lumbungemas/shared/data/providers/dependency_injection.dart';

/// State for pricing feature
class PricingState {
  final List<DailyPrice> prices;
  final bool isLoading;
  final String? error;

  PricingState({
    this.prices = const [],
    this.isLoading = false,
    this.error,
  });

  PricingState copyWith({
    List<DailyPrice>? prices,
    bool? isLoading,
    String? error,
  }) {
    return PricingState(
      prices: prices ?? this.prices,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get price for specific brand and metal type
  DailyPrice? getPrice(String brand, String metalType) {
    try {
      return prices.firstWhere(
        (p) => p.brand.toUpperCase() == brand.toUpperCase() && 
               p.metalType.apiValue == metalType.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Notifier for pricing feature
class PricingNotifier extends StateNotifier<PricingState> {
  final GetCurrentPricesUseCase _getCurrentPricesUseCase;

  PricingNotifier({
    required GetCurrentPricesUseCase getCurrentPricesUseCase,
  })  : _getCurrentPricesUseCase = getCurrentPricesUseCase,
        super(PricingState()) {
    loadPrices();
  }

  Future<void> loadPrices() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _getCurrentPricesUseCase();
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (prices) => state = state.copyWith(isLoading: false, prices: prices),
    );
  }
}

/// Provider for pricing notifier
final pricingProvider = StateNotifierProvider<PricingNotifier, PricingState>((ref) {
  final repository = ref.watch(pricingRepositoryProvider);
  return PricingNotifier(
    getCurrentPricesUseCase: GetCurrentPricesUseCase(repository),
  );
});

/// Provider for Antam Gold price
final antamGoldPriceProvider = Provider<DailyPrice?>((ref) {
  return ref.watch(pricingProvider).getPrice('Antam', 'GOLD');
});

/// Provider for Antam Silver price
final antamSilverPriceProvider = Provider<DailyPrice?>((ref) {
  return ref.watch(pricingProvider).getPrice('Antam', 'SILVER');
});
