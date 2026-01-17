import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Web Client ID from Google Cloud Console (required for Android to get idToken)
  // This is the client_type: 3 from google-services.json
  static const String _webClientId = '916801022458-1075t3021i26e0lphpm68dlc8vt152j7.apps.googleusercontent.com';
  
  static bool _isInitialized = false;
  GoogleSignInAccount? _currentAccount;
  
  /// Initialize the Google Sign-In service (should be called once at app startup)
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    try {
      log('[GoogleAuth] Initializing Google Sign-In...');
      log('[GoogleAuth] Platform: ${Platform.operatingSystem}');
      log('[GoogleAuth] Using serverClientId: $_webClientId');
      
      await _googleSignIn.initialize(
        serverClientId: Platform.isAndroid ? _webClientId : null,
      );
      
      _isInitialized = true;
      log('[GoogleAuth] Google Sign-In initialized successfully');
      
      // Listen to authentication events
      _googleSignIn.authenticationEvents.listen(
        (GoogleSignInAuthenticationEvent event) {
          log('[GoogleAuth] Auth event: ${event.runtimeType}');
          if (event is GoogleSignInAuthenticationEventSignIn) {
            _currentAccount = event.user;
            log('[GoogleAuth] User authenticated: ${event.user.email}');
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            _currentAccount = null;
            log('[GoogleAuth] User signed out');
          }
        },
        onError: (error) {
          log('[GoogleAuth] Auth event error: $error');
        },
      );
      
      // Try lightweight authentication first (if user previously signed in)
      try {
        log('[GoogleAuth] Attempting lightweight authentication...');
        final account = await _googleSignIn.attemptLightweightAuthentication();
        if (account != null) {
          _currentAccount = account;
          log('[GoogleAuth] Lightweight auth successful: ${account.email}');
        } else {
          log('[GoogleAuth] No previous session found');
        }
      } catch (e) {
        log('[GoogleAuth] Lightweight auth failed (expected if first time): $e');
      }
    } catch (e) {
      log('[GoogleAuth] Initialization error: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signInWithGoogle({String type = 'user'}) async {
    try {
      log('[GoogleAuth] Starting Google Sign-In flow...');
      
      // Ensure initialized
      await _ensureInitialized();
      
      GoogleSignInAccount? account = _currentAccount;
      
      // If no current account, need to authenticate
      if (account == null) {
        log('[GoogleAuth] No current account, checking supportsAuthenticate...');
        
        if (!_googleSignIn.supportsAuthenticate()) {
          log('[GoogleAuth] Platform does not support authenticate()');
          throw Exception('This platform does not support Google Sign-In authenticate method');
        }
        
        log('[GoogleAuth] Calling authenticate()...');
        try {
          account = await _googleSignIn.authenticate();
          _currentAccount = account;
          log('[GoogleAuth] authenticate() successful: ${account.email}');
        } catch (e) {
          log('[GoogleAuth] authenticate() failed: $e');
          // Provide more specific error messages
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('cancel')) {
            throw Exception('Sign-in was cancelled by user');
          } else if (errorStr.contains('network')) {
            throw Exception('Network error. Please check your internet connection.');
          } else if (errorStr.contains('developer') || errorStr.contains('configuration')) {
            throw Exception('App configuration error. Please contact support.');
          }
          rethrow;
        }
      } else {
        log('[GoogleAuth] Using existing account: ${account.email}');
      }

      // Get authentication tokens (only idToken is available in google_sign_in 7.x)
      log('[GoogleAuth] Getting authentication tokens...');
      final GoogleSignInAuthentication authentication = await account.authentication;

      final String? idToken = authentication.idToken;

      log('[GoogleAuth] Got idToken: ${idToken != null ? 'yes (${idToken.length} chars)' : 'NO'}');

      if (idToken == null) {
        log('[GoogleAuth] ERROR: Missing idToken - this usually means serverClientId is wrong or not set');
        throw Exception('Missing Google idToken. Please check OAuth configuration.');
      }

      // Create Firebase credential (only idToken is needed)
      log('[GoogleAuth] Creating Firebase credential...');
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // Sign in to Firebase
      log('[GoogleAuth] Signing in to Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Firebase');
      }

      log('[GoogleAuth] Firebase sign-in successful: ${user.email}');

      // Get FCM token
      String? fcmToken;
      try {
        fcmToken = await _messaging.getToken();
        log('[GoogleAuth] FCM Token obtained');
      } catch (e) {
        log('[GoogleAuth] Failed to get FCM token: $e');
      }

      // Call backend API to register/login the user
      log('[GoogleAuth] Calling backend API...');
      final response = await http.post(
        Uri.parse('https://api.thebeautyshop.io/user/auth/social'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'socialId': user.uid,
          'email': user.email,
          'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
          'profileImage': user.photoURL ?? '',
          'deviceToken': fcmToken ?? '',
          'type': type,
        }),
      );

      log('[GoogleAuth] Backend response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        log('[GoogleAuth] Sign-in complete!');
        return data;
      } else {
        log('[GoogleAuth] Backend error: ${response.body}');
        throw Exception('Backend API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      log('[GoogleAuth] Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      log('[GoogleAuth] Signing out...');
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentAccount = null;
      log('[GoogleAuth] Sign out successful');
    } catch (e) {
      log('[GoogleAuth] Sign out error: $e');
      rethrow;
    }
  }
  
  /// Disconnect completely (revokes access)
  Future<void> disconnect() async {
    try {
      log('[GoogleAuth] Disconnecting...');
      await _googleSignIn.disconnect();
      await _auth.signOut();
      _currentAccount = null;
      _isInitialized = false;
      log('[GoogleAuth] Disconnect successful');
    } catch (e) {
      log('[GoogleAuth] Disconnect error: $e');
      rethrow;
    }
  }
}
