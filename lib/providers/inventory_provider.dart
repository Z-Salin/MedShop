import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  int stock;
  // --- NEW FIELDS ---
  final String expiryDate;
  final double discountPercentage;

  ProductModel({
    required this.id, required this.name, required this.imageUrl,
    required this.price, required this.stock,
    required this.expiryDate, required this.discountPercentage,
  });
}

class InventoryProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> get products => [..._products];

  InventoryProvider() {
    _listenToCloudInventory();
  }

  void _listenToCloudInventory() {
    FirebaseFirestore.instance.collection('inventory').snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        final data = doc.data();

        // This 'num' trick handles both integers (50) and doubles (50.0) flawlessly
        final num discountValue = data['discountPercentage'] ?? 0;
        final num priceValue = data['price'] ?? 0;

        return ProductModel(
          id: doc.id,
          name: data['name'] ?? 'Unknown Medicine',
          imageUrl: data['imageUrl'] ?? '',
          price: priceValue.toDouble(),
          stock: data['stock'] ?? 0,
          expiryDate: data['expiryDate'] ?? 'No Date',
          discountPercentage: discountValue.toDouble(), // Force it to double here
        );
      }).toList();

      print("Inventory Updated: ${_products.length} items synced."); // Debug log
      notifyListeners();
    });
  }

  // --- UPDATED: Now accepts Expiry Date ---
  Future<void> addProduct(String name, double price, int stock, String imageUrl, String expiryDate) async {
    await FirebaseFirestore.instance.collection('inventory').add({
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'expiryDate': expiryDate, // Save the expiry date!
      'discountPercentage': 0.0, // Always starts with 0% discount
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- NEW: Owner function to apply a discount ---
  Future<void> updateDiscount(String docId, double discount) async {
    await FirebaseFirestore.instance.collection('inventory').doc(docId).update({
      'discountPercentage': discount,
    });
  }

  Future<void> deleteProduct(String docId) async {
    await FirebaseFirestore.instance.collection('inventory').doc(docId).delete();
  }
}