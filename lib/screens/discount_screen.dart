import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/discount_provider.dart'; // NEW: Imported our live data brain!

class DiscountScreen extends StatelessWidget {
  const DiscountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the live list of discounted items pushed by the Owner
    final sales = Provider.of<DiscountProvider>(context).discountedItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // If the Owner hasn't pushed any sales, show a nice empty message
      body: sales.isEmpty
          ? const Center(child: Text('No active sales right now. Check back later!', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.70,
        ),
        itemCount: sales.length, // Now dynamically tied to real data!
        itemBuilder: (context, index) {
          // Pass the specific item data to the card builder
          return _buildDiscountCard(context, sales[index]);
        },
      ),
    );
  }

  // Updated to accept the live 'DiscountItem' object instead of just an index number
  Widget _buildDiscountCard(BuildContext context, DiscountItem item) {
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
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Icon(Icons.medication_liquid, size: 60, color: Colors.orange),
                  ),
                ),
                const Spacer(),
                // Using live data for name and expiry
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Exp: ${item.expiryDate}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${item.originalPrice.toStringAsFixed(2)}', // Live original price
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          '\$${item.discountedPrice.toStringAsFixed(2)}', // Live discounted price
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16),
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
                          // Pushing the real sale item into the Cart
                          Provider.of<CartProvider>(context, listen: false).addItem(
                            item.id,
                            '${item.name} (Sale)',
                            item.discountedPrice,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Sale item added to cart!'),
                                duration: Duration(seconds: 1)
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
              '${item.discountPercentage}% OFF', // Live dynamic discount percentage!
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}