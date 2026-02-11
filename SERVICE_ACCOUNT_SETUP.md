# 🔐 Google Service Account Setup

## 📋 Anda Sudah Punya Service Account JSON!

File JSON dari Google Cloud Console ini adalah **Service Account credentials** yang lebih aman untuk production dibanding "Anyone with the link".

---

## 🎯 Apa itu Service Account?

Service Account adalah akun khusus untuk aplikasi (bukan user) yang:
- ✅ Lebih aman dari "Anyone with the link"
- ✅ Bisa dikontrol permission-nya
- ✅ Recommended untuk production
- ✅ Tidak perlu Google Sign-In untuk akses Sheets

---

## 📁 Struktur File JSON

File JSON Anda berisi credentials seperti ini:

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\nxxxxx\n-----END PRIVATE KEY-----\n",
  "client_email": "your-service-account@your-project.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

---

## 🔒 Cara Menyimpan File JSON dengan Aman

### ⚠️ JANGAN Commit ke Git!

File ini **SANGAT RAHASIA**. Jangan pernah commit ke GitHub!

### Method 1: Simpan di Folder Aman (Recommended untuk Development)

#### Step 1: Buat folder untuk credentials

```bash
# Di root project
mkdir -p credentials
```

#### Step 2: Copy file JSON ke folder

```bash
# Rename file menjadi service-account.json
cp /path/to/downloaded-file.json credentials/service-account.json
```

#### Step 3: Pastikan di .gitignore

File `.gitignore` sudah saya update dengan:

```gitignore
# Service Account Credentials
credentials/
**/service-account.json
**/service-account-*.json
```

✅ **Aman!** File tidak akan ter-commit.

---

### Method 2: Simpan di Environment Variable (Recommended untuk Production)

#### Step 1: Encode file JSON ke base64

**Windows (PowerShell):**
```powershell
$content = Get-Content credentials/service-account.json -Raw
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content)) | Out-File -FilePath credentials/service-account-base64.txt
```

**Linux/Mac:**
```bash
base64 -i credentials/service-account.json -o credentials/service-account-base64.txt
```

#### Step 2: Tambahkan ke .env

```env
# Service Account (base64 encoded)
GOOGLE_SERVICE_ACCOUNT_JSON_BASE64=eyJ0eXBlIjoic2VydmljZV9hY2NvdW50IiwicHJvamVjdF9pZCI6InlvdXItcHJvamVjdC1pZCIsInByaXZhdGVfa2V5X2lkIjoieHh4eHgiLCJwcml2YXRlX2tleSI6Ii0tLS0tQkVHSU4gUFJJVkFURSBLRVktLS0tLVxuLi4uXG4tLS0tLUVORCBQUklWQVRFIEtFWS0tLS0tXG4iLCJjbGllbnRfZW1haWwiOiJ5b3VyLXNlcnZpY2UtYWNjb3VudEB5b3VyLXByb2plY3QuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCJjbGllbnRfaWQiOiJ4eHh4eCIsImF1dGhfdXJpIjoiaHR0cHM6Ly9hY2NvdW50cy5nb29nbGUuY29tL28vb2F1dGgyL2F1dGgiLCJ0b2tlbl91cmkiOiJodHRwczovL29hdXRoMi5nb29nbGVhcGlzLmNvbS90b2tlbiIsImF1dGhfcHJvdmlkZXJfeDUwOV9jZXJ0X3VybCI6Imh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL29hdXRoMi92MS9jZXJ0cyIsImNsaWVudF94NTA5X2NlcnRfdXJsIjoiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vcm9ib3QvdjEvbWV0YWRhdGEveDUwOS8uLi4ifQ==
```

---

## 🔧 Update Source Code untuk Service Account

### Step 1: Update .env.example

```env
# Google Sheets Configuration
GOOGLE_SHEETS_SPREADSHEET_ID=your_spreadsheet_id_here

# Service Account Authentication (Choose one method)
# Method 1: File path (for development)
GOOGLE_SERVICE_ACCOUNT_FILE=credentials/service-account.json

# Method 2: Base64 encoded JSON (for production/CI-CD)
# GOOGLE_SERVICE_ACCOUNT_JSON_BASE64=your_base64_encoded_json_here
```

### Step 2: Update AppConfig

Buat file baru: `lib/core/config/service_account_config.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServiceAccountConfig {
  ServiceAccountConfig._();

  /// Get service account credentials as Map
  static Map<String, dynamic>? getCredentials() {
    // Method 1: From file path
    final filePath = dotenv.env['GOOGLE_SERVICE_ACCOUNT_FILE'];
    if (filePath != null && filePath.isNotEmpty) {
      return _loadFromFile(filePath);
    }

    // Method 2: From base64 encoded string
    final base64Json = dotenv.env['GOOGLE_SERVICE_ACCOUNT_JSON_BASE64'];
    if (base64Json != null && base64Json.isNotEmpty) {
      return _loadFromBase64(base64Json);
    }

    return null;
  }

  /// Load credentials from file
  static Map<String, dynamic>? _loadFromFile(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('Service account file not found: $filePath');
      }

      final jsonString = file.readAsStringSync();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load service account from file: $e');
    }
  }

  /// Load credentials from base64 encoded string
  static Map<String, dynamic>? _loadFromBase64(String base64String) {
    try {
      final jsonString = utf8.decode(base64.decode(base64String));
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to decode service account from base64: $e');
    }
  }

  /// Get client email from credentials
  static String? getClientEmail() {
    final credentials = getCredentials();
    return credentials?['client_email'] as String?;
  }

  /// Get project ID from credentials
  static String? getProjectId() {
    final credentials = getCredentials();
    return credentials?['project_id'] as String?;
  }

  /// Check if service account is configured
  static bool isConfigured() {
    return getCredentials() != null;
  }
}
```

### Step 3: Update Google Sheets Service

Update file: `lib/shared/data/services/google_sheets_service.dart`

Tambahkan import:
```dart
import 'package:googleapis_auth/auth_io.dart';
import 'package:lumbungemas/core/config/service_account_config.dart';
```

Tambahkan method baru untuk service account authentication:

```dart
/// Authenticate using Service Account (for production)
Future<void> authenticateWithServiceAccount() async {
  try {
    final credentials = ServiceAccountConfig.getCredentials();
    
    if (credentials == null) {
      throw SheetsException(
        message: 'Service account credentials not configured',
      );
    }

    // Create service account credentials
    final accountCredentials = ServiceAccountCredentials.fromJson(credentials);
    
    // Define scopes
    final scopes = [SheetsApi.spreadsheetsScope];
    
    // Get authenticated client
    final authClient = await clientViaServiceAccount(
      accountCredentials,
      scopes,
    );
    
    // Create Sheets API client
    _sheetsApi = SheetsApi(authClient);
    _isAuthenticated = true;
    
    _logger.i('Authenticated with service account: ${ServiceAccountConfig.getClientEmail()}');
  } catch (e) {
    _logger.e('Service account authentication failed', error: e);
    throw SheetsException(
      message: 'Failed to authenticate with service account',
      details: e,
    );
  }
}
```

---

## 🔐 Share Spreadsheet dengan Service Account

### ⚠️ PENTING: Berikan Akses ke Service Account!

Service account perlu akses ke spreadsheet Anda.

#### Step 1: Dapatkan Service Account Email

Buka file JSON, cari `client_email`:
```json
{
  "client_email": "your-service-account@your-project.iam.gserviceaccount.com"
}
```

#### Step 2: Share Spreadsheet

1. Buka Google Spreadsheet Anda
2. Klik tombol **"Share"**
3. Paste **service account email** di kolom "Add people and groups"
4. Set permission: **"Editor"**
5. **UNCHECK** "Notify people" (karena ini bukan user biasa)
6. Klik **"Share"**

✅ **Done!** Service account sekarang bisa akses spreadsheet.

---

## 🚀 Cara Menggunakan

### Development (Google Sign-In)

Untuk development, tetap gunakan Google Sign-In (user authentication):

```dart
final sheetsService = GoogleSheetsService(...);
await sheetsService.authenticate(); // User login
```

### Production (Service Account)

Untuk production, gunakan service account:

```dart
final sheetsService = GoogleSheetsService(...);
await sheetsService.authenticateWithServiceAccount(); // No user login needed
```

---

## 📁 Struktur File Akhir

```
lumbungemas/
├── .env                              ⚠️ RAHASIA
│   ├── GOOGLE_SHEETS_SPREADSHEET_ID
│   └── GOOGLE_SERVICE_ACCOUNT_FILE   ⚠️ Path ke JSON
│
├── credentials/                      ⚠️ RAHASIA (gitignored)
│   ├── service-account.json          ⚠️ File JSON dari Google Cloud
│   └── service-account-base64.txt    ⚠️ Base64 encoded (optional)
│
├── .gitignore                        ✅ Updated
│   ├── credentials/
│   ├── **/service-account*.json
│   └── .env
│
└── lib/
    └── core/
        └── config/
            └── service_account_config.dart  ✅ NEW
```

---

## ✅ Setup Checklist

### File JSON:
- [ ] File JSON sudah di-download dari Google Cloud Console
- [ ] File disimpan di `credentials/service-account.json`
- [ ] Folder `credentials/` ada di `.gitignore`

### Environment:
- [ ] `.env` sudah di-update dengan path file atau base64
- [ ] `.env.example` sudah di-update (tanpa nilai asli)

### Spreadsheet:
- [ ] Service account email sudah di-copy dari JSON
- [ ] Spreadsheet sudah di-share dengan service account email
- [ ] Permission: Editor

### Code:
- [ ] `service_account_config.dart` sudah dibuat
- [ ] `google_sheets_service.dart` sudah di-update
- [ ] Method `authenticateWithServiceAccount()` sudah ditambahkan

---

## 🔄 Migration Path

### Phase 1: Development (Sekarang)
- Gunakan Google Sign-In
- Permission: "Anyone with the link"
- User perlu login

### Phase 2: Production (Nanti)
- Gunakan Service Account
- Permission: Hanya service account
- Tidak perlu user login
- Lebih aman

---

## 🆘 Troubleshooting

### Error: "Service account file not found"

**Penyebab**: Path file salah di `.env`  
**Solusi**: 
```env
# Pastikan path benar (relative dari root project)
GOOGLE_SERVICE_ACCOUNT_FILE=credentials/service-account.json
```

### Error: "Permission denied"

**Penyebab**: Spreadsheet belum di-share dengan service account  
**Solusi**: Share spreadsheet dengan email dari `client_email` di JSON

### Error: "Invalid credentials"

**Penyebab**: File JSON corrupt atau salah  
**Solusi**: Download ulang dari Google Cloud Console

---

## 📚 Dokumentasi Terkait

- **SECURITY_GUIDE.md** - Security best practices
- **SETUP.md** - Setup instructions
- **GOOGLE_SHEETS_SETUP.md** - Sheets configuration

---

## 💡 Kesimpulan

File JSON Service Account yang Anda punya adalah **credentials production-grade** yang:

✅ **Lebih aman** dari "Anyone with the link"  
✅ **Tidak perlu user login** untuk akses Sheets  
✅ **Recommended** untuk production  
✅ **Bisa dikontrol** permission-nya  

**Simpan dengan aman dan jangan commit ke Git!** 🔒

---

**Next Steps:**
1. Simpan file JSON di `credentials/service-account.json`
2. Update `.env` dengan path file
3. Share spreadsheet dengan service account email
4. Test authentication!

🚀 **Ready for Production!**
