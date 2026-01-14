import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<Map<String, dynamic>?> signInWithGoogle({String type = 'user'}) async {
    try {
      // Initialize GoogleSignIn if not already initialized
      await _googleSignIn.initialize();

      // Check if platform supports authenticate
      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception('This platform does not support authenticate method');
      }

      // Trigger the authentication flow and get the account
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      log('Google user: ${account.email}');

      // Get authentication tokens
      final GoogleSignInAuthentication authentication =
          await account.authentication;

      final String? idToken = authentication.idToken;

      if (idToken == null) {
        throw Exception('Missing Google idToken');
      }

      log('Got Google tokens');

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Firebase');
      }

      log('Firebase sign in successful: ${user.email}');

      // Get FCM token
      String? fcmToken;
      try {
        fcmToken = await _messaging.getToken();
        log('FCM Token: $fcmToken');
      } catch (e) {
        log('Failed to get FCM token: $e');
      }

      // Call backend API to register/login the user
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

      log('Backend API response status: ${response.statusCode}');
      log('Backend API response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'Backend API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      log('Google Sign In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      log('User signed out successfully');
    } catch (e) {
      log('Sign out error: $e');
      rethrow;
    }
  }
}
