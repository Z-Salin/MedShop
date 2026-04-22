import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/discount_provider.dart';

class ExpiringSoonScreen extends StatelessWidget {
  const ExpiringSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data representing medicines the system flagged as expiring soon
    final List<Map<String, dynamic>> expiringItems = [
      {'name': 'Beximco Cough Syrup', 'batch': 'B-310', 'stock': 12, 'expiry': 'Aug 2024', 'status': 'Expired'},
      {'name': 'Vitamin C Zinc', 'batch': 'B-205', 'stock': 85, 'expiry': 'Dec 2025', 'status': 'Expiring in 30 Days'},
      {'name': 'Napa Extra 500mg', 'batch': 'B-101', 'stock': 100, 'expiry': 'Jan 2026', 'status': 'Expiring in 60 Days'},
    ];

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

          // The List of Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expiringItems.length,
              itemBuilder: (context, index) {
                final item = expiringItems[index];
                final isExpired = item['status'] == 'Expired';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isExpired ? Colors.red : Colors.orange, width: 1.5),
                  ),
                  // FIX: Replaced ListTile with a robust Padding > Row layout to prevent overflows!
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

                        // The Middle Text (Title and Subtitles)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Batch: ${item['batch']}  •  Stock: ${item['stock']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              Text('Expiry: ${item['expiry']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // The Trailing Column (Status and Button)
                        Column(
                          mainAxisSize: MainAxisSize.min, // FIX: This specifically tells the column not to stretch!
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item['status'],
                              style: TextStyle(
                                color: isExpired ? Colors.red : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (isExpired) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from database.')));
                                  return;
                                }

                                final TextEditingController percentController = TextEditingController(text: '20');

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Discount ${item['name']}'),
                                      // FIX: Added SingleChildScrollView so the keyboard doesn't cause a layout overflow
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
                                          onPressed: () {
                                            int percentage = int.tryParse(percentController.text) ?? 0;

                                            if (percentage > 0 && percentage <= 100) {
                                              Provider.of<DiscountProvider>(context, listen: false)
                                                  .addDiscountItem(item['name'], 4.00, percentage, item['expiry']);

                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Applied $percentage% OFF!'), backgroundColor: Colors.green),
                                              );
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
            ),
          ),
        ],
      ),
    );
  }
}