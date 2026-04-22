import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Notice we removed the unused cart_provider import!

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CUSTOMER: Sends cart to Owner
  // We use List<dynamic> so it automatically accepts whatever your Cart items are!
  Future<void> placeOrder(double total, List<dynamic> items, String userEmail) async {
    await _db.collection('orders').add({
      'userEmail': userEmail,
      'totalAmount': total,
      'status': 'pending',
      'items': items.map((item) => {
        // dynamic allows us to read these safely
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      }).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // OWNER: Marks order as completed/shipped
  Future<void> completeOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).update({'status': 'completed'});
  }
}