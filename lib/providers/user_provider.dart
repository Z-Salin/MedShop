import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  String _role = 'customer'; // Default role

  User? get user => _user;
  String get role => _role;

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    // This watches Firebase 24/7. If someone logs in or out, this triggers!
    _auth.authStateChanges().listen((User? authUser) {
      _user = authUser;

      // --- THE PROTOTYPE HACK ---
      // If the logged-in email is exactly this, they get the keys to the store!
      if (authUser != null && authUser.email == 'admin@medshop.com') {
        _role = 'owner';
      } else {
        _role = 'customer'; // Everyone else is a customer
      }

      notifyListeners();
    });
  }

  // --- 1. REGISTER A NEW ACCOUNT ---
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the exact error to show on the screen
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