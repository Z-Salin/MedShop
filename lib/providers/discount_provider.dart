import 'package:flutter/material.dart';

class DiscountItem {
  final String id;
  final String name;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final String expiryDate;

  DiscountItem({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.expiryDate,
  });
}

class DiscountProvider with ChangeNotifier {
  final List<DiscountItem> _discountedItems = [];

  List<DiscountItem> get discountedItems => [..._discountedItems];

  void addDiscountItem(String name, double originalPrice, int percentage, String expiry) {
    // Calculate the new price based on the percentage
    double newPrice = originalPrice - (originalPrice * (percentage / 100));

    _discountedItems.add(
      DiscountItem(
        id: 'SALE-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
        name: name,
        originalPrice: originalPrice,
        discountedPrice: newPrice,
        discountPercentage: percentage,
        expiryDate: expiry,
      ),
    );
    notifyListeners(); // Tells the Customer's screen to update!
  }

  void removeDiscountItem(String id) {
    _discountedItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}