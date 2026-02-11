# LumbungEmas - Complete Code Examples

## Repository Implementation Examples

### 1. Portfolio Remote Data Source

```dart
// lib/features/portfolio/data/datasources/portfolio_remote_datasource.dart

import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/core/errors/exceptions.dart';
import 'package:lumbungemas/features/portfolio/data/models/metal_asset_model.dart';
import 'package:lumbungemas/shared/data/services/google_sheets_service.dart';
import 'package:logger/logger.dart';

abstract class PortfolioRemoteDataSource {
  Future<List<MetalAssetModel>> getPortfolio(String userId);
  Future<void> addTransaction(MetalAssetModel asset);
  Future<void> updateTransaction(MetalAssetModel asset);
  Future<void> deleteTransaction(String transactionId);
}

class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  final GoogleSheetsService sheetsService;
  final Logger logger;

  PortfolioRemoteDataSourceImpl({
    required this.sheetsService,
    required this.logger,
  });

  @override
  Future<List<MetalAssetModel>> getPortfolio(String userId) async {
    try {
      // Read all transactions from Google Sheets
      final range = '${AppConstants.transactionsSheetName}!A2:L';
      final rows = await sheetsService.read(range);

      // Filter by user ID and convert to models
      final assets = rows
          .where((row) => row.isNotEmpty && row[1]?.toString() == userId)
          .map((row) => MetalAssetModel.fromSheetRow(row))
          .where((asset) => !asset.isDeleted)
          .toList();

      logger.i('Fetched ${assets.length} assets for user $userId');
      return assets;
    } on SheetsException {
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch portfolio', error: e);
      throw ServerException(
        message: 'Failed to fetch portfolio data',
        details: e,
      );
    }
  }

  @override
  Future<void> addTransaction(MetalAssetModel asset) async {
    try {
      final range = '${AppConstants.transactionsSheetName}!A:L';
      final row = asset.toSheetRow();

      await sheetsService.append(range, [row]);
      logger.i('Added transaction: ${asset.transactionId}');
    } on SheetsException {
      rethrow;
    } catch (e) {
      logger.e('Failed to add transaction', error: e);
      throw ServerException(
        message: 'Failed to add transaction',
        details: e,
      );
    }
  }

  @override
  Future<void> updateTransaction(MetalAssetModel asset) async {
    try {
      // Find the row number
      final rowNumber = await sheetsService.findRowByValue(
        AppConstants.transactionsSheetName,
        0, // transaction_id column
        asset.transactionId,
      );

      if (rowNumber == null) {
        throw NotFoundException(message: 'Transaction not found');
      }

      // Update the row
      await sheetsService.updateRow(
        AppConstants.transactionsSheetName,
        rowNumber,
        asset.toSheetRow(),
      );

      logger.i('Updated transaction: ${asset.transactionId}');
    } on SheetsException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      logger.e('Failed to update transaction', error: e);
      throw ServerException(
        message: 'Failed to update transaction',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      // Find the row number
      final rowNumber = await sheetsService.findRowByValue(
        AppConstants.transactionsSheetName,
        0, // transaction_id column
        transactionId,
      );

      if (rowNumber == null) {
        throw NotFoundException(message: 'Transaction not found');
      }

      // Soft delete by setting is_deleted flag
      await sheetsService.softDeleteRow(
        AppConstants.transactionsSheetName,
        rowNumber,
        11, // is_deleted column index
      );

      logger.i('Deleted transaction: $transactionId');
    } on SheetsException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      logger.e('Failed to delete transaction', error: e);
      throw ServerException(
        message: 'Failed to delete transaction',
        details: e,
      );
    }
  }
}
```

### 2. Portfolio Local Data Source

```dart
// lib/features/portfolio/data/datasources/portfolio_local_datasource.dart

import 'package:sqflite/sqflite.dart';
import 'package:lumbungemas/core/errors/exceptions.dart';
import 'package:lumbungemas/features/portfolio/data/models/metal_asset_model.dart';
import 'package:logger/logger.dart';

abstract class PortfolioLocalDataSource {
  Future<List<MetalAssetModel>> getCachedPortfolio(String userId);
  Future<void> cachePortfolio(List<MetalAssetModel> assets);
  Future<void> addTransaction(MetalAssetModel asset);
  Future<void> updateTransaction(MetalAssetModel asset);
  Future<void> deleteTransaction(String transactionId);
  Future<void> markAsSynced(String transactionId);
  Future<void> queueForSync(String transactionId);
  Future<List<String>> getUnsyncedTransactions();
}

class PortfolioLocalDataSourceImpl implements PortfolioLocalDataSource {
  final Database database;
  final Logger logger;

  PortfolioLocalDataSourceImpl({
    required this.database,
    required this.logger,
  });

  @override
  Future<List<MetalAssetModel>> getCachedPortfolio(String userId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'transactions',
        where: 'user_id = ? AND is_deleted = ?',
        whereArgs: [userId, 0],
        orderBy: 'purchase_date DESC',
      );

      return maps.map((map) => MetalAssetModel.fromJson(map)).toList();
    } catch (e) {
      logger.e('Failed to get cached portfolio', error: e);
      throw CacheException(message: 'Failed to get cached data');
    }
  }

  @override
  Future<void> cachePortfolio(List<MetalAssetModel> assets) async {
    try {
      final batch = database.batch();

      for (final asset in assets) {
        batch.insert(
          'transactions',
          asset.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      logger.i('Cached ${assets.length} transactions');
    } catch (e) {
      logger.e('Failed to cache portfolio', error: e);
      throw CacheException(message: 'Failed to cache data');
    }
  }

  @override
  Future<void> addTransaction(MetalAssetModel asset) async {
    try {
      await database.insert(
        'transactions',
        asset.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      logger.i('Added transaction to local cache: ${asset.transactionId}');
    } catch (e) {
      logger.e('Failed to add transaction to cache', error: e);
      throw CacheException(message: 'Failed to add transaction');
    }
  }

  @override
  Future<void> updateTransaction(MetalAssetModel asset) async {
    try {
      await database.update(
        'transactions',
        asset.toJson(),
        where: 'transaction_id = ?',
        whereArgs: [asset.transactionId],
      );
      logger.i('Updated transaction in cache: ${asset.transactionId}');
    } catch (e) {
      logger.e('Failed to update transaction in cache', error: e);
      throw CacheException(message: 'Failed to update transaction');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await database.update(
        'transactions',
        {'is_deleted': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );
      logger.i('Deleted transaction in cache: $transactionId');
    } catch (e) {
      logger.e('Failed to delete transaction in cache', error: e);
      throw CacheException(message: 'Failed to delete transaction');
    }
  }

  @override
  Future<void> markAsSynced(String transactionId) async {
    try {
      await database.update(
        'transactions',
        {'is_synced': 1},
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );
    } catch (e) {
      logger.e('Failed to mark as synced', error: e);
    }
  }

  @override
  Future<void> queueForSync(String transactionId) async {
    try {
      final transaction = await database.query(
        'transactions',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      if (transaction.isEmpty) return;

      await database.insert(
        'sync_queue',
        {
          'entity_type': 'transaction',
          'entity_id': transactionId,
          'operation': 'INSERT',
          'payload': transaction.first.toString(),
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'retry_count': 0,
        },
      );
      logger.i('Queued transaction for sync: $transactionId');
    } catch (e) {
      logger.e('Failed to queue for sync', error: e);
    }
  }

  @override
  Future<List<String>> getUnsyncedTransactions() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'sync_queue',
        where: 'entity_type = ?',
        whereArgs: ['transaction'],
        orderBy: 'created_at ASC',
      );

      return maps.map((m) => m['entity_id'] as String).toList();
    } catch (e) {
      logger.e('Failed to get unsynced transactions', error: e);
      return [];
    }
  }
}
```

### 3. Pricing Remote Data Source

```dart
// lib/features/pricing/data/datasources/pricing_remote_datasource.dart

import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/core/errors/exceptions.dart';
import 'package:lumbungemas/features/pricing/data/models/daily_price_model.dart';
import 'package:lumbungemas/shared/data/services/google_sheets_service.dart';
import 'package:logger/logger.dart';

abstract class PricingRemoteDataSource {
  Future<List<DailyPriceModel>> getCurrentPrices();
  Future<DailyPriceModel?> getPrice(String brand, MetalType metalType, DateTime date);
  Future<void> updatePrice(DailyPriceModel price);
  Future<List<DailyPriceModel>> getPriceHistory(String brand, MetalType metalType, {int days = 30});
}

class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final GoogleSheetsService sheetsService;
  final Logger logger;

  PricingRemoteDataSourceImpl({
    required this.sheetsService,
    required this.logger,
  });

  @override
  Future<List<DailyPriceModel>> getCurrentPrices() async {
    try {
      final range = '${AppConstants.dailyPricesSheetName}!A2:H';
      final rows = await sheetsService.read(range);

      // Get today's date
      final today = DateTime.now();
      final todayTimestamp = DateTime(today.year, today.month, today.day)
          .millisecondsSinceEpoch;

      // Filter for today's prices
      final prices = rows
          .where((row) => row.isNotEmpty)
          .map((row) => DailyPriceModel.fromSheetRow(row))
          .where((price) {
            final priceDate = DateTime.fromMillisecondsSinceEpoch(price.priceDate);
            final priceDateOnly = DateTime(priceDate.year, priceDate.month, priceDate.day)
                .millisecondsSinceEpoch;
            return priceDateOnly == todayTimestamp;
          })
          .toList();

      logger.i('Fetched ${prices.length} current prices');
      return prices;
    } on SheetsException {
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch current prices', error: e);
      throw ServerException(
        message: 'Failed to fetch current prices',
        details: e,
      );
    }
  }

  @override
  Future<DailyPriceModel?> getPrice(
    String brand,
    MetalType metalType,
    DateTime date,
  ) async {
    try {
      final range = '${AppConstants.dailyPricesSheetName}!A2:H';
      final rows = await sheetsService.read(range);

      final targetDate = DateTime(date.year, date.month, date.day)
          .millisecondsSinceEpoch;

      for (final row in rows) {
        if (row.isEmpty) continue;

        final price = DailyPriceModel.fromSheetRow(row);
        final priceDate = DateTime.fromMillisecondsSinceEpoch(price.priceDate);
        final priceDateOnly = DateTime(priceDate.year, priceDate.month, priceDate.day)
            .millisecondsSinceEpoch;

        if (price.brand == brand &&
            price.metalType == metalType.apiValue &&
            priceDateOnly == targetDate) {
          return price;
        }
      }

      return null;
    } on SheetsException {
      rethrow;
    } catch (e) {
      logger.e('Failed to get price', error: e);
      throw ServerException(
        message: 'Failed to get price',
        details: e,
      );
    }
  }

  @override
  Future<void> updatePrice(DailyPriceModel price) async {
    try {
      // Check if price already exists
      final existingRow = await sheetsService.findRowByValue(
        AppConstants.dailyPricesSheetName,
        0, // price_id column
        price.priceId,
      );

      if (existingRow != null) {
        // Update existing price
        await sheetsService.updateRow(
          AppConstants.dailyPricesSheetName,
          existingRow,
          price.toSheetRow(),
        );
        logger.i('Updated price: ${price.priceId}');
      } else {
        // Add new price
        final range = '${AppConstants.dailyPricesSheetName}!A:H';
        await sheetsService.append(range, [price.toSheetRow()]);
        logger.i('Added new price: ${price.priceId}');
      }
    } on SheetsException {
      rethrow;
    } catch (e) {
      logger.e('Failed to update price', error: e);
      throw ServerException(
        message: 'Failed to update price',
        details: e,
      );
    }
  }

  @override
  Future<List<DailyPriceModel>> getPriceHistory(
    String brand,
    MetalType metalType, {
    int days = 30,
  }) async {
    try {
      final range = '${AppConstants.dailyPricesSheetName}!A2:H';
      final rows = await sheetsService.read(range);

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch;

      final history = rows
          .where((row) => row.isNotEmpty)
          .map((row) => DailyPriceModel.fromSheetRow(row))
          .where((price) =>
              price.brand == brand &&
              price.metalType == metalType.apiValue &&
              price.priceDate >= cutoffTimestamp)
          .toList();

      // Sort by date descending
      history.sort((a, b) => b.priceDate.compareTo(a.priceDate));

      logger.i('Fetched ${history.length} price history records');
      return history;
    } on SheetsException {
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch price history', error: e);
      throw ServerException(
        message: 'Failed to fetch price history',
        details: e,
      );
    }
  }
}
```

### 4. Local Database Service

```dart
// lib/shared/data/services/local_database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;
  final Logger _logger = Logger();

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lumbungemas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    _logger.i('Creating database schema version $version');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        user_id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        display_name TEXT,
        photo_url TEXT,
        created_at INTEGER NOT NULL,
        last_login INTEGER NOT NULL,
        synced_at INTEGER
      )
    ''');

    // Transactions table
    await db.execute('''
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
        current_price_per_gram REAL,
        current_market_value REAL,
        profit_loss REAL,
        profit_loss_percentage REAL,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // Daily prices table
    await db.execute('''
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
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL CHECK(operation IN ('INSERT', 'UPDATE', 'DELETE')),
        payload TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_transactions_user_id ON transactions(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_purchase_date ON transactions(purchase_date DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_daily_prices_date ON daily_prices(price_date DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_sync_queue_created ON sync_queue(created_at)',
    );

    _logger.i('Database schema created successfully');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from version $oldVersion to $newVersion');
    
    // Handle future schema migrations here
    if (oldVersion < 2) {
      // Example migration for version 2
      // await db.execute('ALTER TABLE transactions ADD COLUMN new_column TEXT');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    _logger.i('Database closed');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('daily_prices');
    await db.delete('sync_queue');
    _logger.i('All data cleared from local database');
  }
}
```

### 5. Network Info Service

```dart
// lib/core/network/network_info.dart

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
```

---

## Dependency Injection Setup

```dart
// lib/shared/data/providers/dependency_injection.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lumbungemas/core/network/network_info.dart';
import 'package:lumbungemas/shared/data/services/google_sheets_service.dart';
import 'package:lumbungemas/shared/data/services/local_database_service.dart';
import 'package:lumbungemas/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:lumbungemas/features/portfolio/data/datasources/portfolio_local_datasource.dart';
import 'package:lumbungemas/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';

// Core providers
final loggerProvider = Provider<Logger>((ref) => Logger());

final googleSignInProvider = Provider<GoogleSignIn>(
  (ref) => GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/spreadsheets'],
  ),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final connectivityProvider = Provider<Connectivity>(
  (ref) => Connectivity(),
);

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(ref.watch(connectivityProvider)),
);

// Service providers
final googleSheetsServiceProvider = Provider<GoogleSheetsService>(
  (ref) => GoogleSheetsService(
    googleSignIn: ref.watch(googleSignInProvider),
    secureStorage: ref.watch(secureStorageProvider),
    logger: ref.watch(loggerProvider),
  ),
);

final localDatabaseProvider = Provider<LocalDatabaseService>(
  (ref) => LocalDatabaseService.instance,
);

// Data source providers
final portfolioRemoteDataSourceProvider = Provider<PortfolioRemoteDataSource>(
  (ref) => PortfolioRemoteDataSourceImpl(
    sheetsService: ref.watch(googleSheetsServiceProvider),
    logger: ref.watch(loggerProvider),
  ),
);

final portfolioLocalDataSourceProvider = FutureProvider<PortfolioLocalDataSource>(
  (ref) async {
    final db = await ref.watch(localDatabaseProvider).database;
    return PortfolioLocalDataSourceImpl(
      database: db,
      logger: ref.watch(loggerProvider),
    );
  },
);

// Repository providers
final portfolioRepositoryProvider = FutureProvider<PortfolioRepository>(
  (ref) async {
    final localDataSource = await ref.watch(portfolioLocalDataSourceProvider.future);
    
    return PortfolioRepositoryImpl(
      remoteDataSource: ref.watch(portfolioRemoteDataSourceProvider),
      localDataSource: localDataSource,
      networkInfo: ref.watch(networkInfoProvider),
    );
  },
);
```

---

## Main App Entry Point

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lumbungemas/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: LumbungEmasApp(),
    ),
  );
}
```

```dart
// lib/app.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LumbungEmasApp extends StatelessWidget {
  const LumbungEmasApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LumbungEmas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('LumbungEmas - Ready for Implementation'),
        ),
      ),
    );
  }
}
```

---

This completes the code examples for the core implementation!
