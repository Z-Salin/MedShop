import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class DiscountScreen extends StatelessWidget {
  const DiscountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      //  GridView for our discounted items
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.70,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildDiscountCard(context, index);
        },
      ),
    );
  }

  Widget _buildDiscountCard(BuildContext context, int index) {
    double originalPrice = 5.00 + index;
    double discountPrice = originalPrice * 0.8; // 20% off

    // "SALE" badge floating on top of the Card
    return Stack(
      children: [
        // The actual product card
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
                const Text('Cough Syrup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Beximco Pharma', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),

                // The Price Row with the crossed-out original price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          '\$${discountPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16),
                        ),
                      ],
                    ),

                    // Add to Cart Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_shopping_cart, size: 20, color: Colors.deepPurple),
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).addItem(
                            'p_sale_$index',
                            'Cough Syrup (Sale)',
                            discountPrice,
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

        // The Floating "20% OFF" Badge
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
            child: const Text(
              '20% OFF',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}