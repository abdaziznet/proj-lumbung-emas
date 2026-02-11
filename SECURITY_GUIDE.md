# 🔐 Security Guide - API Keys & Sensitive Data

## Overview

This guide explains how to securely store API keys, Firebase configuration, and Google Sheets credentials without exposing them in GitHub.

---

## 🎯 Strategy Summary

| Item | Storage Method | Reason |
|------|---------------|--------|
| **Firebase Config (Android)** | `google-services.json` | Auto-generated, gitignored |
| **Firebase Config (iOS)** | `GoogleService-Info.plist` | Auto-generated, gitignored |
| **Google Sheets Spreadsheet ID** | Environment variables | User-specific |
| **API Keys** | Flutter environment variables | Build-time injection |
| **OAuth Credentials** | Secure storage at runtime | Encrypted storage |

---

## 1. Firebase Configuration

### ✅ Android Setup

**File**: `android/app/google-services.json`

```json
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "lumbungemas-xxxxx",
    "storage_bucket": "lumbungemas-xxxxx.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:xxxxx",
        "android_client_info": {
          "package_name": "com.lumbungemas.lumbungemas"
        }
      },
      "oauth_client": [
        {
          "client_id": "xxxxx.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        }
      ]
    }
  ]
}
```

**Security**: This file is automatically gitignored by Flutter.

### ✅ iOS Setup

**File**: `ios/Runner/GoogleService-Info.plist`

This file is also automatically gitignored.

### ✅ Verify .gitignore

**File**: `.gitignore` (should already contain)

```gitignore
# Firebase
**/google-services.json
**/GoogleService-Info.plist

# Environment files
.env
.env.*
!.env.example

# Secure storage
**/*.keystore
**/*.jks
**/key.properties
```

---

## 2. Google Sheets Spreadsheet ID

### Method 1: Environment Variables (Recommended)

#### Step 1: Create `.env` file

**File**: `.env` (root of project)

```env
# Google Sheets Configuration
GOOGLE_SHEETS_SPREADSHEET_ID=1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t

# Optional: Different spreadsheets for different environments
GOOGLE_SHEETS_SPREADSHEET_ID_DEV=1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t
GOOGLE_SHEETS_SPREADSHEET_ID_PROD=9z8y7x6w5v4u3t2s1r0q9p8o7n6m5l4k3j2i1h0g
```

#### Step 2: Add flutter_dotenv package

**File**: `pubspec.yaml`

```yaml
dependencies:
  flutter_dotenv: ^5.1.0

flutter:
  assets:
    - .env
```

#### Step 3: Create `.env.example` (for GitHub)

**File**: `.env.example`

```env
# Google Sheets Configuration
# Get your spreadsheet ID from the URL:
# https://docs.google.com/spreadsheets/d/[SPREADSHEET_ID]/edit
GOOGLE_SHEETS_SPREADSHEET_ID=your_spreadsheet_id_here

# Optional: Different environments
GOOGLE_SHEETS_SPREADSHEET_ID_DEV=your_dev_spreadsheet_id
GOOGLE_SHEETS_SPREADSHEET_ID_PROD=your_prod_spreadsheet_id
```

#### Step 4: Update .gitignore

```gitignore
# Environment variables
.env
.env.local
.env.*.local
```

#### Step 5: Load environment variables

**File**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lumbungemas/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: LumbungEmasApp(),
    ),
  );
}
```

#### Step 6: Use environment variables

**File**: `lib/core/config/app_config.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  /// Get Google Sheets Spreadsheet ID from environment
  static String get spreadsheetId {
    final id = dotenv.env['GOOGLE_SHEETS_SPREADSHEET_ID'];
    if (id == null || id.isEmpty) {
      throw Exception(
        'GOOGLE_SHEETS_SPREADSHEET_ID not found in .env file. '
        'Please copy .env.example to .env and configure your spreadsheet ID.',
      );
    }
    return id;
  }

  /// Get environment-specific spreadsheet ID
  static String getSpreadsheetId(String environment) {
    final key = 'GOOGLE_SHEETS_SPREADSHEET_ID_${environment.toUpperCase()}';
    return dotenv.env[key] ?? spreadsheetId;
  }

  /// Check if running in production
  static bool get isProduction {
    return dotenv.env['ENVIRONMENT'] == 'production';
  }

  /// Check if running in development
  static bool get isDevelopment {
    return dotenv.env['ENVIRONMENT'] == 'development' || 
           dotenv.env['ENVIRONMENT'] == null;
  }
}
```

#### Step 7: Update app_constants.dart

**File**: `lib/core/constants/app_constants.dart`

```dart
import 'package:lumbungemas/core/config/app_config.dart';

class AppConstants {
  AppConstants._();

  // ... other constants ...

  // Google Sheets - Now loaded from environment
  static String get spreadsheetId => AppConfig.spreadsheetId;
  
  // Sheet names remain constant
  static const String usersSheetName = 'Users';
  static const String transactionsSheetName = 'Transactions';
  static const String dailyPricesSheetName = 'Daily_Prices';
  static const String portfolioSummarySheetName = 'Portfolio_Summary';
}
```

---

## 3. Build-Time Environment Variables (Alternative)

### Using --dart-define

This method doesn't require the dotenv package.

#### Build with environment variables

```bash
# Development build
flutter run --dart-define=SPREADSHEET_ID=your_dev_spreadsheet_id

# Production build
flutter build apk --release --dart-define=SPREADSHEET_ID=your_prod_spreadsheet_id
```

#### Access in code

**File**: `lib/core/config/app_config.dart`

```dart
class AppConfig {
  AppConfig._();

  static const String spreadsheetId = String.fromEnvironment(
    'SPREADSHEET_ID',
    defaultValue: '',
  );

  static void validateConfig() {
    if (spreadsheetId.isEmpty) {
      throw Exception(
        'SPREADSHEET_ID not configured. '
        'Use: flutter run --dart-define=SPREADSHEET_ID=your_id',
      );
    }
  }
}
```

#### Call validation in main

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Validate configuration
  AppConfig.validateConfig();
  
  await Firebase.initializeApp();
  
  runApp(const ProviderScope(child: LumbungEmasApp()));
}
```

---

## 4. OAuth Credentials (Runtime)

### Using Flutter Secure Storage

OAuth tokens and refresh tokens should be stored securely at runtime.

**File**: `lib/core/services/secure_storage_service.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyGoogleCredentials = 'google_credentials';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Save Google credentials JSON
  Future<void> saveGoogleCredentials(String credentials) async {
    await _storage.write(key: _keyGoogleCredentials, value: credentials);
  }

  /// Get Google credentials JSON
  Future<String?> getGoogleCredentials() async {
    return await _storage.read(key: _keyGoogleCredentials);
  }

  /// Clear all tokens (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
```

---

## 5. CI/CD Secrets (GitHub Actions)

### GitHub Secrets Setup

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add secrets:
   - `GOOGLE_SHEETS_SPREADSHEET_ID`
   - `FIREBASE_ANDROID_JSON` (base64 encoded google-services.json)

### GitHub Actions Workflow

**File**: `.github/workflows/build.yml`

```yaml
name: Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.10.7'
    
    - name: Create .env file
      run: |
        echo "GOOGLE_SHEETS_SPREADSHEET_ID=${{ secrets.GOOGLE_SHEETS_SPREADSHEET_ID }}" > .env
    
    - name: Decode and create google-services.json
      run: |
        echo "${{ secrets.FIREBASE_ANDROID_JSON }}" | base64 -d > android/app/google-services.json
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Build APK
      run: flutter build apk --release --dart-define=SPREADSHEET_ID=${{ secrets.GOOGLE_SHEETS_SPREADSHEET_ID }}
```

---

## 6. Complete .gitignore

**File**: `.gitignore`

```gitignore
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Environment variables
.env
.env.*
!.env.example

# Firebase
**/google-services.json
**/GoogleService-Info.plist
firebase_options.dart

# Android related
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java
**/android/key.properties
*.jks
*.keystore

# iOS/XCode related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral/
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Coverage
coverage/

# Symbols
app.*.symbols

# Exceptions to above rules.
!**/ios/**/default.mode1v3
!**/ios/**/default.mode2v3
!**/ios/**/default.pbxuser
!**/ios/**/default.perspectivev3
```

---

## 7. Setup Instructions for Team Members

**File**: `SETUP.md`

```markdown
# Setup Instructions

## 1. Clone Repository

\`\`\`bash
git clone https://github.com/yourusername/lumbungemas.git
cd lumbungemas
\`\`\`

## 2. Configure Environment Variables

\`\`\`bash
# Copy example environment file
cp .env.example .env

# Edit .env and add your configuration
# GOOGLE_SHEETS_SPREADSHEET_ID=your_actual_spreadsheet_id
\`\`\`

## 3. Add Firebase Configuration

### Android
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`

### iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place in `ios/Runner/GoogleService-Info.plist`

## 4. Install Dependencies

\`\`\`bash
flutter pub get
\`\`\`

## 5. Run the App

\`\`\`bash
flutter run
\`\`\`

## ⚠️ Important

- Never commit `.env` file
- Never commit `google-services.json`
- Never commit `GoogleService-Info.plist`
- These files are gitignored for security
\`\`\`

---

## 8. Best Practices Summary

### ✅ DO

1. ✅ Use `.env` files for configuration
2. ✅ Add `.env` to `.gitignore`
3. ✅ Provide `.env.example` for reference
4. ✅ Use Flutter Secure Storage for runtime secrets
5. ✅ Use GitHub Secrets for CI/CD
6. ✅ Validate configuration at startup
7. ✅ Document setup process for team

### ❌ DON'T

1. ❌ Commit API keys to Git
2. ❌ Hardcode secrets in source code
3. ❌ Share `.env` files in chat/email
4. ❌ Commit Firebase config files
5. ❌ Use the same credentials for dev/prod
6. ❌ Store secrets in SharedPreferences
7. ❌ Log sensitive information

---

## 9. Security Checklist

- [ ] `.env` is in `.gitignore`
- [ ] `google-services.json` is in `.gitignore`
- [ ] `.env.example` is committed (without real values)
- [ ] `SETUP.md` is documented
- [ ] Team members know how to configure
- [ ] CI/CD uses GitHub Secrets
- [ ] Runtime tokens use Secure Storage
- [ ] No hardcoded secrets in code
- [ ] Different credentials for dev/prod
- [ ] Secrets are rotated periodically

---

## 10. Emergency Response

### If Secrets Are Leaked

1. **Immediately revoke** the exposed credentials
2. **Rotate** all API keys and tokens
3. **Remove** the commit from Git history:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   ```
4. **Force push** to remote (coordinate with team)
5. **Update** all team members with new credentials
6. **Review** access logs for unauthorized usage

---

## Summary

This security setup ensures:
- ✅ No secrets in Git repository
- ✅ Easy configuration for team members
- ✅ Secure runtime storage
- ✅ CI/CD compatibility
- ✅ Environment separation (dev/prod)
- ✅ Easy credential rotation

**Remember**: Security is not optional. Follow these practices strictly!
