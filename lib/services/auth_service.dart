import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service handling sign-in, token refresh, and session persistence.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Sign in with Google and create/update user profile
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      // Store session token locally for offline access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', user.uid);
      await prefs.setString('refresh_token', googleAuth.accessToken ?? '');

      // Create or update user document
      await _db.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
        'provider': 'google',
      }, SetOptions(merge: true));
    }

    return user;
  }

  /// Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Register new user with email
  Future<User?> registerWithEmail(String email, String password, String displayName) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await _db.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'tier': 'free',
        'credits': 0,
      });
    }

    return user;
  }

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign out and clear local session
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    await prefs.remove('refresh_token');
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
