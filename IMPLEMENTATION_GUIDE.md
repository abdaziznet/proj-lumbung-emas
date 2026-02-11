# LumbungEmas Implementation Guide

## 📚 Table of Contents
1. [Quick Start](#quick-start)
2. [Google Sheets Setup](#google-sheets-setup)
3. [Firebase Setup](#firebase-setup)
4. [Repository Pattern Implementation](#repository-pattern-implementation)
5. [State Management with Riverpod](#state-management-with-riverpod)
6. [Calculation Engine](#calculation-engine)
7. [UI Implementation Examples](#ui-implementation-examples)
8. [Testing Guide](#testing-guide)

---

## 1. Quick Start

### Prerequisites
- Flutter SDK 3.10.7+
- Android Studio / VS Code
- Google Cloud Platform account
- Firebase account

### Installation Steps

```bash
# Navigate to project directory
cd d:/05-Labs/01-flutter/lumbungemas

# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

---

## 2. Google Sheets Setup

### Step 1: Create a New Spreadsheet

1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new spreadsheet named "LumbungEmas Database"
3. Note the Spreadsheet ID from the URL:
   ```
   https://docs.google.com/spreadsheets/d/[SPREADSHEET_ID]/edit
   ```

### Step 2: Create Required Sheets

Create 4 sheets with the following structures:

#### Sheet 1: Users
| user_id | email | display_name | photo_url | created_at | last_login |
|---------|-------|--------------|-----------|------------|------------|

**Header Row (Row 1):**
```
user_id | email | display_name | photo_url | created_at | last_login
```

#### Sheet 2: Transactions
| transaction_id | user_id | brand | metal_type | weight_gram | purchase_price_per_gram | total_purchase_value | purchase_date | notes | created_at | updated_at | is_deleted |
|----------------|---------|-------|------------|-------------|-------------------------|----------------------|---------------|-------|------------|------------|------------|

**Header Row (Row 1):**
```
transaction_id | user_id | brand | metal_type | weight_gram | purchase_price_per_gram | total_purchase_value | purchase_date | notes | created_at | updated_at | is_deleted
```

#### Sheet 3: Daily_Prices
| price_id | brand | metal_type | buy_price | sell_price | price_date | created_at | updated_by |
|----------|-------|------------|-----------|------------|------------|------------|------------|

**Header Row (Row 1):**
```
price_id | brand | metal_type | buy_price | sell_price | price_date | created_at | updated_by
```

#### Sheet 4: Portfolio_Summary
| user_id | total_assets_value | total_invested | total_profit_loss | profit_loss_percentage | gold_value | silver_value | last_calculated |
|---------|-------------------|----------------|-------------------|------------------------|------------|--------------|-----------------|

**Header Row (Row 1):**
```
user_id | total_assets_value | total_invested | total_profit_loss | profit_loss_percentage | gold_value | silver_value | last_calculated
```

### Step 3: Configure Spreadsheet ID

Update `lib/core/constants/app_constants.dart`:

```dart
static const String spreadsheetId = 'YOUR_ACTUAL_SPREADSHEET_ID';
```

### Step 4: Set Permissions

1. Click "Share" button in Google Sheets
2. Set to "Anyone with the link can edit" (for development)
3. For production, use service account authentication

---

## 3. Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Name it "LumbungEmas"
4. Enable Google Analytics (optional)

### Step 2: Add Android App

1. Click "Add app" → Android
2. Package name: `com.lumbungemas.lumbungemas`
3. Download `google-services.json`
4. Place in `android/app/`

### Step 3: Enable Authentication

1. Go to Authentication → Sign-in method
2. Enable "Google" provider
3. Add your SHA-1 fingerprint:

```bash
# Get debug SHA-1
cd android
./gradlew signingReport
```

### Step 4: Update Android Configuration

**android/app/build.gradle:**
```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
}
```

**android/build.gradle:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle (bottom):**
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 5: Initialize Firebase

Create `lib/core/firebase_config.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
}
```

---

## 4. Repository Pattern Implementation

### Example: Portfolio Repository

**Interface (Domain Layer):**

```dart
// lib/features/portfolio/domain/repositories/portfolio_repository.dart

import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/portfolio_summary.dart';

abstract class PortfolioRepository {
  /// Get all portfolio assets for a user
  Future<Either<Failure, List<MetalAsset>>> getPortfolio(String userId);

  /// Get portfolio summary with calculations
  Future<Either<Failure, PortfolioSummary>> getPortfolioSummary(String userId);

  /// Add a new transaction
  Future<Either<Failure, void>> addTransaction(MetalAsset asset);

  /// Update existing transaction
  Future<Either<Failure, void>> updateTransaction(MetalAsset asset);

  /// Delete transaction (soft delete)
  Future<Either<Failure, void>> deleteTransaction(String transactionId);

  /// Sync local data with remote
  Future<Either<Failure, void>> syncPortfolio(String userId);
}
```

**Implementation (Data Layer):**

```dart
// lib/features/portfolio/data/repositories/portfolio_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:lumbungemas/core/errors/exceptions.dart';
import 'package:lumbungemas/core/errors/failures.dart';
import 'package:lumbungemas/core/network/network_info.dart';
import 'package:lumbungemas/features/portfolio/data/datasources/portfolio_local_datasource.dart';
import 'package:lumbungemas/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource remoteDataSource;
  final PortfolioLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PortfolioRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MetalAsset>>> getPortfolio(String userId) async {
    try {
      // 1. Return cached data immediately (offline-first)
      final cachedAssets = await localDataSource.getCachedPortfolio(userId);
      
      // 2. Sync in background if connected
      if (await networkInfo.isConnected) {
        _syncInBackground(userId);
      }

      return Right(cachedAssets.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      // If cache fails, try remote
      if (await networkInfo.isConnected) {
        try {
          final remoteAssets = await remoteDataSource.getPortfolio(userId);
          await localDataSource.cachePortfolio(remoteAssets);
          return Right(remoteAssets.map((model) => model.toEntity()).toList());
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      }
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(MetalAsset asset) async {
    try {
      // 1. Save to local cache immediately
      final model = MetalAssetModel.fromEntity(asset);
      await localDataSource.addTransaction(model);

      // 2. Sync to remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.addTransaction(model);
          await localDataSource.markAsSynced(asset.transactionId);
        } on ServerException {
          // Queue for later sync
          await localDataSource.queueForSync(asset.transactionId);
        }
      } else {
        // Queue for sync when online
        await localDataSource.queueForSync(asset.transactionId);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PortfolioSummary>> getPortfolioSummary(
    String userId,
  ) async {
    try {
      final assets = await getPortfolio(userId);
      
      return assets.fold(
        (failure) => Left(failure),
        (assetList) async {
          // Calculate summary from assets
          final summary = _calculateSummary(userId, assetList);
          return Right(summary);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<void> _syncInBackground(String userId) async {
    try {
      final remoteAssets = await remoteDataSource.getPortfolio(userId);
      await localDataSource.cachePortfolio(remoteAssets);
    } catch (e) {
      // Silent fail for background sync
    }
  }

  PortfolioSummary _calculateSummary(
    String userId,
    List<MetalAsset> assets,
  ) {
    double totalInvested = 0;
    double totalCurrentValue = 0;
    double goldValue = 0;
    double silverValue = 0;

    for (final asset in assets) {
      if (asset.isDeleted) continue;

      totalInvested += asset.totalPurchaseValue;
      totalCurrentValue += asset.currentMarketValue ?? asset.totalPurchaseValue;

      if (asset.metalType == MetalType.gold) {
        goldValue += asset.currentMarketValue ?? asset.totalPurchaseValue;
      } else {
        silverValue += asset.currentMarketValue ?? asset.totalPurchaseValue;
      }
    }

    final profitLoss = totalCurrentValue - totalInvested;
    final profitLossPercentage = totalInvested > 0
        ? (profitLoss / totalInvested) * 100
        : 0;

    return PortfolioSummary(
      userId: userId,
      totalAssetsValue: totalCurrentValue,
      totalInvested: totalInvested,
      totalProfitLoss: profitLoss,
      profitLossPercentage: profitLossPercentage,
      goldValue: goldValue,
      silverValue: silverValue,
      totalTransactions: assets.where((a) => !a.isDeleted).length,
      lastCalculated: DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, void>> updateTransaction(MetalAsset asset) async {
    // Implementation similar to addTransaction
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    // Implementation with soft delete
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> syncPortfolio(String userId) async {
    // Manual sync implementation
    throw UnimplementedError();
  }
}
```

---

## 5. State Management with Riverpod

### Provider Setup

```dart
// lib/features/portfolio/presentation/providers/portfolio_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';

// Portfolio state
class PortfolioState {
  final List<MetalAsset> assets;
  final PortfolioSummary? summary;
  final bool isLoading;
  final String? error;

  const PortfolioState({
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
      error: error,
    );
  }
}

// Portfolio notifier
class PortfolioNotifier extends StateNotifier<PortfolioState> {
  final PortfolioRepository _repository;

  PortfolioNotifier(this._repository) : super(const PortfolioState());

  Future<void> loadPortfolio(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getPortfolio(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (assets) async {
        // Get summary
        final summaryResult = await _repository.getPortfolioSummary(userId);
        
        summaryResult.fold(
          (failure) {
            state = state.copyWith(
              assets: assets,
              isLoading: false,
              error: failure.message,
            );
          },
          (summary) {
            state = state.copyWith(
              assets: assets,
              summary: summary,
              isLoading: false,
            );
          },
        );
      },
    );
  }

  Future<void> addTransaction(MetalAsset asset) async {
    final result = await _repository.addTransaction(asset);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Reload portfolio
        loadPortfolio(asset.userId);
      },
    );
  }
}

// Provider
final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return PortfolioNotifier(repository);
});
```

---

## 6. Calculation Engine

### Profit/Loss Calculator

```dart
// lib/features/portfolio/domain/usecases/calculate_profit_loss.dart

import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';

class ProfitLossCalculator {
  /// Calculate profit/loss for a single asset
  static MetalAsset calculateForAsset(
    MetalAsset asset,
    double currentPricePerGram,
  ) {
    final currentMarketValue = asset.weightGram * currentPricePerGram;
    final profitLoss = currentMarketValue - asset.totalPurchaseValue;
    final profitLossPercentage =
        (profitLoss / asset.totalPurchaseValue) * 100;

    return asset.copyWith(
      currentPricePerGram: currentPricePerGram,
      currentMarketValue: currentMarketValue,
      profitLoss: profitLoss,
      profitLossPercentage: profitLossPercentage,
    );
  }

  /// Calculate total profit/loss for multiple assets
  static Map<String, double> calculateTotal(List<MetalAsset> assets) {
    double totalInvested = 0;
    double totalCurrentValue = 0;

    for (final asset in assets) {
      if (asset.isDeleted) continue;
      totalInvested += asset.totalPurchaseValue;
      totalCurrentValue += asset.currentMarketValue ?? asset.totalPurchaseValue;
    }

    final profitLoss = totalCurrentValue - totalInvested;
    final profitLossPercentage =
        totalInvested > 0 ? (profitLoss / totalInvested) * 100 : 0;

    return {
      'totalInvested': totalInvested,
      'totalCurrentValue': totalCurrentValue,
      'profitLoss': profitLoss,
      'profitLossPercentage': profitLossPercentage,
    };
  }

  /// Calculate ROI (Return on Investment)
  static double calculateROI(double invested, double currentValue) {
    if (invested == 0) return 0;
    return ((currentValue - invested) / invested) * 100;
  }

  /// Calculate average purchase price
  static double calculateAveragePurchasePrice(List<MetalAsset> assets) {
    if (assets.isEmpty) return 0;

    double totalWeight = 0;
    double totalValue = 0;

    for (final asset in assets) {
      if (asset.isDeleted) continue;
      totalWeight += asset.weightGram;
      totalValue += asset.totalPurchaseValue;
    }

    return totalWeight > 0 ? totalValue / totalWeight : 0;
  }
}
```

---

## 7. UI Implementation Examples

### Dashboard Screen

```dart
// lib/features/portfolio/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/utils/currency_formatter.dart';
import 'package:lumbungemas/features/portfolio/presentation/providers/portfolio_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load portfolio on init
    Future.microtask(() {
      final userId = ref.read(currentUserProvider)?.userId;
      if (userId != null) {
        ref.read(portfolioProvider.notifier).loadPortfolio(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LumbungEmas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final userId = ref.read(currentUserProvider)?.userId;
              if (userId != null) {
                ref.read(portfolioProvider.notifier).loadPortfolio(userId);
              }
            },
          ),
        ],
      ),
      body: portfolioState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : portfolioState.error != null
              ? Center(child: Text('Error: ${portfolioState.error}'))
              : RefreshIndicator(
                  onRefresh: () async {
                    final userId = ref.read(currentUserProvider)?.userId;
                    if (userId != null) {
                      await ref
                          .read(portfolioProvider.notifier)
                          .loadPortfolio(userId);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(portfolioState.summary),
                        const SizedBox(height: 24),
                        _buildAssetsList(portfolioState.assets),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(PortfolioSummary? summary) {
    if (summary == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data available'),
        ),
      );
    }

    final isProfitable = summary.isProfitable;
    final profitColor = isProfitable ? Colors.green : Colors.red;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Portfolio Value',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(summary.totalAssetsValue),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invested',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      CurrencyFormatter.format(summary.totalInvested),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Profit/Loss',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      CurrencyFormatter.formatProfitLoss(
                        summary.totalProfitLoss,
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: profitColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      CurrencyFormatter.formatPercentage(
                        summary.profitLossPercentage,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: profitColor,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsList(List<MetalAsset> assets) {
    if (assets.isEmpty) {
      return const Center(
        child: Text('No assets yet. Add your first transaction!'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Assets',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            if (asset.isDeleted) return const SizedBox.shrink();
            
            return _buildAssetCard(asset);
          },
        ),
      ],
    );
  }

  Widget _buildAssetCard(MetalAsset asset) {
    final isProfitable = asset.isProfitable;
    final profitColor = isProfitable ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: asset.metalType == MetalType.gold
              ? Colors.amber
              : Colors.grey,
          child: Icon(
            asset.metalType == MetalType.gold
                ? Icons.stars
                : Icons.circle,
            color: Colors.white,
          ),
        ),
        title: Text('${asset.brand} - ${asset.metalType.displayName}'),
        subtitle: Text(
          '${CurrencyFormatter.formatWeight(asset.weightGram)} • ${DateFormatter.formatDate(asset.purchaseDate)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(
                asset.currentMarketValue ?? asset.totalPurchaseValue,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (asset.profitLoss != null)
              Text(
                CurrencyFormatter.formatProfitLoss(asset.profitLoss!),
                style: TextStyle(
                  color: profitColor,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/asset-detail',
            arguments: asset,
          );
        },
      ),
    );
  }
}
```

---

## 8. Testing Guide

### Unit Test Example

```dart
// test/features/portfolio/domain/usecases/calculate_profit_loss_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/domain/usecases/calculate_profit_loss.dart';

void main() {
  group('ProfitLossCalculator', () {
    test('should calculate profit correctly when current price is higher', () {
      // Arrange
      final asset = MetalAsset(
        transactionId: '1',
        userId: 'user1',
        brand: 'Antam',
        metalType: MetalType.gold,
        weightGram: 1.0,
        purchasePricePerGram: 1000000,
        totalPurchaseValue: 1000000,
        purchaseDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = ProfitLossCalculator.calculateForAsset(asset, 1100000);

      // Assert
      expect(result.currentPricePerGram, 1100000);
      expect(result.currentMarketValue, 1100000);
      expect(result.profitLoss, 100000);
      expect(result.profitLossPercentage, 10.0);
    });

    test('should calculate loss correctly when current price is lower', () {
      // Arrange
      final asset = MetalAsset(
        transactionId: '1',
        userId: 'user1',
        brand: 'Antam',
        metalType: MetalType.gold,
        weightGram: 1.0,
        purchasePricePerGram: 1000000,
        totalPurchaseValue: 1000000,
        purchaseDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = ProfitLossCalculator.calculateForAsset(asset, 900000);

      // Assert
      expect(result.profitLoss, -100000);
      expect(result.profitLossPercentage, -10.0);
    });
  });
}
```

---

## Next Steps

1. **Complete Repository Implementations**: Finish all repository implementations for auth, pricing, and analytics
2. **Build UI Screens**: Implement all screens following the dashboard example
3. **Add Charts**: Integrate fl_chart for analytics visualization
4. **Implement Notifications**: Set up price alerts and sync notifications
5. **Add PDF Export**: Implement PDF report generation
6. **Testing**: Write comprehensive tests for all features
7. **Performance Optimization**: Implement caching and optimize API calls
8. **Production Deployment**: Configure release builds and deploy to Play Store

---

## Support & Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Riverpod Documentation**: https://riverpod.dev
- **Google Sheets API**: https://developers.google.com/sheets/api
- **Firebase Documentation**: https://firebase.google.com/docs

---

**Happy Coding! 🚀**
