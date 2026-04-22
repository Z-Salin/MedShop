import 'package:flutter/material.dart';

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
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: isExpired ? Colors.red.shade100 : Colors.orange.shade100,
                      child: Icon(
                        isExpired ? Icons.delete_forever : Icons.access_time_filled,
                        color: isExpired ? Colors.red : Colors.orange,
                      ),
                    ),
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Batch: ${item['batch']}  •  Stock: ${item['stock']}'),
                        Text('Expiry Date: ${item['expiry']}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['status'],
                          style: TextStyle(
                            color: isExpired ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // A button for the owner to quickly apply a discount or remove stock
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isExpired ? 'Removed from database.' : 'Moved to Discount Sale screen!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isExpired ? Colors.red : Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(isExpired ? 'Discard' : 'Discount 50%'),
                        )
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