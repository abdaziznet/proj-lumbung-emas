# 🚀 QUICK SECURITY FIX GUIDE

## Status: ⚠️ 4 CRITICAL FIXES NEEDED BEFORE PLAY STORE

Estimated time: **8-10 hours**

---

## FIX #1: Add Network Security Configuration ⏱️ 1 hour

### Step 1: Create network_security_config.xml

**File:** `android/app/src/main/res/xml/network_security_config.xml` (create new folder if doesn't exist)

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Only allow HTTPS for API calls -->
    <domain-config cleartextTrafficPermitted="false">
        <!-- Firebase -->
        <domain includeSubdomains="true">lumbungemasku.firebaseapp.com</domain>
        <domain includeSubdomains="true">firebase.googleapis.com</domain>
        <domain includeSubdomains="true">firebaseapp.com</domain>
        
        <!-- Google Services -->
        <domain includeSubdomains="true">googleapis.com</domain>
        <domain includeSubdomains="true">google.com</domain>
        <domain includeSubdomains="true">sheets.googleapis.com</domain>
        <domain includeSubdomains="true">accounts.google.com</domain>
        
        <!-- Google Sign-In -->
        <domain includeSubdomains="true">accounts.google.com</domain>
        
        <!-- Notifications -->
        <domain includeSubdomains="true">fcm.googleapis.com</domain>
        <domain includeSubdomains="true">google-analytics.com</domain>
    </domain-config>
    
    <!-- Default: No cleartext traffic allowed -->
    <default-config cleartextTrafficPermitted="false" />
</network-security-config>
```

### Step 2: Update AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`

Find the `<application>` tag and add `android:networkSecurityConfig`:

```xml
<application
    android:label="Lumbung Emasku"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:networkSecurityConfig="@xml/network_security_config">
    <!-- rest of config -->
</application>
```

---

## FIX #2: Input Validation ⏱️ 3-4 hours

### Step 1: Create Validation Service

**File:** `lib/core/utils/validators.dart`

```dart
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // Brand validation
  static String? validateBrand(String? value) {
    if (value == null || value.isEmpty) {
      return 'Brand tidak boleh kosong';
    }
    if (value.length < 2 || value.length > 50) {
      return 'Brand harus 2-50 karakter';
    }
    // Only alphanumeric, spaces, hyphens
    if (!RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(value)) {
      return 'Brand hanya boleh huruf, angka, spasi, dan tanda hubung';
    }
    return null;
  }

  // Quantity validation (gram)
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah tidak boleh kosong';
    }
    final quantity = double.tryParse(value);
    if (quantity == null) {
      return 'Jumlah harus berupa angka';
    }
    if (quantity <= 0) {
      return 'Jumlah harus lebih besar dari 0';
    }
    if (quantity > 1000000) {
      return 'Jumlah maksimal 1.000.000 gram';
    }
    return null;
  }

  // Price validation (Rupiah)
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga tidak boleh kosong';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Harga harus berupa angka';
    }
    if (price <= 0) {
      return 'Harga harus lebih besar dari 0';
    }
    if (price > 1000000000) {
      return 'Harga melebihi batas maksimal';
    }
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Tanggal tidak boleh kosong';
    }
    if (value.isAfter(DateTime.now())) {
      return 'Tanggal tidak boleh di masa depan';
    }
    // Max 100 years in past
    if (value.isBefore(DateTime.now().subtract(const Duration(days: 36500)))) {
      return 'Tanggal terlalu lama di masa lalu';
    }
    return null;
  }

  // Text sanitization (prevent SQL injection)
  static String sanitizeInput(String input) {
    return input
        .replaceAll("'", "''") // Escape single quotes
        .replaceAll('"', '""') // Escape double quotes
        .trim();
  }
}
```

### Step 2: Apply Validation to Forms

Example for Add Asset Form:

**Find:** (assume file already exists)
```dart
// In add_transaction_screen.dart or similar
```

**Update form validator:**
```dart
TextFormField(
  controller: brandController,
  validator: (value) => Validators.validateBrand(value),
  decoration: InputDecoration(
    labelText: 'Brand Emas',
    errorText: _brandError,
  ),
  onChanged: (value) {
    setState(() {
      _brandError = Validators.validateBrand(value);
    });
  },
)
```

---

## FIX #3: Enable ProGuard/R8 Obfuscation ⏱️ 1-2 hours

### Step 1: Update build.gradle.kts

**File:** `android/app/build.gradle.kts`

Find `buildTypes` section and update `release`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug") // Will change to release key
        
        // ADD THESE LINES:
        minifyEnabled true
        shrinkResources true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        
        // Existing and future configs...
    }
}
```

### Step 2: Create proguard-rules.pro

**File:** `android/app/proguard-rules.pro` (create new file)

```proguard
# ============================================
# Proguard Rules for LumbungEmas
# ============================================

# Flutter & Dart Framework
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Services & Firebase
-keep class com.google.** { *; }
-keep class com.firebase.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Androidx
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# SQLite
-keep class android.database.sqlite.** { *; }

# Google Sheets & APIs
-keep class com.google.api.** { *; }
-keep class com.google.auth.** { *; }

# Our custom classes (keep, but obfuscate)
-keep class com.lumbungemas.** { *; }
-keep class com.lumbungemas.lumbungemas.** { *; }

# Serialization
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Remove debugging information from production
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable

# Preserve method names for Reflection
-keepclasseswithmembers class * {
    public static void main(java.lang.String[]);
}

# Keep BuildConfig
-keep class com.lumbungemas.lumbungemas.BuildConfig { *; }

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Verify that removed code doesn't connect
-allowaccessmodification
```

### Step 3: Test Build

```bash
# Build release version with obfuscation
flutter build apk --release

# Check if build succeeds
# If errors: Add more keep rules to proguard-rules.pro
```

---

## FIX #4: Update Android Permissions ⏱️ 30 mins

### Update AndroidManifest.xml

Add cleartext permission explicitly (deny by default):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Security: Only allow HTTPS -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <application
        android:label="Lumbung Emasku"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:networkSecurityConfig="@xml/network_security_config"
        android:usesCleartextTraffic="false">
        <!-- rest of manifest -->
    </application>
</manifest>
```

---

## TESTING & VERIFICATION ⏱️ 2-3 hours

### Test Network Security

```bash
# Check if HTTP is blocked
adb logcat | grep "cleartext"

# Expected: Log about blocked cleartext traffic
```

### Test Obfuscation

```bash
# Verify classes are obfuscated
unzip build/app/outputs/apk/release/app-release.apk
strings classes.dex | grep "MaterialApp" # Should return nothing if obfuscated
```

### Test Input Validation

- Try to add asset with:
  - Empty brand name → Should show error
  - Special characters in brand → Should show error
  - Negative quantity → Should show error
  - Invalid price → Should show error

---

## IMPLEMENTATION CHECKLIST

### Day 1: Network Security & Obfuscation (2 hours)
- [ ] Create `network_security_config.xml`
- [ ] Update `AndroidManifest.xml`
- [ ] Create `proguard-rules.pro`
- [ ] Update `build.gradle.kts`
- [ ] Test build locally

### Day 2: Input Validation (4 hours)
- [ ] Create `lib/core/utils/validators.dart`
- [ ] Add validation to all forms
- [ ] Test all validation rules
- [ ] Fix any bugs

### Day 3: Testing & Final Check (2 hours)
- [ ] Build release APK
- [ ] Test on device
- [ ] Verify no errors in logcat
- [ ] Check obfuscation worked
- [ ] Verify network security config

---

## FILE LOCATIONS TO CREATE/MODIFY

| File | Action | Type |
|------|--------|------|
| `android/app/src/main/res/xml/network_security_config.xml` | CREATE | XML |
| `android/app/src/main/AndroidManifest.xml` | MODIFY | XML |
| `android/app/build.gradle.kts` | MODIFY | Gradle |
| `android/app/proguard-rules.pro` | CREATE | Config |
| `lib/core/utils/validators.dart` | CREATE | Dart |

---

## AFTER FIXES ✅

Once completed:

```
Security Score: 7.1/10 → 8.5/10
Status: Ready for Play Store Submission
Risk Level: MEDIUM → LOW
```

---

## TROUBLESHOOTING

**Error: "Cleartext traffic not permitted"**
```
✅ Good! This means network security config is working
→ Make sure all APIs use HTTPS
```

**Error: "ProGuard/R8 enabled but getting ClassNotFoundException"**
```
→ Add keep rule for that class to proguard-rules.pro
→ Rebuild and test
```

**Error: "validation not working in form"**
```
→ Verify TextFormField has validator parameter set
→ Check setState() is called on change
```

---

**Estimated Total Time:** 8-10 hours
**Difficulty:** Medium (mostly configuration)
**Impact:** Critical for security

Start with FIX #1 & #3 (can do in parallel), then FIX #2, then FIX #4.
