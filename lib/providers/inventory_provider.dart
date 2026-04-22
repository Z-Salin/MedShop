import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEW: The Cloud Database!

// The blueprint for a product
class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
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
  List<ProductModel> _products = [];
  List<ProductModel> get products => [..._products];

  // When this provider boots up, it connects to Firebase immediately
  InventoryProvider() {
    _listenToCloudInventory();
  }

  // 1. READ FROM CLOUD: Live 24/7 Stream
  void _listenToCloudInventory() {
    FirebaseFirestore.instance
        .collection('inventory') // This is the name of our folder in the cloud
        .snapshots() // 'snapshots' means it listens for live updates constantly
        .listen((snapshot) {

      // Map the cloud data into our Flutter models
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel(
          id: doc.id, // Firebase automatically creates a unique ID for us!
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          price: (data['price'] ?? 0).toDouble(), // Safely handle decimals
          stock: data['stock'] ?? 0,
        );
      }).toList();

      notifyListeners(); // Tell the Customer's screen to redraw!
    });
  }

  // 2. WRITE TO CLOUD: Pushing a new batch to Firebase
  Future<void> addProduct(String name, double price, int stock, String imageUrl) async {
    // Instead of adding it to a local list, we push it to the cloud!
    await FirebaseFirestore.instance.collection('inventory').add({
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(), // Always good to track when it was added
    });

  }
}