import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/inventory_provider.dart'; // UPDATED: Pointing to the real Inventory cloud brain

class DiscountScreen extends StatelessWidget {
  const DiscountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the inventory instead of the old discount provider
    final inventory = Provider.of<InventoryProvider>(context);

    // 2. FILTER: Only show products that actually have a discount set by the Owner
    final sales = inventory.products.where((p) => p.discountPercentage > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: sales.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active sales right now.', style: TextStyle(color: Colors.grey, fontSize: 18)),
            Text('Check back later!', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.70,
        ),
        itemCount: sales.length,
        itemBuilder: (context, index) {
          return _buildDiscountCard(context, sales[index]);
        },
      ),
    );
  }

  // UPDATED: Now accepts 'ProductModel' from the InventoryProvider
  Widget _buildDiscountCard(BuildContext context, ProductModel product) {
    // Logic: Calculate the actual price after the discount
    final double discountAmount = product.price * (product.discountPercentage / 100);
    final double finalPrice = product.price - discountAmount;

    return Stack(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(product.imageUrl, height: 60, fit: BoxFit.contain)
                        : const Icon(Icons.medication_liquid, size: 60, color: Colors.orange),
                  ),
                ),
                const Spacer(),
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Exp: ${product.expiryDate}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          '\$${finalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                        ),
                      ],
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_shopping_cart, size: 20, color: Colors.deepPurple),
                        onPressed: () {
                          // Add the DISCOUNTED price to the cart
                          Provider.of<CartProvider>(context, listen: false).addItem(
                            product.id,
                            '${product.name} (Sale)',
                            finalPrice,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sale item added to cart!'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),

        // The Red "OFF" Tag
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Text(
              '${product.discountPercentage.toInt()}% OFF',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}