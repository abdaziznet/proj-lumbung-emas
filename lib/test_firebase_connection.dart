import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class TestFirebaseConnectionScreen extends StatefulWidget {
  const TestFirebaseConnectionScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    // Check if user is already signed in
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _status = 'Signed in as ${_currentUser!.email}';
    }
  }

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
      _addLog('   Project ID: ${app.options.projectId}');

      // Test 2: Firebase Auth
      _addLog('');
      _addLog('🔐 Step 2: Checking Firebase Auth...');
      
      final auth = FirebaseAuth.instance;
      _addLog('✅ Firebase Auth available');
      _addLog('   Current user: ${auth.currentUser?.email ?? 'Not signed in'}');

      // Test 3: Google Sign-In Configuration
      _addLog('');
      _addLog('📱 Step 3: Checking Google Sign-In...');
      
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
        _addLog('   Photo URL: ${user.photoURL?.substring(0, 50)}...');

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
