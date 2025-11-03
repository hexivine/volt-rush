import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      print('Failed to sign in anonymously: $e');
    }
  }
}
