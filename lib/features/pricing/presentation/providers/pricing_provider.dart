import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/features/pricing/domain/entities/daily_price.dart';
import 'package:lumbungemas/features/pricing/domain/usecases/get_current_prices.dart';
import 'package:lumbungemas/features/pricing/domain/usecases/update_price.dart';
import 'package:lumbungemas/shared/data/providers/dependency_injection.dart';
import 'package:uuid/uuid.dart';

/// State for pricing feature
class PricingState {
  final List<DailyPrice> prices;
  final bool isLoading;
  final String? error;

  static const Object _noChange = Object();

  PricingState({
    this.prices = const [],
    this.isLoading = false,
    this.error,
  });

  PricingState copyWith({
    List<DailyPrice>? prices,
    bool? isLoading,
    Object? error = _noChange,
  }) {
    return PricingState(
      prices: prices ?? this.prices,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _noChange) ? this.error : error as String?,
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
  final Ref _ref;

  PricingNotifier({
    required GetCurrentPricesUseCase getCurrentPricesUseCase,
    required Ref ref,
  })  : _getCurrentPricesUseCase = getCurrentPricesUseCase,
        _ref = ref,
        super(PricingState()) {
    loadPrices();
  }

  Future<void> loadPrices() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sheetsService = _ref.read(googleSheetsServiceProvider);
      if (!sheetsService.isInitialized) {
        await sheetsService.authenticateWithServiceAccount();
      }

      final result = await _getCurrentPricesUseCase();
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (prices) => state = state.copyWith(isLoading: false, prices: prices),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat harga: $e',
      );
    }
  }

  Future<bool> updateTodayPrice({
    required String brand,
    required MetalType metalType,
    required double buyPrice,
    required double sellPrice,
    String? updatedBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sheetsService = _ref.read(googleSheetsServiceProvider);
      if (!sheetsService.isInitialized) {
        await sheetsService.authenticateWithServiceAccount();
      }

      final updatePriceUseCase = UpdatePriceUseCase(
        _ref.read(pricingRepositoryProvider),
      );

      final now = DateTime.now();
      final result = await updatePriceUseCase(
        DailyPrice(
          priceId: const Uuid().v4(),
          brand: brand,
          metalType: metalType,
          buyPrice: buyPrice,
          sellPrice: sellPrice,
          priceDate: now,
          createdAt: now,
          updatedBy: updatedBy,
        ),
      );

      var isSuccess = false;
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (_) => isSuccess = true,
      );

      if (isSuccess) {
        await loadPrices();
      }

      return isSuccess;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal menyimpan harga: $e',
      );
      return false;
    }
  }
}

/// Provider for pricing notifier
final pricingProvider = StateNotifierProvider<PricingNotifier, PricingState>((ref) {
  final repository = ref.watch(pricingRepositoryProvider);
  return PricingNotifier(
    getCurrentPricesUseCase: GetCurrentPricesUseCase(repository),
    ref: ref,
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
