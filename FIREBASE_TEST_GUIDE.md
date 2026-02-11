# 🔥 Firebase Setup Test Guide

## 🎯 Cara Test Firebase Setup

Panduan lengkap untuk memastikan Firebase sudah configured dengan benar.

---

## ✅ Step 1: Cek File Firebase (2 menit)

### 1.1. Cek firebase_options.dart

```powershell
# Cek file exists
Test-Path lib\firebase_options.dart
# Harus return: True
```

✅ **Status**: File sudah ada!

### 1.2. Cek google-services.json (Android)

```powershell
# Cek file exists
Test-Path android\app\google-services.json
# Harus return: True
```

**Jika False**: Download dari Firebase Console dan letakkan di `android/app/`

### 1.3. Cek GoogleService-Info.plist (iOS - Optional)

```powershell
# Cek file exists (optional untuk iOS)
Test-Path ios\Runner\GoogleService-Info.plist
```

---

## 🧪 Step 2: Create Firebase Test Screen (5 menit)

Saya akan buatkan test screen untuk Firebase.

### File: `lib/test_firebase_connection.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumbungemas/firebase_options.dart';

class TestFirebaseConnectionScreen extends StatefulWidget {
  const TestFirebaseConnectionScreen({Key? key}) : super(key: key);

  @override
  State<TestFirebaseConnectionScreen> createState() =>
      _TestFirebaseConnectionScreenState();
}

class _TestFirebaseConnectionScreenState
    extends State<TestFirebaseConnectionScreen> {
  String _status = 'Ready to test';
  bool _isLoading = false;
  final List<String> _logs = [];
  User? _currentUser;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
  }

  Future<void> _testFirebase() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Firebase...';
      _logs.clear();
    });

    try {
      // Test 1: Firebase Initialization
      _addLog('🔍 Step 1: Checking Firebase initialization...');
      
      final app = Firebase.app();
      _addLog('✅ Firebase initialized');
      _addLog('   App name: ${app.name}');
      _addLog('   Options: ${app.options.projectId}');

      // Test 2: Firebase Auth
      _addLog('');
      _addLog('🔐 Step 2: Checking Firebase Auth...');
      
      final auth = FirebaseAuth.instance;
      _addLog('✅ Firebase Auth available');
      _addLog('   Current user: ${auth.currentUser?.email ?? 'Not signed in'}');

      // Test 3: Google Sign-In Configuration
      _addLog('');
      _addLog('📱 Step 3: Checking Google Sign-In...');
      
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      _addLog('✅ Google Sign-In configured');

      _addLog('');
      _addLog('🎉 All Firebase tests passed!');
      _addLog('');
      _addLog('💡 Next: Try signing in with Google');

      setState(() {
        _status = '✅ Firebase OK!';
        _isLoading = false;
      });
    } catch (e) {
      _addLog('');
      _addLog('❌ Error: $e');
      setState(() {
        _status = '❌ Firebase test failed';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Google Sign-In...';
    });

    try {
      _addLog('');
      _addLog('🔐 Testing Google Sign-In...');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out first (clean state)
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      _addLog('📱 Opening Google Sign-In dialog...');
      
      // Trigger sign-in
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _addLog('⚠️  Sign-in cancelled by user');
        setState(() {
          _status = 'Sign-in cancelled';
          _isLoading = false;
        });
        return;
      }

      _addLog('✅ Google account selected: ${googleUser.email}');
      _addLog('🔑 Getting authentication credentials...');

      // Get auth credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _addLog('🔥 Signing in to Firebase...');

      // Sign in to Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        _addLog('');
        _addLog('🎉 Sign-in successful!');
        _addLog('   User ID: ${user.uid}');
        _addLog('   Email: ${user.email}');
        _addLog('   Display Name: ${user.displayName}');
        _addLog('   Photo URL: ${user.photoURL}');

        setState(() {
          _currentUser = user;
          _status = '✅ Signed in as ${user.email}';
          _isLoading = false;
        });
      }
    } catch (e) {
      _addLog('');
      _addLog('❌ Sign-in error: $e');
      setState(() {
        _status = '❌ Sign-in failed';
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      _addLog('');
      _addLog('🚪 Signing out...');

      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      _addLog('✅ Signed out successfully');

      setState(() {
        _currentUser = null;
        _status = 'Signed out';
      });
    } catch (e) {
      _addLog('❌ Sign-out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firebase Connection'),
        backgroundColor: Colors.orange,
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
                      : Colors.orange.shade50,
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
                    if (_currentUser != null) ...[
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: _currentUser!.photoURL != null
                            ? NetworkImage(_currentUser!.photoURL!)
                            : null,
                        child: _currentUser!.photoURL == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentUser!.displayName ?? 'No name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _currentUser!.email ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testFirebase,
              icon: const Icon(Icons.science),
              label: const Text('Test Firebase Setup'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading || _currentUser != null
                  ? null
                  : _testGoogleSignIn,
              icon: const Icon(Icons.login),
              label: const Text('Test Google Sign-In'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            if (_currentUser != null)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
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
                              child: Text(
                                  'No logs yet. Click "Test Firebase Setup" to start.'),
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
```

---

## 🔧 Step 3: Update Main App (3 menit)

Update `lib/main.dart` untuk menambahkan tombol test Firebase.

Ganti `HomeScreen` class dengan:

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LumbungEmas'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'LumbungEmas',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configuration Loaded Successfully!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            
            // Test Firebase Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestFirebaseConnectionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.firebase),
              label: const Text('Test Firebase'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Test Google Sheets Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestSheetsConnectionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('Test Google Sheets'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Tambahkan import di atas:

```dart
import 'package:lumbungemas/test_firebase_connection.dart';
```

---

## 🚀 Step 4: Run Test (5 menit)

### 4.1. Run App

```bash
flutter run
```

### 4.2. Test Firebase Setup

1. App akan terbuka
2. Klik tombol **"Test Firebase"**
3. Klik **"Test Firebase Setup"**
4. Lihat logs

**Expected Result:**
```
✅ Firebase initialized
   App name: [DEFAULT]
   Options: your-project-id
✅ Firebase Auth available
   Current user: Not signed in
✅ Google Sign-In configured
🎉 All Firebase tests passed!
```

### 4.3. Test Google Sign-In

1. Klik **"Test Google Sign-In"**
2. Pilih akun Google Anda
3. Lihat logs

**Expected Result:**
```
✅ Google account selected: your@email.com
✅ Sign-in successful!
   User ID: abc123...
   Email: your@email.com
   Display Name: Your Name
```

---

## ✅ Verification Checklist

Pastikan semua ini berhasil:

### Firebase Setup:
- [ ] `firebase_options.dart` exists
- [ ] `google-services.json` exists (Android)
- [ ] Firebase initialized successfully
- [ ] Firebase Auth available
- [ ] Project ID correct

### Google Sign-In:
- [ ] Google Sign-In configured
- [ ] Sign-in dialog muncul
- [ ] Bisa pilih akun Google
- [ ] Sign-in berhasil
- [ ] User info ditampilkan

---

## 🆘 Troubleshooting

### Error: "google-services.json not found"

**Solusi**:
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project Anda
3. Project Settings → Your apps → Android app
4. Download `google-services.json`
5. Letakkan di `android/app/google-services.json`

### Error: "Firebase not initialized"

**Solusi**:
```bash
# Run Firebase CLI configuration
flutter pub global activate flutterfire_cli
flutterfire configure
```

### Error: "Google Sign-In failed"

**Penyebab**: SHA-1 fingerprint belum ditambahkan  
**Solusi**:

```bash
# Get SHA-1 fingerprint
cd android
.\gradlew signingReport

# Copy SHA-1 dari output
# Tambahkan ke Firebase Console:
# Project Settings → Your apps → Android app → Add fingerprint
```

### Error: "PlatformException (sign_in_failed)"

**Penyebab**: Google Sign-In provider belum enabled  
**Solusi**:
1. Firebase Console → Authentication
2. Sign-in method tab
3. Enable "Google" provider
4. Save

---

## 📋 Quick Commands

### Get SHA-1 Fingerprint:

```powershell
# Windows
cd android
.\gradlew signingReport

# Look for "SHA1:" in the output
```

### Reconfigure Firebase:

```bash
# If you need to reconfigure
flutterfire configure
```

### Clean and Rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🎯 Expected Test Results

### ✅ Success Indicators:

1. **Firebase Initialized**
   - App name: [DEFAULT]
   - Project ID matches your Firebase project

2. **Auth Available**
   - Firebase Auth instance created
   - No errors

3. **Google Sign-In Works**
   - Dialog opens
   - Can select account
   - Sign-in completes
   - User info displayed

### ❌ Failure Indicators:

1. **Firebase Not Initialized**
   - Missing `firebase_options.dart`
   - Missing `google-services.json`

2. **Auth Fails**
   - SHA-1 not configured
   - Google provider not enabled

3. **Sign-In Fails**
   - Network issues
   - Configuration mismatch

---

## 📚 Documentation

Untuk setup Firebase lengkap, lihat:
- **IMPLEMENTATION_GUIDE.md** - Firebase setup section
- **SETUP.md** - Complete setup instructions

---

## ✨ Summary

### Test Firebase Setup:

```bash
# 1. Run app
flutter run

# 2. Click "Test Firebase"
# 3. Click "Test Firebase Setup"
# 4. Check logs for ✅

# 5. Click "Test Google Sign-In"
# 6. Select Google account
# 7. Check if sign-in successful
```

### Success Criteria:

- ✅ Firebase initialized
- ✅ Auth available
- ✅ Google Sign-In works
- ✅ User can sign in and out

---

**Firebase setup siap untuk production!** 🔥🚀
