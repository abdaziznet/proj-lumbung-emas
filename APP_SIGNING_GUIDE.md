# SETUP GUIDE: App Signing untuk Google Play Store

## 📖 Overview

Untuk upload ke Google Play Store, aplikasi HARUS di-sign dengan release key. Guide ini menunjukkan cara:
1. Generate release signing key
2. Update `build.gradle.kts`
3. Build signed APK/AAB
4. Upload ke Play Store

---

## 🔑 STEP 1: Generate Release Signing Key

### Opsi A: Recommended (menggunakan Android Studio GUI)

```
Android Studio → Build → Generate Signed Bundle/APK
→ Select "Android App Bundle" (AAB)
→ Click "Create new..." untuk keystore baru
→ Fill details (lihat option B untuk info yang diperlukan)
```

### Opsi B: Terminal Command

Buka terminal di project root:

```bash
# Navigate ke android/app directory
cd android/app

# Generate keystore
keytool -genkey -v -keystore release.keystore \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias lumbungemas-key

# Kapan ditanya, isi details:
# - Keystore password: [SECURE PASSWORD]
# - Key password: [SAME OR DIFFERENT PASSWORD]
# - First and last name: LumbungEmas App
# - Organizational unit: Development
# - Organization: Your Company/Personal
# - City/Locality: Jakarta
# - State/Province: DKI Jakarta
# - Country code: ID
```

**Output:** `android/app/release.keystore` file akan dibuat

### ⚠️ PENTING: Backup & Secure

```bash
# Backup keystore file ke lokasi aman
# JANGAN commit ke Git!
# Jika hilang, tidak bisa update app di Play Store lagi!

# Recommended: Simpan di
# - Password manager (1Password, Bitwarden)
# - Encrypted drive
# - Team shared storage (untuk team projects)
```

---

## 📝 STEP 2: Update Build Configuration

### Opsi A: Using Environment Variables (RECOMMENDED)

**1. Create `android/key.properties`** (jangan commit ke Git)

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=lumbungemas-key
storeFile=release.keystore
```

**2. Update `android/app/build.gradle.kts`**

```kotlin
// Di atas android {} block, add:
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    // ADD SIGNING CONFIG
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... other release config ...
        }
    }
}
```

**3. Update `.gitignore`** (jangan leak passwords)

```
# Add ke android/.gitignore atau root .gitignore
android/key.properties
android/app/release.keystore
```

### Opsi B: Direct in build.gradle (LESS SECURE)

```kotlin
signingConfigs {
    release {
        storeFile file("release.keystore")
        storePassword "YOUR_PASSWORD"
        keyAlias "lumbungemas-key"
        keyPassword "YOUR_PASSWORD"
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

⚠️ **NOT RECOMMENDED** - passwords visible dalam source code

---

## 📦 STEP 3: Update Version Numbers

### Current Version
```yaml
# pubspec.yaml
version: 2026.0.7+8
```

### Change To
```yaml
# pubspec.yaml
version: 1.0.0+1
```

**Penjelasan:**
- `1.0.0` = Version name (user lihat di Play Store)
- `+1` = Version code (internal, harus selalu increment)
- Subsequent releases: `1.0.1+2`, `1.1.0+3`, dll

**Convention:**
- MAJOR version = significant features or redesign
- MINOR version = new features
- PATCH version = bug fixes
- Version code = increment setiap build

---

## 🏗️ STEP 4: Build Release APK/AAB

### Build Android App Bundle (RECOMMENDED)

```bash
# Navigate ke project root
cd /path/to/lumbungemas

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build AAB (recommended untuk Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Alternative: Build APK (for local testing)

```bash
# Build APK
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
```

### Verify Signed

```bash
# Check if APK/AAB is signed correctly
jarsigner -verify -verbose build/app/outputs/apk/release/app-release.apk

# Output should show: "jar verified"
```

---

## 📊 STEP 5: Analyze Build Size

```bash
flutter build appbundle --release --analyze-size

# Output akan show:
# - Total size
# - Package breakdown
# - Recommendations untuk reduce size
```

**Target:** < 50MB (recommended)

---

## 🚀 STEP 6: Test Before Upload

### Test Local Signed APK

```bash
# Install signed APK ke device
adb install build/app/outputs/apk/release/app-release.apk

# Test important flows:
# 1. Login dengan Google
# 2. Add asset
# 3. Calculate profit/loss
# 4. Export PDF
# 5. Notifications
```

### Check Version Numbers

```bash
# Verify di app settings
# Settings → About → Version should show 1.0.0
```

---

## 📱 STEP 7: Upload to Play Console

1. **Buka Play Console:** https://play.google.com/console
2. **Create new app** (jika belum ada)
3. **Navigation:**
   - Release → Production
   - Upload `app-release.aab` (dapat dari step 4)
4. **Fill release notes:**
   ```
   Version 1.0.0 - Initial Release
   
   Fitur utama:
   - Portfolio management emas & perak
   - Real-time profit/loss tracking
   - Google Sheets integration
   - Detailed analytics & charts
   - Export ke PDF
   ```
5. **Review & submit**

---

## ✅ CHECKLIST SEBELUM UPLOAD

- [ ] Key generated & secured
- [ ] `build.gradle.kts` updated
- [ ] `key.properties` created & in `.gitignore`
- [ ] Version updated ke `1.0.0+1`
- [ ] `flutter clean` & `flutter pub get` dijalankan
- [ ] `flutter build appbundle --release` berhasil
- [ ] APK/AAB size reasonable (< 50MB)
- [ ] Local testing passed
- [ ] Privacy policy ready
- [ ] Screenshots prepared

---

## 🔒 SECURITY BEST PRACTICES

### DO ✅
- [ ] Backup keystore di secure location
- [ ] Use strong passwords (min 12 char, alphanumeric+symbols)
- [ ] Don't share keystore atau passwords
- [ ] Add keystore to `.gitignore`
- [ ] Don't commit key.properties ke Git
- [ ] Rotate passwords annually
- [ ] Use different passwords untuk keystore & key

### DON'T ❌
- [ ] Hardcode passwords di gradle files
- [ ] Commit keystore atau key.properties ke Git
- [ ] Share keystore dengan unauthorized people
- [ ] Use weak/simple passwords
- [ ] Lose original keystore (CANNOT RECOVER!)
- [ ] Mix signing keys between apps

---

## 📋 TROUBLESHOOTING

### Error: "keystore file not found"
```
❌ Solution: Verify path di key.properties correct & file exists
   Check: android/app/release.keystore exists
```

### Error: "The keystore password is too short"
```
❌ Solution: Use password dengan min 6 characters
   Re-generate dengan password lebih panjang
```

### Error: "Keystore was tampered with"
```
❌ Solution: File corrupted - regenerate keystore
   Risk: Akan tidak bisa update app lama di Play Store
```

### Build APK size > 100MB
```
❌ Solution: Analyze menggunakan --analyze-size
   Check native libraries & remove unnecessary assets
```

### Play Store "App not compatible"
```
❌ Solution: 
   1. Check minSdk & targetSdk di gradle
   2. Verify Dart SDK version
   3. Test di multiple devices
```

---

## 🎓 REFERENCE

### File Locations
- Keystore: `android/app/release.keystore`
- Key properties: `android/key.properties` (add ke .gitignore)
- Build config: `android/app/build.gradle.kts`
- Version: `pubspec.yaml`
- Built AAB: `build/app/outputs/bundle/release/app-release.aab`

### Links
- Flutter Publishing: https://flutter.dev/to/play-store
- Android Signing: https://developer.android.com/studio/publish/app-signing
- Key Tool Doc: https://docs.oracle.com/javase/8/docs/technotes/tools/windows/keytool.html

---

## 💡 NEXT STEPS

1. Generate keystore (STEP 1)
2. Update build.gradle.kts (STEP 2)
3. Update version (STEP 3)
4. Build AAB (STEP 4)
5. Test locally (STEP 6)
6. Upload to Play Console (STEP 7)

Good luck! 🚀
