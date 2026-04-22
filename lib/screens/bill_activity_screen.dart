import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillActivityScreen extends StatelessWidget {
  const BillActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      // NEW: We listen directly to the cloud for completed orders!
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'completed') // Only show finished bills
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
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No completed bills yet.', style: TextStyle(fontSize: 20, color: Colors.grey)),
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

              // Safely grab the data from Firebase
              final String email = data['userEmail'] ?? 'Unknown Customer';
              final double total = (data['totalAmount'] ?? 0).toDouble();
              final List items = data['items'] ?? [];

              // Format the timestamp if it exists
              String dateString = 'Recently';
              if (data['createdAt'] != null) {
                DateTime date = (data['createdAt'] as Timestamp).toDate();
                dateString = '${date.day}/${date.month}/${date.year}';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Total: \$${total.toStringAsFixed(2)}  •  $dateString'),
                  // This expands to show the exact items they bought!
                  children: items.map((item) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                      title: Text(item['name'] ?? 'Item'),
                      trailing: Text('Qty: ${item['quantity']}  x  \$${(item['price'] ?? 0).toStringAsFixed(2)}'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}