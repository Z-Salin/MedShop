import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart'; // NEW: Pointing to the Cloud Brain!

class ExpiringSoonScreen extends StatelessWidget {
  const ExpiringSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expiring Soon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          // Alert Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Attention: You have items that require immediate action to prevent inventory loss.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // --- NEW: LIVE CLOUD CONSUMER ---
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, inventory, child) {
                if (inventory.products.isEmpty) {
                  return const Center(child: Text('Inventory is fully stocked and safe!', style: TextStyle(color: Colors.grey, fontSize: 16)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: inventory.products.length,
                  itemBuilder: (context, index) {
                    final product = inventory.products[index];

                    // PROTOTYPE HACK: If the string date contains an old year, flag it as Expired!
                    final bool isExpired = product.expiryDate.contains('2023') || product.expiryDate.contains('2024');
                    final String statusText = isExpired ? 'Expired' : 'Expiring Soon';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isExpired ? Colors.red : Colors.orange, width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // The Leading Avatar
                            CircleAvatar(
                              backgroundColor: isExpired ? Colors.red.shade100 : Colors.orange.shade100,
                              radius: 24,
                              child: Icon(
                                isExpired ? Icons.delete_forever : Icons.access_time_filled,
                                color: isExpired ? Colors.red : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // The Middle Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  // We use the first 4 letters of the Cloud ID as a fake "Batch Number"
                                  Text('Batch: B-${product.id.substring(0, 4).toUpperCase()}  •  Stock: ${product.stock}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  Text('Expiry: ${product.expiryDate}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // The Trailing Column (Status and Button)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: isExpired ? Colors.red : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    // --- 1. DISCARD LOGIC ---
                                    if (isExpired) {
                                      // Tell the cloud to delete the document completely
                                      await Provider.of<InventoryProvider>(context, listen: false).deleteProduct(product.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from Database.'), backgroundColor: Colors.red));
                                      }
                                      return;
                                    }

                                    // --- 2. DISCOUNT LOGIC ---
                                    final TextEditingController percentController = TextEditingController();

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Discount ${product.name}'),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('Enter the discount percentage below:'),
                                                const SizedBox(height: 16),
                                                TextField(
                                                  controller: percentController,
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Discount %',
                                                    border: OutlineInputBorder(),
                                                    suffixText: '%',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                            ElevatedButton(
                                              onPressed: () async {
                                                double percentage = double.tryParse(percentController.text) ?? 0.0;

                                                if (percentage > 0 && percentage <= 100) {
                                                  // Blast the new discount to the cloud!
                                                  await Provider.of<InventoryProvider>(context, listen: false).updateDiscount(product.id, percentage);

                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Applied $percentage% OFF!'), backgroundColor: Colors.green),
                                                    );
                                                  }
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                                              child: const Text('Apply Discount'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isExpired ? Colors.red : Colors.orange,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(80, 32),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: Text(isExpired ? 'Discard' : 'Discount'),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}