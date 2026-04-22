import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class PendingPrescriptionsScreen extends StatefulWidget {
  const PendingPrescriptionsScreen({super.key});

  @override
  State<PendingPrescriptionsScreen> createState() => _PendingPrescriptionsScreenState();
}

class _PendingPrescriptionsScreenState extends State<PendingPrescriptionsScreen> {
  // Mock data representing photos customers have uploaded
  final List<Map<String, dynamic>> _prescriptions = [
    {'id': 'RX-782', 'customer': 'Alice Johnson', 'date': 'Today, 2:15 PM'},
    {'id': 'RX-783', 'customer': 'Bob Brown', 'date': 'Today, 1:45 PM'},
    {'id': 'RX-784', 'customer': 'Charlie Davis', 'date': 'Yesterday, 10:30 AM'},
  ];

  // Function to handle the button clicks
  void _reviewPrescription(int index, bool isApproved) {
    final item = _prescriptions[index];

    // If approved, actually add it to the global CartProvider!
    if (isApproved) {
      Provider.of<CartProvider>(context, listen: false).addItem(
        'rx_${item['id']}', // A unique ID for this prescription
        'Prescription: ${item['id']}',
        15.00, // A mock price for the prescription items
      );
    }

    // Remove the item from the list
    setState(() {
      _prescriptions.removeAt(index);
    });

    // Show a success/rejection message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isApproved ? 'Prescription ${item['id']} Approved & Added to Cart!' : 'Prescription ${item['id']} Rejected.'),
        backgroundColor: isApproved ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Prescriptions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        // Keeping our vibrant theme!
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
      // If the list is empty, show a nice "All caught up" message
      body: _prescriptions.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text('All caught up!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text('No pending prescriptions to review.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _prescriptions.length,
        itemBuilder: (context, index) {
          final item = _prescriptions[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            clipBehavior: Clip.antiAlias, // Ensures the grey image box has rounded corners
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simulated Image Area (Where the camera photo would go)
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Customer Uploaded Photo', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                // Details and Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.deepPurple)),
                          Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Uploaded by: ${item['customer']}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _reviewPrescription(index, false),
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text('Reject', style: TextStyle(color: Colors.red, fontSize: 16)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _reviewPrescription(index, true),
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}