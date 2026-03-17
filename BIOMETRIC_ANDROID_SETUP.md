# 🔐 Biometric Setup Guide - Android

## ⚠️ Common Issues & Solutions

### Issue 1: "no_fragment_activity" Error

**Error Message:**
```
PlatformException(no_fragment_activity, local_auth plugin requires activity to be a FragmentActivity., null, null)
```

**Cause:**
The `local_auth` plugin requires the main activity to be a `FragmentActivity`. While Flutter's `FlutterActivity` is a FragmentActivity by default, there can be issues with activity lifecycle or configuration.

**Solution:**

#### ✅ Already Applied in This Project:
1. **AndroidManifest.xml** - Added `android:enableOnBackInvokedCallback="true"`
   ```xml
   <application
       android:enableOnBackInvokedCallback="true"
       ...
   ```

2. **MainActivity.kt** - Extends FlutterActivity (which is FragmentActivity)
   ```kotlin
   class MainActivity : FlutterActivity()
   ```

3. **build.gradle.kts** - Correct configuration
   - minSdk = 26 (supports biometric)
   - compileSdk = 34+

#### Additional Checks if Issue Persists:

1. **Clean Build:**
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean && cd ..
   flutter run
   ```

2. **Check Android Version:**
   - Min SDK should be 26+
   - Target SDK should be 33+

3. **Logcat Output:**
   Check for detailed error in: `logcat | grep flutter`

### Issue 2: "OnBackInvokedCallback is not enabled"

**Error Message:**
```
W/WindowOnBackDispatcher: OnBackInvokedCallback is not enabled for the application.
Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
```

**Solution:** ✅ Already fixed in AndroidManifest.xml

### Issue 3: Biometric Not Available on Device

**Symptoms:**
- BiometricLocalDataSource logs: "Biometric not available" or "No biometric types available"
- No native fingerprint dialog appears

**Possible Causes:**
1. Emulator doesn't have biometric hardware enabled
2. Physical device doesn't have fingerprint/face sensor
3. Biometric not enrolled in device

**Solutions:**

**For Emulator (Android Studio):**
1. Create emulator with API 30 or higher
2. In Extended Controls (⋮ menu):
   - Go to "Fingerprint" tab
   - Click "Simulate valid fingerprint"
   - Now the dialog will appear

**For Physical Device:**
1. Check device has biometric hardware (fingerprint/face)
2. Settings → Security → Biometric/Fingerprint enrollment
3. Enroll at least one biometric
4. Settings → Permissions → App permissions → ensure app has permission

## 🧪 Testing Biometric

### Test Steps:

1. **Manual Test in Settings:**
   ```
   Dashboard → Settings (gear icon) → Biometric section
   → Toggle ON
   → Native fingerprint dialog should appear
   ```

2. **Watching Logs:**
   ```bash
   flutter logs | grep "I/flutter\|E/flutter"
   ```
   Look for log entries starting with:
   - "Starting biometric authentication..."
   - "Available biometrics: ..."
   - "Launching native biometric dialog..."

3. **Test Flows:**
   - ✅ Setup: Toggle in Settings → verify dialog → scan finger
   - ✅ Unlock: Restart app → verify lock screen → scan finger
   - ✅ Fallback: Try unlocking → click fallback → Google Sign-In

## 📋 Permissions Checklist

### AndroidManifest.xml
- [x] `USE_BIOMETRIC` permission
- [x] `USE_FINGERPRINT` permission for backward compatibility
- [x] `enableOnBackInvokedCallback="true"` in application tag

### iOS (Info.plist)
- [x] `NSFaceIDUsageDescription`
- [x] `NSBiometricUsageDescription`

## 🔧 Debug Commands

```bash
# View biometric availability
adb shell pm dump io.flutter.app | grep -i biometric

# Monitor local_auth plugin logs
adb logcat | grep local_auth

# Full Flutter logs
flutter logs

# Rebuild and reinstall
flutter clean
flutter pub get
flutter run --verbose
```

## 📱 Device Specific Notes

### Samsung Devices
- Most have fingerprint/face recognition
- Should work out of the box after enrollment
- Check Knox security settings

### Google Pixel
- Usually has fingerprint + face unlock
- Face unlock may require proper lighting
- Verify in Settings → Security → Biometric

### Other Devices
- Verify biometric hardware exists
- Check device documentation
- Test with other biometric apps first

## ✅ Verification Checklist

Before submitting app to Play Store:

- [ ] BiometricSetupDialog appears after login
- [ ] Native fingerprint dialog launches when toggling in settings
- [ ] Fingerprint scan works (valid enrollment)
- [ ] Lock screen appears on app restart
- [ ] Google Sign-In fallback works
- [ ] Settings displays correct biometric type (Fingerprint/Face)
- [ ] Error messages clear and actionable
- [ ] Logs show proper flow (check Flutter logs)
- [ ] Permission checks pass
- [ ] AndroidManifest has all required attributes
- [ ] minSdk is 26+

---

For issues not listed here, check Flutter [`local_auth` plugin documentation](https://pub.dev/packages/local_auth)
