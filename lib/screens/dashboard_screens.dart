import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/inventory_provider.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'delivery_address_screen.dart';
import 'settings_screen.dart';
import 'manage_inventory_screen.dart';
import 'bill_activity_screen.dart';
import 'pending_prescriptions_screen.dart';
import 'expiring_soon_screen.dart';
import 'dart:io';
import '../providers/prescription_provider.dart';

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
// 1. THE CUSTOMER E-COMMERCE VIEW (UPDATED WITH SEARCH)
// ==========================================
class _CustomerDashboard extends StatefulWidget {
  const _CustomerDashboard();

  @override
  State<_CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<_CustomerDashboard> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- THE SEARCH BAR ---
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value; // Updates the grid in real-time!
            });
          },
          decoration: InputDecoration(
            hintText: 'Search for medicines...',
            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
            // Adds a clear button if they have typed something
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            )
                : null,
            filled: true,
            fillColor: Colors.deepPurple.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 32),

        const Text(
          'All Products',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 16),

        // THE LIVE PRODUCT GRID
        Consumer<InventoryProvider>(
          builder: (context, inventory, child) {
            // FILTER LOGIC: Match the search query against the product names
            final products = inventory.products.where((p) {
              return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            // 1. If the cloud is totally empty
            if (inventory.products.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No products currently in stock.', style: TextStyle(color: Colors.grey)),
              ));
            }

            // 2. If they searched for something that doesn't exist
            if (products.isEmpty) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('No medicines found for "$_searchQuery"', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ));
            }

            // 3. Display the filtered grid!
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.70,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildLiveProductCard(context, products[index]);
              },
            );
          },
        ),
      ],
    );
  }

  // Live Product Card
  Widget _buildLiveProductCard(BuildContext context, ProductModel product) {
    bool inStock = product.stock > 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MedicineDetailScreen(name: product.name, price: "\$${product.price.toStringAsFixed(2)}")
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
              // The Smart Medicine Picture (Handles Network & Local Files)
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrl.startsWith('http')
                    // If it starts with http, it's a web link (or future Firebase URL)
                        ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_pharmacy, size: 50, color: Colors.teal),
                    )
                    // If it doesn't, it's a local file from the owner's phone!
                        : Image.file(
                      File(product.imageUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('Stock: ${product.stock}', style: TextStyle(color: inStock ? Colors.grey : Colors.red, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  IconButton(
                    icon: Icon(Icons.add_shopping_cart, size: 20, color: inStock ? Colors.deepPurple : Colors.grey),
                    onPressed: inStock ? () {
                      Provider.of<CartProvider>(context, listen: false).addItem(
                        product.id,
                        product.name,
                        product.price,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Added ${product.name} to cart!'),
                            duration: const Duration(seconds: 1)
                        ),
                      );
                    } : null,
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
            _buildAdminCard(Icons.warning_amber, 'Pending Prescriptions', Colors.red, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PendingPrescriptionsScreen()),
              );
            }),
            _buildAdminCard(Icons.inventory, 'Manage Inventory', Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageInventoryScreen()),
              );
            }),
            _buildAdminCard(Icons.receipt_long, 'Bill Activity', Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BillActivityScreen()),
              );
            }),
            _buildAdminCard(Icons.date_range, 'Expiring Soon', Colors.orange, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExpiringSoonScreen()),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6200EA), Color(0xFFB388FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // --- THE PRESCRIPTION SYNC BUTTON ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: ElevatedButton.icon(
              onPressed: () async {
                final email = userProvider.user?.email ?? 'Unknown_Customer';

                // 1. Ask the cloud if the Owner approved anything for this email
                final newItems = await Provider.of<PrescriptionProvider>(context, listen: false)
                    .fetchAndClearApproved(email);

                if (!context.mounted) return;

                if (newItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new approved prescriptions yet!')),
                  );
                  return;
                }

                // 2. Dump the approved items directly into the local Cart!
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                for (var item in newItems) {
                  // Make sure this matches your CartProvider's exact addItem arguments!
                  cartProvider.addItem(
                    item['id'],
                    item['name'],
                    (item['price'] ?? 0).toDouble(),
                  );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully imported ${newItems.length} prescription(s)!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.downloading, color: Colors.white),
              label: const Text('Check for Approved Prescriptions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5), // Teal accent
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // --- THE REST OF YOUR NORMAL CART ---
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, i) {
                final cartItem = cart.items.values.toList()[i];
                final productId = cart.items.keys.toList()[i];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Text('${cartItem.quantity}x', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(cartItem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Total: \$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        cart.removeItem(productId);
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // --- CHECKOUT AREA ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    Text('\$${cart.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (cart.items.isNotEmpty) {
                        final email = userProvider.user?.email ?? 'Unknown_Customer';

                        // Pass the cart data to the cloud OrderProvider
                        Provider.of<OrderProvider>(context, listen: false).placeOrder(
                          cart.totalAmount,
                          cart.items.values.toList(),
                          email,
                        );

                        cart.clearCart();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order Sent to Owner for Approval!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                    child: const Text('Checkout Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
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

        const Divider(),
        ListTile(
          leading: const Icon(Icons.person_outline, color: Colors.deepPurple),
          title: const Text('Edit Profile'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.location_on_outlined, color: Colors.deepPurple),
          title: const Text('Delivery Addresses'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryAddressScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined, color: Colors.deepPurple),
          title: const Text('Settings'),
          subtitle: const Text('Theme, Notifications, & Language'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          },
        ),
        const Divider(),

        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
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
              decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
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