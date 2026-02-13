import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumbungemas/core/config/app_config.dart';
import 'package:lumbungemas/core/config/service_account_config.dart';
import 'package:lumbungemas/shared/data/services/google_sheets_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class TestSheetsConnectionScreen extends ConsumerStatefulWidget {
  const TestSheetsConnectionScreen({super.key});

  @override
  ConsumerState<TestSheetsConnectionScreen> createState() =>
      _TestSheetsConnectionScreenState();
}

class _TestSheetsConnectionScreenState
    extends ConsumerState<TestSheetsConnectionScreen> {
  final _logger = Logger();
  String _status = 'Ready to test';
  bool _isLoading = false;
  final List<String> _logs = [];

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
      if (await ServiceAccountConfig.isConfigured()) {
        _addLog('✅ Service account configured');
        _addLog('   Email: ${await ServiceAccountConfig.getClientEmail()}');
        _addLog('   Project: ${await ServiceAccountConfig.getProjectId()}');
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
        logger: _logger,
      );

      // Authenticate with service account
      await sheetsService.authenticateWithServiceAccount();
      _addLog('✅ Authentication successful!');

      _addLog('');
      _addLog('📊 Step 3: Checking available sheets...');
      
      try {
        final sheetNames = await sheetsService.getSheetNames();
        _addLog('✅ Found ${sheetNames.length} sheets:');
        for (final name in sheetNames) {
          _addLog('   - "$name"');
        }
        
        // Check for required sheets
        final requiredSheets = ['Users', 'Transactions', 'Daily_Prices', 'Portfolio_Summary'];
        final missingSheets = requiredSheets.where((name) => !sheetNames.contains(name)).toList();
        
        if (missingSheets.isNotEmpty) {
          _addLog('❌ Missing required sheets: ${missingSheets.join(', ')}');
          _addLog('   Please rename your sheets EXACTLY as shown above.');
        } else {
          _addLog('✅ All required sheets found!');
        }
      } catch (e) {
        _addLog('❌ Failed to list sheets: $e');
        if (e.toString().contains('404')) {
           _addLog('   Possible causes:');
           _addLog('   1. Spreadsheet ID in .env is incorrect');
           _addLog('   2. Service Account email not added as Editor');
        }
      }

      _addLog('');
      _addLog('📊 Step 4: Testing data access...');

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
        foregroundColor: Colors.white,
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
