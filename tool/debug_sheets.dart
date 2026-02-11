import 'dart:io';
import 'dart:convert';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

void main() async {
  print('🔍 Starting Debug Script...');
  print('----------------------------------------------------------------');

  // 1. Get Spreadsheet ID from .env manually
  String? spreadsheetId;
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ Error: .env file not found!');
    return;
  }
  
  final lines = envFile.readAsLinesSync();
  for (var line in lines) {
    // Handle comments and simple parsing
    var cleanLine = line.trim();
    if (cleanLine.isEmpty || cleanLine.startsWith('#')) continue;
    
    if (cleanLine.startsWith('GOOGLE_SHEETS_SPREADSHEET_ID=')) {
      spreadsheetId = cleanLine.split('=')[1].trim();
      // Remove quotes if present
      if (spreadsheetId.startsWith('"') && spreadsheetId.endsWith('"')) {
        spreadsheetId = spreadsheetId.substring(1, spreadsheetId.length - 1);
      }
    }
  }

  if (spreadsheetId == null || spreadsheetId.isEmpty) {
    print('❌ Error: GOOGLE_SHEETS_SPREADSHEET_ID not found in .env');
    return;
  }

  print('📝 Spreadsheet ID loaded: $spreadsheetId');

  // 2. Load Service Account
  final credFile = File('credentials/service-account.json');
  if (!credFile.existsSync()) {
    print('❌ Error: credentials/service-account.json not found!');
    return;
  }

  final credContent = credFile.readAsStringSync();
  final credJson = jsonDecode(credContent);
  final email = credJson['client_email'];
  print('📧 Service Account: $email');
  print('----------------------------------------------------------------');

  // 3. Connect
  try {
    print('🔄 Authenticating...');
    final credentials = ServiceAccountCredentials.fromJson(credJson);
    final scopes = [SheetsApi.spreadsheetsScope];
    final client = await clientViaServiceAccount(credentials, scopes);
    final api = SheetsApi(client);

    print('✅ Authentication Successful!');

    // 4. Test Access
    print('🔄 Trying to access Spreadsheet...');
    final spreadsheet = await api.spreadsheets.get(spreadsheetId);
    
    print('\n🎉 SUCCESS! Connected to Spreadsheet: "${spreadsheet.properties?.title}"');
    print('\n📋 Available Sheets (Tabs):');
    for (var sheet in spreadsheet.sheets!) {
      print('   - "${sheet.properties?.title}"');
    }
    
    // Check for required sheets
    final requiredSheets = ['Users', 'Transactions', 'Daily_Prices', 'Portfolio_Summary'];
    print('\n🔍 Validation:');
    for (var req in requiredSheets) {
       bool found = spreadsheet.sheets!.any((s) => s.properties?.title == req);
       if (found) {
         print('   ✅ Sheet "$req" found.');
       } else {
         print('   ❌ Sheet "$req" MISSING! (Case Sensitive)');
       }
    }
    
    print('\n✅ Jika semua checklist hijau, aplikasi Flutter Anda seharusnya berjalan lancar.');

  } catch (e) {
    print('\n❌ CONNECTION FAILED:');
    print(e);
    
    print('\n----------------------------------------------------------------');
    if (e.toString().contains('404')) {
      print('👉 DIAGNOSA: 404 Found');
      print('   Artinya ID Spreadsheet salah atau Email Service Account belum di-invite.');
      print('\n   SOLUSI:');
      print('   1. Buka Spreadsheet di Browser.');
      print('   2. Klik tombol SHARE.');
      print('   3. Masukkan email ini sebagai EDITOR:');
      print('      $email');
      print('   4. Cek ulang ID di .env apakah sama dengan di URL Browser.');
    } else if (e.toString().contains('403')) {
      print('👉 DIAGNOSA: 403 Forbidden');
      print('   Artinya API belum di-enable atau permission kurang.');
    }
    print('----------------------------------------------------------------');
  }
}
