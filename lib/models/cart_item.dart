// lib/models/cart_item.dart

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1, // Defaults to 1 when first added
  });
}