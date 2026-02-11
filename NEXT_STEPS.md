# 🚀 Next Steps - Setelah Setup Selesai

## ✅ Setup Sudah Selesai!

Anda sudah:
- ✅ File JSON di `credentials/service-account.json`
- ✅ Update `.env` dengan path file
- ✅ Spreadsheet sudah dibuat dengan 4 sheets
- ✅ Spreadsheet sudah di-share ke service account

**Sekarang saatnya TEST dan mulai CODING!** 🎉

---

## 🧪 Step 1: Test Configuration (5 menit)

### Test 1.1: Verify File Exists

```powershell
# Cek file JSON exists
Test-Path credentials\service-account.json
# Harus return: True
```

### Test 1.2: Verify .env Configuration

```powershell
# Lihat isi .env
cat .env
```

Pastikan ada:
```env
GOOGLE_SHEETS_SPREADSHEET_ID=your_actual_spreadsheet_id
GOOGLE_SERVICE_ACCOUNT_FILE=credentials/service-account.json
```

### Test 1.3: Run Flutter App

```bash
flutter run
```

**Expected Result:**
- ✅ App compile tanpa error
- ✅ Muncul screen "Configuration Loaded Successfully!"
- ✅ Tidak ada error di console

Jika ada error, lihat section **Troubleshooting** di bawah.

---

## 🔧 Step 2: Update Google Sheets Service (10 menit)

Sekarang kita perlu update `GoogleSheetsService` untuk support Service Account.

### File: `lib/shared/data/services/google_sheets_service.dart`

Tambahkan import di bagian atas:

```dart
import 'package:googleapis_auth/auth_io.dart';
import 'package:lumbungemas/core/config/service_account_config.dart';
```

Tambahkan method baru setelah method `authenticate()`:

```dart
/// Authenticate using Service Account (for production)
/// This method doesn't require user login
Future<void> authenticateWithServiceAccount() async {
  try {
    _logger.i('Authenticating with service account...');
    
    // Get service account credentials
    final credentials = ServiceAccountConfig.getCredentials();
    
    if (credentials == null) {
      throw SheetsException(
        message: 'Service account credentials not configured.\n'
            'Please check SERVICE_ACCOUNT_QUICK_GUIDE.md for setup instructions.',
      );
    }

    // Validate credentials
    if (!ServiceAccountConfig.validate()) {
      throw SheetsException(
        message: 'Invalid service account credentials.\n'
            'Please ensure the JSON file is valid.',
      );
    }

    // Create service account credentials
    final accountCredentials = ServiceAccountCredentials.fromJson(credentials);
    
    // Define scopes
    final scopes = [SheetsApi.spreadsheetsScope];
    
    // Get authenticated HTTP client
    final authClient = await clientViaServiceAccount(
      accountCredentials,
      scopes,
    );
    
    // Create Sheets API client
    _sheetsApi = SheetsApi(authClient);
    _isAuthenticated = true;
    
    _logger.i('✅ Authenticated with service account: ${ServiceAccountConfig.getClientEmail()}');
  } catch (e) {
    _logger.e('❌ Service account authentication failed', error: e);
    throw SheetsException(
      message: 'Failed to authenticate with service account: ${e.toString()}',
      details: e,
    );
  }
}
```

---

## 🧪 Step 3: Create Test File (15 menit)

Buat file test untuk verify koneksi ke Google Sheets.

### File: `lib/test_sheets_connection.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/config/app_config.dart';
import 'package:lumbungemas/core/config/service_account_config.dart';
import 'package:lumbungemas/shared/data/services/google_sheets_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class TestSheetsConnectionScreen extends ConsumerStatefulWidget {
  const TestSheetsConnectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TestSheetsConnectionScreen> createState() =>
      _TestSheetsConnectionScreenState();
}

class _TestSheetsConnectionScreenState
    extends ConsumerState<TestSheetsConnectionScreen> {
  final _logger = Logger();
  String _status = 'Ready to test';
  bool _isLoading = false;
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    _logger.i(message);
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing...';
      _logs.clear();
    });

    try {
      _addLog('🔍 Step 1: Checking configuration...');

      // Check spreadsheet ID
      final spreadsheetId = AppConfig.spreadsheetId;
      _addLog('✅ Spreadsheet ID: ${spreadsheetId.substring(0, 20)}...');

      // Check service account
      if (ServiceAccountConfig.isConfigured()) {
        _addLog('✅ Service account configured');
        _addLog('   Email: ${ServiceAccountConfig.getClientEmail()}');
        _addLog('   Project: ${ServiceAccountConfig.getProjectId()}');
      } else {
        _addLog('⚠️  Service account not configured');
      }

      _addLog('');
      _addLog('🔐 Step 2: Authenticating...');

      // Create Google Sheets service
      final sheetsService = GoogleSheetsService(
        googleSignIn: GoogleSignIn(
          scopes: ['https://www.googleapis.com/auth/spreadsheets'],
        ),
        secureStorage: const FlutterSecureStorage(),
        logger: _logger,
      );

      // Authenticate with service account
      await sheetsService.authenticateWithServiceAccount();
      _addLog('✅ Authentication successful!');

      _addLog('');
      _addLog('📊 Step 3: Testing spreadsheet access...');

      // Test read from Users sheet
      try {
        final usersData = await sheetsService.read('Users!A1:F1');
        _addLog('✅ Users sheet accessible');
        _addLog('   Headers: ${usersData.isNotEmpty ? usersData[0].length : 0} columns');
      } catch (e) {
        _addLog('❌ Users sheet error: $e');
      }

      // Test read from Transactions sheet
      try {
        final transactionsData = await sheetsService.read('Transactions!A1:L1');
        _addLog('✅ Transactions sheet accessible');
        _addLog('   Headers: ${transactionsData.isNotEmpty ? transactionsData[0].length : 0} columns');
      } catch (e) {
        _addLog('❌ Transactions sheet error: $e');
      }

      // Test read from Daily_Prices sheet
      try {
        final pricesData = await sheetsService.read('Daily_Prices!A1:H1');
        _addLog('✅ Daily_Prices sheet accessible');
        _addLog('   Headers: ${pricesData.isNotEmpty ? pricesData[0].length : 0} columns');
      } catch (e) {
        _addLog('❌ Daily_Prices sheet error: $e');
      }

      // Test read from Portfolio_Summary sheet
      try {
        final summaryData = await sheetsService.read('Portfolio_Summary!A1:H1');
        _addLog('✅ Portfolio_Summary sheet accessible');
        _addLog('   Headers: ${summaryData.isNotEmpty ? summaryData[0].length : 0} columns');
      } catch (e) {
        _addLog('❌ Portfolio_Summary sheet error: $e');
      }

      _addLog('');
      _addLog('🎉 All tests completed!');

      setState(() {
        _status = '✅ Connection successful!';
        _isLoading = false;
      });
    } catch (e) {
      _addLog('');
      _addLog('❌ Error: $e');
      setState(() {
        _status = '❌ Connection failed';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Google Sheets Connection'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _status.contains('✅')
                  ? Colors.green.shade50
                  : _status.contains('❌')
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testConnection,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run Test'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Logs
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey.shade200,
                      child: const Text(
                        'Logs',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _logs.isEmpty
                          ? const Center(
                              child: Text('No logs yet. Click "Run Test" to start.'),
                            )
                          : ListView.builder(
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    log,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: log.contains('❌')
                                          ? Colors.red
                                          : log.contains('✅')
                                              ? Colors.green
                                              : log.contains('⚠️')
                                                  ? Colors.orange
                                                  : Colors.black87,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔧 Step 4: Update Main App (5 menit)

Update `lib/main.dart` untuk menambahkan tombol test:

Ganti isi `MyApp` class dengan:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LumbungEmas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LumbungEmas'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'LumbungEmas',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configuration Loaded Successfully!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestSheetsConnectionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.science),
              label: const Text('Test Google Sheets Connection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Tambahkan import di atas:

```dart
import 'package:lumbungemas/test_sheets_connection.dart';
```

---

## 🚀 Step 5: Run Test (5 menit)

### 5.1. Install Dependencies

```bash
flutter pub get
```

### 5.2. Run App

```bash
flutter run
```

### 5.3. Test Connection

1. App akan terbuka
2. Klik tombol **"Test Google Sheets Connection"**
3. Klik **"Run Test"**
4. Lihat logs

**Expected Result:**
```
✅ Spreadsheet ID: ...
✅ Service account configured
✅ Authentication successful!
✅ Users sheet accessible
✅ Transactions sheet accessible
✅ Daily_Prices sheet accessible
✅ Portfolio_Summary sheet accessible
🎉 All tests completed!
```

---

## ✅ Step 6: Verify Success

Jika semua test berhasil, berarti:

- ✅ Configuration benar
- ✅ Service account berfungsi
- ✅ Spreadsheet accessible
- ✅ Semua sheets ada dan bisa dibaca
- ✅ **READY FOR DEVELOPMENT!** 🎉

---

## 🆘 Troubleshooting

### Error: "Service account credentials not configured"

**Penyebab**: File JSON tidak ditemukan  
**Solusi**:
```powershell
# Cek file exists
Test-Path credentials\service-account.json

# Cek .env
cat .env | Select-String "SERVICE_ACCOUNT"
```

### Error: "Permission denied"

**Penyebab**: Spreadsheet belum di-share ke service account  
**Solusi**:
1. Buka `credentials/service-account.json`
2. Copy `client_email`
3. Share spreadsheet dengan email tersebut
4. Permission: **Editor**

### Error: "Sheet not found"

**Penyebab**: Nama sheet salah  
**Solusi**: Pastikan nama sheet **exact**:
- `Users` (bukan `users` atau `USERS`)
- `Transactions`
- `Daily_Prices` (dengan underscore)
- `Portfolio_Summary` (dengan underscore)

### Error: "Invalid credentials"

**Penyebab**: File JSON corrupt atau salah format  
**Solusi**:
1. Download ulang dari Google Cloud Console
2. Pastikan format JSON valid
3. Jangan edit file JSON manually

---

## 🎯 Next Steps - Development

Setelah test berhasil, Anda bisa mulai development:

### Phase 1: Repository Layer (Week 1-2)
- [ ] Implement `PortfolioRepository`
- [ ] Implement `PricingRepository`
- [ ] Implement `AuthRepository`
- [ ] Test CRUD operations

### Phase 2: Business Logic (Week 2-3)
- [ ] Implement Use Cases
- [ ] Implement State Management (Riverpod)
- [ ] Implement Calculation Engine
- [ ] Test business logic

### Phase 3: UI Layer (Week 3-5)
- [ ] Implement Login Screen
- [ ] Implement Dashboard
- [ ] Implement Add Transaction Screen
- [ ] Implement Portfolio Detail Screen
- [ ] Implement Analytics Screen

### Phase 4: Advanced Features (Week 5-7)
- [ ] Charts integration
- [ ] PDF export
- [ ] Notifications
- [ ] Dark mode

### Phase 5: Testing & Polish (Week 7-8)
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] UI/UX polish

### Phase 6: Production (Week 8-10)
- [ ] Release build
- [ ] Play Store submission
- [ ] Documentation

---

## 📚 Documentation Reference

Untuk development, baca:

1. **IMPLEMENTATION_GUIDE.md** - Development guide
2. **ARCHITECTURE.md** - System architecture
3. **CODE_EXAMPLES.md** - Code examples
4. **PROJECT_SUMMARY.md** - Quick reference

---

## 🎉 Congratulations!

Setup sudah **100% SELESAI**! 🎊

Anda sekarang punya:
- ✅ Flutter project yang configured
- ✅ Google Sheets database yang ready
- ✅ Service Account yang secure
- ✅ Test tool untuk verify connection
- ✅ Complete documentation

**Siap untuk mulai coding!** 🚀

---

**Happy Coding!** 💻✨
