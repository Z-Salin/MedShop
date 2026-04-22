import 'package:flutter/material.dart';

// The blueprint for a product displayed to the Customer
class ProductModel {
  final String id;
  final String name;
  final String imageUrl; // NEW: To hold the medicine pictures!
  final double price;
  int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.stock,
  });
}

class InventoryProvider with ChangeNotifier {
  // Pre-loading with some mock data using placeholder images for the prototype
  final List<ProductModel> _products = [
    ProductModel(
      id: 'P-101',
      name: 'Napa Extra 500mg',
      imageUrl: 'https://via.placeholder.com/150/E1BEE7/6200EA?text=Napa',
      price: 1.50,
      stock: 150,
    ),
    ProductModel(
      id: 'P-102',
      name: 'Vitamin C Zinc',
      imageUrl: 'https://via.placeholder.com/150/C8E6C9/2E7D32?text=Vit+C',
      price: 2.50,
      stock: 85,
    ),
    ProductModel(
      id: 'P-103',
      name: 'Beximco Cough Syrup',
      imageUrl: 'https://via.placeholder.com/150/FFF9C4/F57F17?text=Syrup',
      price: 4.00,
      stock: 12,
    ),
  ];

  List<ProductModel> get products => [..._products];

  // We will wire this up to the Owner's Manage Inventory screen next!
  void addProduct(String name, double price, int stock, String imageUrl) {
    _products.add(
      ProductModel(
        id: 'P-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
        name: name,
        imageUrl: imageUrl,
        price: price,
        stock: stock,
      ),
    );
    notifyListeners();
  }
}