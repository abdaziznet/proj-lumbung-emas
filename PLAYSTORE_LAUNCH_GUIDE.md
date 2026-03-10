# 🚀 QUICK START: Google Play Store Preparation (5-Day Timeline)

## 📅 Timeline & Checklist

### ⏰ DAY 1: Setup & Security
**Objective:** Siapkan app signing & prepare dokumentasi

#### Morning
- [ ] Generate release signing key
  ```bash
  cd android/app
  keytool -genkey -v -keystore release.keystore \
    -keyalg RSA -keysize 2048 -validity 10000 -alias lumbungemas-key
  ```
- [ ] Update `android/app/build.gradle.kts` dengan signing config
- [ ] Create `android/key.properties` dengan credentials
- [ ] Add `key.properties` & `release.keystore` ke `.gitignore`
- [ ] Save keystore password ke password manager

#### Afternoon
- [ ] Update `pubspec.yaml` version dari `2026.0.7+8` → `1.0.0+1`
- [ ] Review Privacy Policy (use template di `PRIVACY_POLICY.md`)
- [ ] Create support email address (atau pakai existing)
- [ ] Verify Firebase project is production-ready

---

### ⏰ DAY 2: Media & Assets
**Objective:** Siapkan visual assets untuk Play Store listing

#### Requirements
- [ ] **App Icon (512x512 PNG)**
  - Ada di `assets/icons/gold.png` - update untuk 512x512 versi jika perlu
  
- [ ] **2-5 Screenshots (1080x1920 PNG) - Portrait**
  - Screenshot 1: Main dashboard showing portfolio summary
  - Screenshot 2: Asset list & details
  - Screenshot 3: Analytics/charts
  - Screenshot 4: Profit/loss tracking
  - Screenshot 5: (Optional) PDF export feature
  
- [ ] **Feature Graphic (1024x500 PNG)**
  - Untuk heading di Play Store listing
  - Minimal text, focus pada visual
  - Recommend: Use Canva template atau Figma

#### Steps
1. Build APK local untuk testing
2. Take screenshots dari device/emulator (bisa pakai emulator)
3. Crop/edit screenshots to 1080x1920
4. Optional: Add text overlays untuk explain features
5. Save semua dalam folder `playstore_assets/`

---

### ⏰ DAY 3: Build & Testing
**Objective:** Build signed release version & test thoroughly

#### Morning - Build
```bash
# Clean & build
flutter clean
flutter pub get

# Build AAB
flutter build appbundle --release

# Size analysis
flutter build appbundle --release --analyze-size
```

Output path: `build/app/outputs/bundle/release/app-release.aab`

#### Afternoon - Testing
- [ ] Install APK ke real device atau multiple emulators
- [ ] Test login flow (Google Sign-In)
- [ ] Test add/edit assets
- [ ] Test portfolio calculations
- [ ] Test offline mode
- [ ] Check version number (Settings → About)
- [ ] Verify no error logs
- [ ] Test notification permissions

#### Verification
```bash
# Verify APK is signed correctly
jarsigner -verify -verbose build/app/outputs/apk/release/app-release.apk
# Expected: "jar verified"
```

---

### ⏰ DAY 4: Play Console Setup & Upload
**Objective:** Setup Play Console & upload ke review

#### Step 1: Create Play Console Account
- Go: https://play.google.com/console
- Pay: $25 USD (one-time)
- Setup: Merchant account & developer info

#### Step 2: Create New App
- [ ] Click "Create app"
- [ ] App name: "LumbungEmas"
- [ ] Default language: Indonesian
- [ ] Category: Finance → Investment
- [ ] Category: Personal Finance

#### Step 3: Fill App Details
- [ ] **Title:** LumbungEmas
- [ ] **Short Description (80 chars):**  
  `Kelola portfolio emas & perak, tracking untung rugi real-time`

- [ ] **Full Description (4000 chars):**
  ```
  LumbungEmas - Mitra Monitoring Aset Emas Anda
  
  Fitur Utama:
  ✓ Kelola portfolio emas & perak dari berbagai brand
  ✓ Tracking keuntungan & kerugian real-time
  ✓ Analisis mendalam dengan grafik interaktif
  ✓ Integrasi Google Sheets untuk backup data
  ✓ Export laporan ke PDF
  ✓ Notifikasi harga untuk monitoring
  ✓ Offline mode - akses tanpa internet
  ✓ Enkripsi data lokal untuk keamanan
  
  Supported Brands:
  - Antam
  - UBS
  - EmasKu
  - Galeri 24
  - Pegadaian
  - Custom brands
  
  Teknologi:
  - Firebase authentication
  - Google Sheets integration
  - Real-time calculations
  - Material Design UI
  
  Privasi & Keamanan:
  - Tidak ada tracking/ads
  - Semua data Anda kontrol
  - Encrypted storage
  - Open source compatible
  
  Status: Version 1.0 - Production Ready
  ```

#### Step 4: Add Media
- [ ] Upload app icon (512x512)
- [ ] Upload feature graphic (1024x500)
- [ ] Upload 2-5 screenshots
- [ ] (Optional) Video preview

#### Step 5: Content Rating
- [ ] Fill IARC questionnaire:
  - Violence: None
  - Sexual content: None
  - Profanity: None
  - Alcohol/drugs: Not applicable
  - Other: Financial information about precious metals
- [ ] Get rating (instant)

#### Step 6: Privacy & Compliance
- [ ] Link Privacy Policy (url atau embed)
  - Option: Upload `PRIVACY_POLICY.md` online
  - Or: Create Google Doc & make public, link URL
  
- [ ] Support email: [your-email]
- [ ] Website: (optional)
- [ ] Verify no third-party ad/analytics networks

#### Step 7: Upload AAB
- [ ] Go: Release → Production
- [ ] Click upload button
- [ ] Select `build/app/outputs/bundle/release/app-release.aab`
- [ ] System akan validate & extract APKs (tunggu 2-5 min)

#### Step 8: Review Release Notes
```
Version 1.0.0
- Initial Release
- Comprehensive precious metal portfolio management
- Real-time profit/loss tracking
- Multi-brand support (Antam, UBS, EmasKu, etc)
- Google Sheets integration
- Advanced analytics with charts
- PDF export functionality
- Offline mode with sync
```

#### Step 9: Submit for Review
- [ ] Review semua info sekali lagi
- [ ] Click "Submit for review"
- [ ] **Status:** "In Review" (tunggu 24-48 jam)

---

### ⏰ DAY 5: Monitor & Optimize
**Objective:** Monitor review status & prepare untuk launch

#### Review Monitoring
- [ ] Check console daily untuk status updates
- [ ] Expected: Approved dalam 24-48 jam
- [ ] Worst case: Rejection dengan feedback (fix & resubmit)

#### Common Rejection Reasons (& solutions)
- **"App crashes on startup"** → Test more thoroughly
- **"Incomplete permissions disclosure"** → Update privacy policy
- **"Misleading description"** → Align description dengan actual features
- **"Policy violation"** → Review Google Play Policies https://play.google.com/about/developer-content-policy/

#### After Approval
- [ ] Click "Release to Production"
- [ ] Set rollout percentage (recommend: start 10-25%)
- [ ] Monitor crash reports & reviews
- [ ] Gradually increase rollout

#### Celebrate! 🎉
App is now live di Google Play Store!

---

## 📋 FINAL CHECKLIST

### CRITICAL (Must Have)
- [ ] App signing key generated
- [ ] Signed AAB ready
- [ ] Privacy policy written & accessible
- [ ] App icon 512x512 prepared
- [ ] Minimum 2 screenshots
- [ ] Play Console account created
- [ ] Content rating completed
- [ ] Support email configured
- [ ] Version number updated (1.0.0+1)

### IMPORTANT (Should Have)
- [ ] 4-5 screenshots (better coverage)
- [ ] Feature graphic prepared
- [ ] Release notes written
- [ ] Tested on 3+ devices/versions
- [ ] No crashes or major bugs
- [ ] Privacy policy reviewed for compliance

### NICE TO HAVE (Optional)
- [ ] Promo video/preview
- [ ] Promotional graphics
- [ ] Pre-launch marketing
- [ ] Beta testing feedback addressed
- [ ] Localized description (if international)

---

## 🎯 Success Criteria

**App is ready untuk Play Store jika:**
- ✅ Signed AAB build works without crashes
- ✅ All features functional (login, add asset, calculate, export)
- ✅ Privacy policy addresses Firebase & Google Sheets usage
- ✅ Offline mode tested & working
- ✅ Screenshots clear & show value proposition
- ✅ Play Console listing complete dengan semua info
- ✅ Content rating approved
- ✅ No policy violations identified

---

## 📞 Support Resources

### If Stuck:
1. **Flutter Docs:** https://flutter.dev/to/play-store
2. **Google Play Policies:** https://play.google.com/about/developer-content-policy/
3. **Firebase Security:** https://firebase.google.com/docs/rules
4. **Android Signing:** https://developer.android.com/studio/publish/app-signing

### If Rejected:
- Read Google's feedback carefully
- Cross-check dengan policy docs
- Fix issues explicitly mentioned
- Resubmit updated version

---

## 💡 Pro Tips

1. **Test Early & Often** - Jangan tunggu hari 3 untuk start testing
2. **Screenshots Matter** - 70% user decide dari screenshots, put effort here!
3. **Privacy Policy Clear** - User suspicious tanpa clear privacy statement
4. **Monitor Reviews** - First 2-3 weeks crucial, respond to feedback
5. **Gradual Rollout** - Jangan 100% immediately, check stability first
6. **Regular Updates** - At least 1x per quarter untuk maintain listing

---

## 🚀 EXECUTION ORDER

### MUST DO FIRST (Cannot skip)
1. Generate signing key
2. Build signed AAB
3. Create Play Console account
4. Write privacy policy
5. Prepare screenshots

### THEN (In order)
6. Setup Play Console listing
7. Upload AAB
8. Complete all required fields
9. Submit for review
10. Monitor & launch

---

**Estimated Time Investment:**
- Day 1: 2-3 hours
- Day 2: 3-4 hours
- Day 3: 2-3 hours
- Day 4: 1-2 hours
- Day 5: 30 mins (monitoring)

**Total: 9-13 hours spread over 5 days**

---

**Good luck! Semoga app launch sukses! 🚀**

Kalau ada questions, refer ke:
- `PLAYSTORE_READINESS.md` (comprehensive checklist)
- `APP_SIGNING_GUIDE.md` (signing setup details)
- `PRIVACY_POLICY.md` (template privacy policy)
