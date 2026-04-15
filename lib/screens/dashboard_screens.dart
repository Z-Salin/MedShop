import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/cart_provider.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'delivery_address_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<UserProvider>(context).role;
    final isOwner = role == 'owner';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: isOwner ? const _OwnerDashboard() : const _CustomerDashboard(),
      ),
    );
  }
}

// ==========================================
// 1. THE CUSTOMER E-COMMERCE VIEW
// ==========================================
class _CustomerDashboard extends StatelessWidget {
  const _CustomerDashboard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Selling Medicines',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 16),

        // THE CAROUSEL
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildCarouselCard(context, index);
            },
          ),
        ),

        const SizedBox(height: 32),

        const Text(
          'All Products',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 16),

        // THE PRODUCT GRID
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            return _buildProductCard(context, index);
          },
        ),
      ],
    );
  }

  // Helper widget for the horizontal carousel
  Widget _buildCarouselCard(BuildContext context, int index) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.medication_liquid, size: 60, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Napa Extra 500mg', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Fever & Pain Relief', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<CartProvider>(context, listen: false).addItem(
                      'p_napa_$index',
                      'Napa Extra 500mg',
                      1.50,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added Napa to cart!'), duration: Duration(seconds: 1)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add to Cart'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper widget for the vertical product grid
  Widget _buildProductCard(BuildContext context, int index) {
    // clickable!
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MedicineDetailScreen(name: "Vitamin C Zinc", price: "\$2.50")
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Icon(Icons.local_pharmacy, size: 50, color: Colors.teal)),
              const Spacer(),
              const Text('Vitamin C Zinc', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Square Pharma', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('\$2.50', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart, size: 20, color: Colors.deepPurple),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(
                        'p_vitc_$index',
                        'Vitamin C Zinc',
                        2.50,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Added Vitamin C to cart!'),
                            duration: Duration(seconds: 1)
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. THE OWNER MANAGEMENT VIEW
// ==========================================
class _OwnerDashboard extends StatelessWidget {
  const _OwnerDashboard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Store Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdminCard(Icons.warning_amber, 'Pending Prescriptions', Colors.red),
            _buildAdminCard(Icons.inventory, 'Manage Inventory', Colors.blue),
            _buildAdminCard(Icons.date_range, 'Expiring Soon', Colors.orange),
            _buildAdminCard(Icons.monetization_on, 'Today\'s Sales', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==========================================
// 3. CART SCREEN
// ==========================================
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    if (cart.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Your Cart is Empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final productId = cart.items.keys.toList()[index];
                final item = cart.items.values.toList()[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.medication, color: Colors.white),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Qty: ${item.quantity}  x  \$${item.price.toStringAsFixed(2)}'),

                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              Provider.of<CartProvider>(context, listen: false).removeItem(productId);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name} removed'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    cart.clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order Placed Successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Checkout', style: TextStyle(fontSize: 18)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 4. PROFILE SCREEN
// ==========================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<UserProvider>(context).role;
    final isOwner = role == 'owner';

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // --- PROFILE HEADER ---
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text('Zisan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Center(
          child: Text(
            isOwner ? 'Store Manager' : 'Customer Account',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
        const SizedBox(height: 32),

        // --- SETTINGS LIST ---
        const Divider(),
        ListTile(
          leading: const Icon(Icons.person_outline, color: Colors.deepPurple),
          title: const Text('Edit Profile'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.location_on_outlined, color: Colors.deepPurple),
          title: const Text('Delivery Addresses'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DeliveryAddressScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined, color: Colors.deepPurple),
          title: const Text('Settings'),
          subtitle: const Text('Theme, Notifications, & Language'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        const Divider(),

        // --- LOGOUT BUTTON ---
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false).clearCart();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Log Out', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 5. MEDICINE DETAIL SCREEN
// ==========================================
class MedicineDetailScreen extends StatelessWidget {
  final String name;
  final String price;

  const MedicineDetailScreen({super.key, required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication, size: 120, color: Colors.teal),
            ),
            const SizedBox(height: 32),
            Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(price, style: const TextStyle(fontSize: 24, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text(
              "Detailed description of the medicine goes here. This includes active ingredients, recommended dosage instructions, and potential side effects.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Dashboard", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }
}