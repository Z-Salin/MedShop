import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart'; // We use this to trigger the 'completeOrder' function!

class PendingOrdersScreen extends StatelessWidget {
  const PendingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      // NEW: Listen to Firebase for pending orders!
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'pending') // Only fetch pending!
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No pending orders!', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String email = data['userEmail'] ?? 'Unknown';
              final double total = (data['totalAmount'] ?? 0).toDouble();
              final List items = data['items'] ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.access_time, color: Colors.white),
                  ),
                  title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),

                  // Expand to see the items and the Complete button
                  children: [
                    ...items.map((item) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                        title: Text(item['name'] ?? 'Item'),
                        trailing: Text('Qty: ${item['quantity']}  x  \$${(item['price'] ?? 0).toStringAsFixed(2)}'),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Tell Firebase to change the status from 'pending' to 'completed'
                          await Provider.of<OrderProvider>(context, listen: false).completeOrder(doc.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order Completed & Moved to Bill Activity!'), backgroundColor: Colors.green),
                            );
                          }
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Mark as Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 48), // Makes the button stretch wide
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}