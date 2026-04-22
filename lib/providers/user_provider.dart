import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NEW: The Auth Engine

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user; // Holds the active Firebase user object
  String _role = 'customer'; // Default role

  User? get user => _user;
  String get role => _role;

  UserProvider() {
    // This is the magic listener! It watches the app 24/7.
    // If a user logs in, or closes the app and opens it later, this automatically triggers.
    _auth.authStateChanges().listen((User? authUser) {
      _user = authUser;

      // Simple role routing for our prototype:
      // We will make one specific email the "Owner" account.
      if (authUser != null && authUser.email == 'admin@medshop.com') {
        _role = 'owner';
      } else {
        _role = 'customer';
      }

      notifyListeners();
    });
  }

  // --- 1. REGISTER A NEW ACCOUNT ---
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Return null if it was perfectly successful
    } on FirebaseAuthException catch (e) {
      return e.message; // If it fails (e.g. password too short), return the error message
    }
  }

  // --- 2. LOGIN TO EXISTING ACCOUNT ---
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // --- 3. LOGOUT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }
}