import 'dart:io';
import 'dart:convert';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

void main() async {
  stdout.writeln('🔍 Starting Debug Script...');
  stdout.writeln('----------------------------------------------------------------');

  // 1. Get Spreadsheet ID from .env manually
  String? spreadsheetId;
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    stdout.writeln('❌ Error: .env file not found!');
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
    stdout.writeln('❌ Error: GOOGLE_SHEETS_SPREADSHEET_ID not found in .env');
    return;
  }

  stdout.writeln('📝 Spreadsheet ID loaded: $spreadsheetId');

  // 2. Load Service Account
  final credFile = File('credentials/service-account.json');
  if (!credFile.existsSync()) {
    stdout.writeln('❌ Error: credentials/service-account.json not found!');
    return;
  }

  final credContent = credFile.readAsStringSync();
  final credJson = jsonDecode(credContent);
  final email = credJson['client_email'];
  stdout.writeln('📧 Service Account: $email');
  stdout.writeln('----------------------------------------------------------------');

  // 3. Connect
  try {
    stdout.writeln('🔄 Authenticating...');
    final credentials = ServiceAccountCredentials.fromJson(credJson);
    final scopes = [SheetsApi.spreadsheetsScope];
    final client = await clientViaServiceAccount(credentials, scopes);
    final api = SheetsApi(client);

    stdout.writeln('✅ Authentication Successful!');

    // 4. Test Access
    stdout.writeln('🔄 Trying to access Spreadsheet...');
    final spreadsheet = await api.spreadsheets.get(spreadsheetId);
    
    stdout.writeln('\n🎉 SUCCESS! Connected to Spreadsheet: "${spreadsheet.properties?.title}"');
    stdout.writeln('\n📋 Available Sheets (Tabs):');
    for (var sheet in spreadsheet.sheets!) {
      stdout.writeln('   - "${sheet.properties?.title}"');
    }
    
    // Check for required sheets
    final requiredSheets = ['Users', 'Transactions', 'Daily_Prices', 'Portfolio_Summary'];
    stdout.writeln('\n🔍 Validation:');
    for (var req in requiredSheets) {
       bool found = spreadsheet.sheets!.any((s) => s.properties?.title == req);
       if (found) {
         stdout.writeln('   ✅ Sheet "$req" found.');
       } else {
         stdout.writeln('   ❌ Sheet "$req" MISSING! (Case Sensitive)');
       }
    }
    
    stdout.writeln('\n✅ Jika semua checklist hijau, aplikasi Flutter Anda seharusnya berjalan lancar.');

  } catch (e) {
    stdout.writeln('\n❌ CONNECTION FAILED:');
    stdout.writeln(e);
    
    stdout.writeln('\n----------------------------------------------------------------');
    if (e.toString().contains('404')) {
      stdout.writeln('👉 DIAGNOSA: 404 Found');
      stdout.writeln('   Artinya ID Spreadsheet salah atau Email Service Account belum di-invite.');
      stdout.writeln('\n   SOLUSI:');
      stdout.writeln('   1. Buka Spreadsheet di Browser.');
      stdout.writeln('   2. Klik tombol SHARE.');
      stdout.writeln('   3. Masukkan email ini sebagai EDITOR:');
      stdout.writeln('      $email');
      stdout.writeln('   4. Cek ulang ID di .env apakah sama dengan di URL Browser.');
    } else if (e.toString().contains('403')) {
      stdout.writeln('👉 DIAGNOSA: 403 Forbidden');
      stdout.writeln('   Artinya API belum di-enable atau permission kurang.');
    }
    stdout.writeln('----------------------------------------------------------------');
  }
}
