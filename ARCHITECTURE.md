# LumbungEmas - Production Architecture Documentation

## 📋 Table of Contents
1. [System Overview](#system-overview)
2. [Architecture Pattern](#architecture-pattern)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Data Flow](#data-flow)
6. [Database Schema](#database-schema)
7. [Security Considerations](#security-considerations)
8. [Performance Optimization](#performance-optimization)
9. [Scalability Strategy](#scalability-strategy)

---

## 1. System Overview

**LumbungEmas** is a production-ready mobile application for managing personal precious metal (gold and silver) portfolio with real-time profit/loss tracking, analytics, and Google Sheets integration.

### Core Capabilities
- Multi-brand precious metal portfolio management
- Real-time profit/loss calculation
- Daily price tracking and history
- Advanced analytics with charts
- Google Sheets as primary database
- Firebase Authentication (Google Sign-In)
- Offline-first architecture with sync
- Export reports to PDF

---

## 2. Architecture Pattern

### Clean Architecture + MVVM

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Screens    │  │  ViewModels  │  │   Widgets    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Entities   │  │  Use Cases   │  │ Repositories │  │
│  │              │  │              │  │ (Interfaces) │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Models     │  │ Repositories │  │ Data Sources │  │
│  │              │  │ (Impl)       │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐                    │
│  │ Google Sheets│  │ Local Cache  │                    │
│  │   Service    │  │  (SQLite)    │                    │
│  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### Presentation Layer
- **Screens**: UI components and user interactions
- **ViewModels**: State management using Riverpod
- **Widgets**: Reusable UI components

#### Domain Layer
- **Entities**: Core business models (pure Dart objects)
- **Use Cases**: Business logic operations
- **Repository Interfaces**: Abstract contracts for data operations

#### Data Layer
- **Models**: Data transfer objects with JSON serialization
- **Repository Implementations**: Concrete data operations
- **Data Sources**: 
  - Remote: Google Sheets API
  - Local: SQLite for caching

---

## 3. Technology Stack

### Frontend Framework
- **Flutter**: 3.10.7+ (latest stable)
- **Dart**: 3.10.7+
- **Material 3**: Modern design system

### State Management
- **Riverpod**: 2.5.0+ (Recommended for scalability)
  - Provider pattern
  - Dependency injection
  - Immutable state
  - Testing support

### Authentication
- **Firebase Auth**: 4.15.0+
- **Google Sign-In**: 6.2.2+

### Database & Storage
- **Primary**: Google Sheets API (googleapis: 13.2.0+)
- **Cache**: SQLite (sqflite: 2.4.0+)
- **Local Preferences**: shared_preferences: 2.5.4+

### Additional Packages
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  
  # Google Services
  google_sign_in: ^6.2.2
  googleapis: ^13.2.0
  googleapis_auth: ^1.5.0
  
  # Database
  sqflite: ^2.4.0
  
  # Networking
  http: ^1.3.0
  dio: ^5.4.0 # For advanced HTTP features
  
  # Charts & Analytics
  fl_chart: ^0.70.2
  syncfusion_flutter_charts: ^24.1.41
  
  # PDF Generation
  pdf: ^3.11.3
  printing: ^5.14.2
  
  # Utilities
  intl: ^0.20.2 # Currency formatting
  freezed: ^2.4.6 # Immutable models
  json_annotation: ^4.8.1
  equatable: ^2.0.5
  
  # UI
  google_fonts: ^7.0.1
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.7
  freezed_annotation: ^2.4.1
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  
  # Testing
  mockito: ^5.4.4
  flutter_test:
    sdk: flutter
```

---

## 4. Project Structure

```
lumbungemas/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   └── route_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   ├── utils/
│   │   │   ├── currency_formatter.dart
│   │   │   ├── date_formatter.dart
│   │   │   ├── validators.dart
│   │   │   └── logger.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   └── network/
│   │       ├── network_info.dart
│   │       └── api_client.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in_with_google.dart
│   │   │   │       ├── sign_out.dart
│   │   │   │       └── get_current_user.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── splash_screen.dart
│   │   │       │   └── login_screen.dart
│   │   │       └── widgets/
│   │   │           └── google_sign_in_button.dart
│   │   │
│   │   ├── portfolio/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── metal_asset.dart
│   │   │   │   │   ├── brand.dart
│   │   │   │   │   └── portfolio_summary.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── portfolio_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_portfolio.dart
│   │   │   │       ├── add_transaction.dart
│   │   │   │       ├── update_transaction.dart
│   │   │   │       ├── delete_transaction.dart
│   │   │   │       └── calculate_profit_loss.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── metal_asset_model.dart
│   │   │   │   │   ├── brand_model.dart
│   │   │   │   │   └── transaction_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── portfolio_remote_datasource.dart
│   │   │   │   │   └── portfolio_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── portfolio_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── portfolio_provider.dart
│   │   │       │   └── portfolio_state.dart
│   │   │       ├── screens/
│   │   │       │   ├── dashboard_screen.dart
│   │   │       │   ├── add_transaction_screen.dart
│   │   │       │   └── portfolio_detail_screen.dart
│   │   │       └── widgets/
│   │   │           ├── portfolio_card.dart
│   │   │           ├── asset_item.dart
│   │   │           └── profit_loss_indicator.dart
│   │   │
│   │   ├── pricing/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── daily_price.dart
│   │   │   │   │   └── price_history.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── pricing_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_current_prices.dart
│   │   │   │       ├── update_price.dart
│   │   │   │       └── get_price_history.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── daily_price_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── pricing_remote_datasource.dart
│   │   │   │   │   └── pricing_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── pricing_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── pricing_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── price_management_screen.dart
│   │   │       └── widgets/
│   │   │           ├── price_input_form.dart
│   │   │           └── price_history_chart.dart
│   │   │
│   │   ├── analytics/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── analytics_data.dart
│   │   │   │   │   └── performance_metrics.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── analytics_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_portfolio_analytics.dart
│   │   │   │       ├── get_asset_allocation.dart
│   │   │   │       └── compare_metal_performance.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── analytics_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── analytics_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── analytics_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── analytics_screen.dart
│   │   │       └── widgets/
│   │   │           ├── portfolio_pie_chart.dart
│   │   │           ├── performance_line_chart.dart
│   │   │           └── comparison_bar_chart.dart
│   │   │
│   │   └── settings/
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── app_settings.dart
│   │       │   └── repositories/
│   │       │       └── settings_repository.dart
│   │       ├── data/
│   │       │   ├── models/
│   │       │   │   └── settings_model.dart
│   │       │   └── repositories/
│   │       │       └── settings_repository_impl.dart
│   │       └── presentation/
│   │           ├── providers/
│   │           │   └── settings_provider.dart
│   │           ├── screens/
│   │           │   └── settings_screen.dart
│   │           └── widgets/
│   │               └── settings_tile.dart
│   │
│   └── shared/
│       ├── data/
│       │   ├── services/
│       │   │   ├── google_sheets_service.dart
│       │   │   ├── local_database_service.dart
│       │   │   ├── notification_service.dart
│       │   │   └── pdf_export_service.dart
│       │   └── providers/
│       │       └── dependency_injection.dart
│       └── widgets/
│           ├── custom_app_bar.dart
│           ├── loading_indicator.dart
│           ├── error_widget.dart
│           └── empty_state_widget.dart
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
└── assets/
    ├── images/
    ├── icons/
    └── fonts/
```

---

## 5. Data Flow

### Authentication Flow
```
User Action (Login)
    ↓
LoginScreen → AuthProvider
    ↓
SignInWithGoogleUseCase
    ↓
AuthRepository (Interface)
    ↓
AuthRepositoryImpl
    ↓
AuthRemoteDataSource (Firebase)
    ↓
Google Sign-In → Firebase Auth
    ↓
User Entity ← AuthProvider
    ↓
Navigate to Dashboard
```

### Portfolio Data Flow
```
App Launch
    ↓
Check Local Cache (SQLite)
    ↓
Display Cached Data (Offline-first)
    ↓
Sync with Google Sheets (Background)
    ↓
Update Local Cache
    ↓
Notify UI (Riverpod)
    ↓
Refresh Display
```

### Transaction Flow
```
User Adds Transaction
    ↓
AddTransactionScreen → Form Validation
    ↓
AddTransactionUseCase
    ↓
PortfolioRepository
    ↓
1. Save to Local Cache (Immediate)
2. Queue for Sync
    ↓
Background Sync Worker
    ↓
Google Sheets API
    ↓
Update Success → Mark Synced
```

---

## 6. Database Schema

### Google Sheets Structure

#### Sheet 1: Users
```
| user_id | email | display_name | photo_url | created_at | last_login |
|---------|-------|--------------|-----------|------------|------------|
| STRING  | STRING| STRING       | STRING    | TIMESTAMP  | TIMESTAMP  |
```

#### Sheet 2: Transactions
```
| transaction_id | user_id | brand | metal_type | weight_gram | purchase_price_per_gram | total_purchase_value | purchase_date | notes | created_at | updated_at | is_deleted |
|----------------|---------|-------|------------|-------------|-------------------------|----------------------|---------------|-------|------------|------------|------------|
| STRING (UUID)  | STRING  | STRING| ENUM       | DECIMAL     | DECIMAL                 | DECIMAL              | DATE          | STRING| TIMESTAMP  | TIMESTAMP  | BOOLEAN    |
```

**Columns:**
- `transaction_id`: Primary key (UUID)
- `user_id`: Foreign key to Users
- `brand`: Antam, UBS, EmasKu, Pegadaian, Custom
- `metal_type`: GOLD or SILVER
- `weight_gram`: Decimal (e.g., 1.5, 2.0, 5.0)
- `purchase_price_per_gram`: IDR amount
- `total_purchase_value`: Calculated field
- `purchase_date`: Date of purchase
- `notes`: Optional user notes
- `created_at`: Record creation timestamp
- `updated_at`: Last update timestamp
- `is_deleted`: Soft delete flag

#### Sheet 3: Daily_Prices
```
| price_id | brand | metal_type | buy_price | sell_price | price_date | created_at | updated_by |
|----------|-------|------------|-----------|------------|------------|------------|------------|
| STRING   | STRING| ENUM       | DECIMAL   | DECIMAL    | DATE       | TIMESTAMP  | STRING     |
```

**Columns:**
- `price_id`: Primary key (UUID)
- `brand`: Brand name
- `metal_type`: GOLD or SILVER
- `buy_price`: Current buy price per gram (IDR)
- `sell_price`: Current sell/buyback price per gram (IDR)
- `price_date`: Date of price (unique per brand+metal+date)
- `created_at`: Timestamp
- `updated_by`: User ID who updated

#### Sheet 4: Portfolio_Summary (Calculated View)
```
| user_id | total_assets_value | total_invested | total_profit_loss | profit_loss_percentage | gold_value | silver_value | last_calculated |
|---------|-------------------|----------------|-------------------|------------------------|------------|--------------|-----------------|
| STRING  | DECIMAL           | DECIMAL        | DECIMAL           | DECIMAL                | DECIMAL    | DECIMAL      | TIMESTAMP       |
```

### SQLite Local Cache Schema

```sql
-- Users Table
CREATE TABLE users (
    user_id TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    display_name TEXT,
    photo_url TEXT,
    created_at INTEGER,
    last_login INTEGER,
    synced_at INTEGER
);

-- Transactions Table
CREATE TABLE transactions (
    transaction_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    brand TEXT NOT NULL,
    metal_type TEXT NOT NULL CHECK(metal_type IN ('GOLD', 'SILVER')),
    weight_gram REAL NOT NULL,
    purchase_price_per_gram REAL NOT NULL,
    total_purchase_value REAL NOT NULL,
    purchase_date INTEGER NOT NULL,
    notes TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    is_synced INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Daily Prices Table
CREATE TABLE daily_prices (
    price_id TEXT PRIMARY KEY,
    brand TEXT NOT NULL,
    metal_type TEXT NOT NULL CHECK(metal_type IN ('GOLD', 'SILVER')),
    buy_price REAL NOT NULL,
    sell_price REAL NOT NULL,
    price_date INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_by TEXT,
    is_synced INTEGER DEFAULT 0,
    UNIQUE(brand, metal_type, price_date)
);

-- Sync Queue Table
CREATE TABLE sync_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    operation TEXT NOT NULL CHECK(operation IN ('INSERT', 'UPDATE', 'DELETE')),
    payload TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    retry_count INTEGER DEFAULT 0,
    last_error TEXT
);

-- Indexes
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_purchase_date ON transactions(purchase_date DESC);
CREATE INDEX idx_daily_prices_date ON daily_prices(price_date DESC);
CREATE INDEX idx_sync_queue_created ON sync_queue(created_at);
```

---

## 7. Security Considerations

### Authentication Security
1. **Firebase Auth Rules**
   - Only authenticated users can access data
   - Users can only access their own data
   
2. **Google Sheets API**
   - OAuth 2.0 authentication
   - Scoped access (read/write only to specific sheets)
   - Service account for backend operations

3. **Secure Storage**
   ```dart
   // Store sensitive tokens
   final secureStorage = FlutterSecureStorage();
   await secureStorage.write(key: 'refresh_token', value: token);
   ```

### Data Validation
```dart
class TransactionValidator {
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'Weight must be greater than 0';
    }
    if (weight > 1000) {
      return 'Weight seems unrealistic';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }
}
```

### Network Security
```dart
class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  ApiClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final token = await _getAuthToken();
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token refresh
          if (error.response?.statusCode == 401) {
            await _refreshToken();
            return handler.resolve(await _retry(error.requestOptions));
          }
          return handler.next(error);
        },
      ),
    );
  }
}
```

---

## 8. Performance Optimization

### 1. Offline-First Architecture
```dart
class PortfolioRepositoryImpl implements PortfolioRepository {
  @override
  Future<Either<Failure, List<MetalAsset>>> getPortfolio(String userId) async {
    try {
      // 1. Return cached data immediately
      final cachedData = await _localDataSource.getPortfolio(userId);
      
      // 2. Sync in background
      _syncInBackground(userId);
      
      return Right(cachedData.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  Future<void> _syncInBackground(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteData = await _remoteDataSource.getPortfolio(userId);
        await _localDataSource.cachePortfolio(remoteData);
      } catch (e) {
        // Log error but don't fail the operation
        logger.error('Background sync failed', e);
      }
    }
  }
}
```

### 2. Pagination & Lazy Loading
```dart
class TransactionListProvider extends StateNotifier<AsyncValue<List<Transaction>>> {
  final int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;

  Future<void> loadMore() async {
    if (!_hasMore) return;
    
    state = const AsyncValue.loading();
    
    final result = await _repository.getTransactions(
      page: _currentPage,
      pageSize: _pageSize,
    );
    
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (newTransactions) {
        _hasMore = newTransactions.length == _pageSize;
        _currentPage++;
        
        final currentList = state.value ?? [];
        state = AsyncValue.data([...currentList, ...newTransactions]);
      },
    );
  }
}
```

### 3. Caching Strategy
```dart
class CacheManager {
  static const Duration _cacheValidity = Duration(hours: 1);
  
  Future<T?> getCached<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(key);
    final cachedTime = prefs.getInt('${key}_time');
    
    if (cachedData != null && cachedTime != null) {
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTime;
      if (cacheAge < _cacheValidity.inMilliseconds) {
        return jsonDecode(cachedData) as T;
      }
    }
    return null;
  }
  
  Future<void> cache<T>(String key, T data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
    await prefs.setInt('${key}_time', DateTime.now().millisecondsSinceEpoch);
  }
}
```

### 4. Optimized Google Sheets Queries
```dart
class GoogleSheetsService {
  // Batch read operations
  Future<List<List<Object?>>> batchRead(List<String> ranges) async {
    final response = await _sheetsApi.spreadsheets.values.batchGet(
      _spreadsheetId,
      ranges: ranges,
      majorDimension: 'ROWS',
    );
    return response.valueRanges?.map((vr) => vr.values ?? []).toList() ?? [];
  }

  // Batch write operations
  Future<void> batchWrite(Map<String, List<List<Object?>>> updates) async {
    final requests = updates.entries.map((entry) {
      return ValueRange.fromJson({
        'range': entry.key,
        'values': entry.value,
      });
    }).toList();

    await _sheetsApi.spreadsheets.values.batchUpdate(
      BatchUpdateValuesRequest(
        data: requests,
        valueInputOption: 'USER_ENTERED',
      ),
      _spreadsheetId,
    );
  }
}
```

---

## 9. Scalability Strategy

### Phase 1: Current Architecture (Google Sheets)
- **Capacity**: Up to 1000 transactions
- **Users**: Single user
- **Performance**: Acceptable for personal use

### Phase 2: Multi-User Support
```dart
// Abstract repository interface allows easy migration
abstract class PortfolioRepository {
  Future<Either<Failure, List<MetalAsset>>> getPortfolio(String userId);
  Future<Either<Failure, void>> addTransaction(Transaction transaction);
}

// Current implementation
class GoogleSheetsPortfolioRepository implements PortfolioRepository {
  // Google Sheets logic
}

// Future implementation
class FirestorePortfolioRepository implements PortfolioRepository {
  // Firestore logic
}
```

### Phase 3: Migration to Firestore
```dart
// Dependency injection makes migration seamless
final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  final useFirestore = ref.watch(featureFlagProvider('use_firestore'));
  
  if (useFirestore) {
    return FirestorePortfolioRepository(
      firestore: ref.watch(firestoreProvider),
    );
  }
  
  return GoogleSheetsPortfolioRepository(
    sheetsService: ref.watch(googleSheetsServiceProvider),
  );
});
```

### Phase 4: Backend API
```dart
// REST API implementation
class ApiPortfolioRepository implements PortfolioRepository {
  final ApiClient _apiClient;
  
  @override
  Future<Either<Failure, List<MetalAsset>>> getPortfolio(String userId) async {
    try {
      final response = await _apiClient.get('/api/v1/portfolio/$userId');
      final assets = (response.data as List)
          .map((json) => MetalAssetModel.fromJson(json).toEntity())
          .toList();
      return Right(assets);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
```

### Database Migration Path
```
Google Sheets (Current)
    ↓
Cloud Firestore (Phase 2)
    ↓
PostgreSQL + REST API (Phase 3)
    ↓
Microservices Architecture (Phase 4)
```

### Feature Flags
```dart
class FeatureFlags {
  static const bool enableFirestore = false;
  static const bool enablePushNotifications = true;
  static const bool enableAdvancedAnalytics = true;
  static const bool enablePriceAlerts = true;
}
```

---

## 10. Testing Strategy

### Unit Tests
```dart
void main() {
  group('CalculateProfitLoss UseCase', () {
    late CalculateProfitLoss useCase;
    late MockPortfolioRepository mockRepository;

    setUp(() {
      mockRepository = MockPortfolioRepository();
      useCase = CalculateProfitLoss(mockRepository);
    });

    test('should calculate correct profit when current price is higher', () async {
      // Arrange
      final asset = MetalAsset(
        purchasePrice: 1000000,
        currentPrice: 1100000,
        weight: 1.0,
      );

      // Act
      final result = useCase.calculate(asset);

      // Assert
      expect(result.profitLoss, 100000);
      expect(result.profitLossPercentage, 10.0);
    });
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('Portfolio card displays correct profit/loss', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PortfolioCard(
          asset: testAsset,
        ),
      ),
    );

    expect(find.text('Rp 100.000'), findsOneWidget);
    expect(find.text('+10%'), findsOneWidget);
  });
}
```

### Integration Tests
```dart
void main() {
  group('Portfolio Flow', () {
    testWidgets('Complete add transaction flow', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // Navigate to add transaction
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Fill form
      await tester.enterText(find.byKey(Key('weight')), '1.5');
      await tester.enterText(find.byKey(Key('price')), '1000000');
      
      // Submit
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // Verify
      expect(find.text('Transaction added'), findsOneWidget);
    });
  });
}
```

---

## 11. Error Handling

### Failure Classes
```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
```

### Error Handling in UI
```dart
class PortfolioScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioProvider);
    
    return portfolioState.when(
      data: (portfolio) => PortfolioList(portfolio: portfolio),
      loading: () => const LoadingIndicator(),
      error: (error, stack) {
        if (error is NetworkFailure) {
          return ErrorWidget(
            message: 'No internet connection',
            onRetry: () => ref.refresh(portfolioProvider),
          );
        }
        return ErrorWidget(
          message: 'Something went wrong',
          onRetry: () => ref.refresh(portfolioProvider),
        );
      },
    );
  }
}
```

---

## Conclusion

This architecture provides:
- ✅ **Scalability**: Easy migration from Google Sheets to Firestore/PostgreSQL
- ✅ **Maintainability**: Clean separation of concerns
- ✅ **Testability**: Dependency injection and interface-based design
- ✅ **Performance**: Offline-first with background sync
- ✅ **Security**: Firebase Auth + secure data handling
- ✅ **Production-Ready**: Error handling, validation, logging

The implementation follows SOLID principles and enterprise-grade standards while remaining flexible for future enhancements.
