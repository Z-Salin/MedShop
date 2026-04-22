import 'package:flutter/material.dart';
import '../models/cart_item.dart';

// 1. We define the blueprint of a single Order
class OrderModel {
  final String id;
  final String customer;
  final String date;
  final double total;
  final List<CartItem> items;
  String status; // 'Pending' or 'Completed'

  OrderModel({
    required this.id,
    required this.customer,
    required this.date,
    required this.total,
    required this.items,
    this.status = 'Pending',
  });
}

// 2. The Provider that manages the list of all orders
class OrderProvider with ChangeNotifier {
  final List<OrderModel> _orders = [];

  // Getters to filter the lists for the Owner's screens
  List<OrderModel> get pendingOrders => _orders.where((o) => o.status == 'Pending').toList();
  List<OrderModel> get completedOrders => _orders.where((o) => o.status == 'Completed').toList();
  List<OrderModel> get allOrders => [..._orders];

  // 3. Customer calls this to Checkout
  void placeOrder(double totalAmount, List<CartItem> cartItems) {
    final newOrder = OrderModel(
      id: '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}', // Generates a random 4-digit ID
      customer: 'Zisan', // We are hardcoding the current user's name for the prototype
      date: 'Just Now',
      total: totalAmount,
      items: cartItems,
    );

    _orders.insert(0, newOrder); // Adds it to the top of the list
    notifyListeners(); // Tells the Owner screens to update!
  }

  // 4. Owner calls this to Approve the order
  void confirmOrder(String orderId) {
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex >= 0) {
      _orders[orderIndex].status = 'Completed';
      notifyListeners();
    }
  }
}