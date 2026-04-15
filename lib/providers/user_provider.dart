import 'package:flutter/material.dart';

// ChangeNotifier allows this class to broadcast updates to the app
class UserProvider with ChangeNotifier {
  // By default, let's make them a customer
  String _role = 'customer';

  // A "getter" so other files can read the role
  String get role => _role;

  // A function to update the role and tell the app to redraw
  void setRole(String newRole) {
    _role = newRole;
    notifyListeners(); // This is the magic command that updates the UI!
  }
}