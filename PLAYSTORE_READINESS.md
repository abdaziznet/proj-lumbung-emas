# Google Play Store Readiness Checklist

## Status: ⚠️ MEMBUTUHKAN PERSIAPAN

Project ini sudah production-ready dari sisi code, tapi missing beberapa document dan konfigurasi untuk Play Store submission.

---

## 📋 CHECKLIST PERSIAPAN (Priority Order)

### 🔴 CRITICAL (MUST DO) - Jangan upload tanpa ini!

- [ ] **1. App Signing Configuration**
  - Perlu generate Google Play Signing Key
  - File: `android/app/build.gradle.kts` - update `signingConfigs` untuk release
  - Tutorial: https://developer.android.com/studio/publish/app-signing#generate-key
  
- [ ] **2. Update Version Code & Name**
  - Current: `2026.0.7+8` di `pubspec.yaml` 
  - Untuk production: gunakan semantic versioning seperti `1.0.0+1`
  - Version code harus increment setiap build

- [ ] **3. Unique Application ID**
  - Current: `com.lumbungemas.lumbungemas`
  - ✅ Sudah unique, tapi pastikan tidak ada di Play Store lain
  - Pastikan konsisten di seluruh Android config

- [ ] **4. App Icon & Screenshots**
  - ✅ Ada icon di `assets/icons/gold.svg`
  - **BUTUH:** 512x512 PNG untuk Play Store listing
  - **BUTUH:** 2-8 screenshots (1080x1920 untuk portrait)
  - **BUTUH:** Feature graphic (1024x500)
  - **BUTUH:** Store icon (512x512)

- [ ] **5. Privacy Policy**
  - **BUTUH:** Privacy Policy document (MANDATORY oleh Play Store)
  - Tempat: Self-hosted URL atau Google Docs
  - Harus di-link di Play Store listing
  - Minimal harus cover: Firebase, Google Sign-In, Google Sheets access

- [ ] **6. Firebase Production Setup**
  - Current: `google-services.json` sudah ada
  - Verifikasi: Firebase project production-ready?
  - Enable: Firestore backup & security rules jika diperlukan

---

### 🟠 HIGH PRIORITY (HARUS SEBELUM LAUNCH)

- [ ] **7. Permission Justification**
  - Current permission: `POST_NOTIFICATIONS`
  - Pastikan semua permissions dalam `AndroidManifest.xml` justified di Play Store listing
  - Jika tambah internet: pastikan no suspicious activity

- [ ] **8. Compliance & Content Rating**
  - [ ] Isi questionnaire Content Rating
  - [ ] Agree dengan Policies (data privacy, security, etc)
  - [ ] Verify app doesn't violate Play Store Policies

- [ ] **9. Release Notes**
  - First version: describe features clearly
  - Indonesian language recommended
  - Min 10 characters, max 500 characters

- [ ] **10. Contact Info & Support**
  - Email untuk support
  - Website (optional) minimalkan di-link di app
  - Privacy policy URL (see #5)

- [ ] **11. Gradle & Dependencies Updates**
  - Flutter SDK: versi `3.10.7` ✅ OK
  - Target SDK: pastikan `targetSdk` = latest (versi 34-35)
  - Min SDK: currently 26 ✅ OK
  - Build tools sama dengan Flutter version

---

### 🟡 MEDIUM PRIORITY (GOOD TO HAVE)

- [ ] **12. App Testing**
  - [ ] Test di minimal 3-4 Android devices/emulator
  - [ ] Test offline mode
  - [ ] Test Firebase authentication
  - [ ] Test Google Sheets sync
  - [ ] Performance testing (battery, memory)

- [ ] **13. Crash Reporting**
  - Optional: Add Firebase Crashlytics
  - Atau: Use Sentry untuk analytics
  - Recommended untuk monitor production stability

- [ ] **14. Optimize App Size**
  - Run: `flutter build apk --analyze-size`
  - Target: < 50MB
  - Current estimate: ~40-50MB (reasonable)

- [ ] **15. Localization Check**
  - Current: Indonesian language primary ✅
  - Optional: Add English for international reach

---

### 🟢 NICE TO HAVE (TAPI TIDAK WAJIB)

- [ ] **16. Terms of Service**
  - Optional tapi recommended untuk app financial
  - Protect dari misuse

- [ ] **17. End User License Agreement (EULA)**
  - Optional, tapi recommended untuk financial app

- [ ] **18. In-App Purchase (IAM)**
  - N/A untuk app Anda (free app)

- [ ] **19. Analytics Setup**
  - Optional: Firebase Analytics untuk track user behavior
  - Helps optimize features

---

## 🔧 TECHNICAL SETUP STEPS

### Step 1: Fix App Signing (CRITICAL)

```gradle
// android/app/build.gradle.kts

// Add signing config
signingConfigs {
    release {
        storeFile = file("path/to/release.keystore")
        storePassword = System.getenv("KEYSTORE_PASSWORD")
        keyAlias = System.getenv("KEY_ALIAS")
        keyPassword = System.getenv("KEY_PASSWORD")
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

**Cara generate key:**
```bash
cd android/app
keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias lumbungemas-key
```

### Step 2: Update Version

```yaml
# pubspec.yaml
version: 1.0.0+1  # Ganti dari 2026.0.7+8
```

### Step 3: Build Release APK/AAB

```bash
# Build AAB (recommended untuk Play Store)
flutter build appbundle --release

# Atau build APK untuk testing
flutter build apk --release
```

---

## 📑 DOCUMENTS YANG PERLU DIBUAT

### 1. Privacy Policy Template

```markdown
# Privacy Policy - LumbungEmas

## Data Collection
- User authentication via Google Sign-In
- Portfolio data stored in Google Sheets
- Push notification tokens

## Third-Party Services
- Firebase Authentication
- Google Sign-In
- Google Sheets API
- Google Play Services

## User Rights
- Users can delete their account anytime
- All data in Google Sheets owned by user
```

### 2. Release Notes

```
Version 1.0.0
- Initial release
- Comprehensive portfolio management
- Real-time profit/loss tracking
- Google Sheets integration
- Firebase authentication
```

---

## 🚀 SUBMISSION CHECKLIST

Sebelum submit ke Play Store:

1. ✅ Code dioptimasi (flutter build appbundle --release)
2. ✅ Testing selesai di multiple devices
3. ✅ Version code sudah increment
4. ✅ App icon 512x512 PNG siap
5. ✅ Screenshots (min 2) siap
6. ✅ Privacy policy URL ready
7. ✅ Release notes written
8. ✅ Content rating questionnaire completed
9. ✅ Agree dengan policies
10. ✅ Contact info updated

---

## 📊 PROJECT ASSESSMENT

### Strengths ✅
- Architecture: Clean Architecture ✅
- Authentication: Firebase + Google Sign-In ✅
- Database: Google Sheets + SQLite (offline) ✅
- UI/UX: Material Design 3 ✅
- Features: Comprehensive portfolio management ✅
- Code quality: Well-structured, documented ✅
- Dependencies: Up-to-date ✅

### Weaknesses ❌
- Missing: Privacy Policy document
- Missing: App signing configuration for release
- Missing: Screenshots & store assets
- Missing: Release notes template
- Need: Content rating questionnaire

### Overall Readiness: **65% - NEARLY READY**

**Time to ready: 3-5 hari kerja** (Asumsi dokumentasi & assets ada)

---

## 🎯 RECOMMENDED TIMELINE

1. **Day 1:** Setup app signing & create Privacy Policy
2. **Day 2:** Prepare screenshots & store assets
3. **Day 3:** Build & test release APK/AAB
4. **Day 4:** Complete Play Console setup & upload
5. **Day 5:** Submit untuk review (24-48 jam approval)

---

## 📱 PLAY CONSOLE SETUP

1. Buka: https://play.google.com/console
2. Create new app
3. Isi app details (nama, deskripsi, category = Finance)
4. Upload AAB
5. Set content rating
6. Add privacy policy URL
7. Submit untuk review

---

## 💡 TIPS DARI GOOGLE

- Jangan gunakan "beta" atau "test" di app name
- Screenshots harus real gameplay, bukan mock-up
- Privacy policy harus accessible & clear
- Response time ke policy violation: < 24 jam
- Update regularly (minimal 1x/quarter) untuk maintain listing

---

## ⚠️ COMMON MISTAKES TO AVOID

- ❌ Hardcoded API keys / credentials (gunakan environment variables)
- ❌ Tidak test offline mode
- ❌ Incomplete privacy policy
- ❌ Version code tidak increment
- ❌ Screenshots dalam bahasa berbeda
- ❌ Signing key tidak aman (backup & secure!)

---

## 🔗 USEFUL RESOURCES

- Flutter Play Store: https://flutter.dev/to/play-store
- Google Play Policies: https://play.google.com/about/developer-content-policy/
- App Signing: https://developer.android.com/studio/publish/app-signing
- Firebase Security: https://firebase.google.com/docs/rules

---

## NEXT STEPS

1. **Mulai dari CRITICAL tasks dulu** (App signing, version, privacy policy)
2. **Prepare media assets** (icon, screenshots)
3. **Build & test** release version
4. **Create Play Console account** jika belum ada
5. **Submit untuk review**

Apakah ada part yang ingin saya bantu prepare?
