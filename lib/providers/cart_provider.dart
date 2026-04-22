// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'cart_provider.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  // We use a Map (Dictionary) where the Key is the product ID.
  // This makes it extremely fast to check if an item is already in the cart.
  final Map<String, CartItem> _items = {};

  // Getter to read the items safely
  Map<String, CartItem> get items => _items;

  // Calculate the total price of everything in the cart
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // The logic to add an item
  void addItem(String productId, String name, double price) {
    if (_items.containsKey(productId)) {
      // If it's already in the cart, just increase the quantity by 1
      _items[productId]!.quantity += 1;
    } else {
      // If it's brand new, add it to the map
      _items[productId] = CartItem(
        id: DateTime.now().toString(), // Generating a random unique ID
        name: name,
        price: price,
      );
    }
    // TELL FLUTTER TO REDRAW THE SCREENS!
    notifyListeners();
  }

  // Logic to clear the whole cart (e.g., after successful payment)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners(); // Tell the UI to redraw without this item!
  }
}