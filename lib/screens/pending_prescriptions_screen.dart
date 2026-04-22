import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class PendingPrescriptionsScreen extends StatefulWidget {
  const PendingPrescriptionsScreen({super.key});

  @override
  State<PendingPrescriptionsScreen> createState() => _PendingPrescriptionsScreenState();
}

class _PendingPrescriptionsScreenState extends State<PendingPrescriptionsScreen> {
  final List<Map<String, dynamic>> _prescriptions = [
    {'id': 'RX-782', 'customer': 'Alice Johnson', 'date': 'Today, 2:15 PM'},
    {'id': 'RX-783', 'customer': 'Bob Brown', 'date': 'Today, 1:45 PM'},
    {'id': 'RX-784', 'customer': 'Charlie Davis', 'date': 'Yesterday, 10:30 AM'},
  ];

  // Controllers for our new popup form
  final TextEditingController _medicinesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _medicinesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // 1. The specific function for REJECTING a prescription
  void _rejectPrescription(int index) {
    final item = _prescriptions[index];
    setState(() {
      _prescriptions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Prescription ${item['id']} Rejected.'), backgroundColor: Colors.red),
    );
  }

  // 2. The NEW function that opens the pricing popup
  void _showApprovalDialog(int index) {
    final item = _prescriptions[index];
    _medicinesController.clear();
    _priceController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Process ${item['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${item['customer']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Review the photo, then enter the required medicines and total cost.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: _medicinesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Prescribed Medicines (e.g. Napa x2)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Price (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_priceController.text.isEmpty || _medicinesController.text.isEmpty) return;

                // Grab the inputted data
                final double finalPrice = double.tryParse(_priceController.text) ?? 0.0;
                final String medicinesList = _medicinesController.text;

                // Push this specific custom order to the Cart Provider!
                Provider.of<CartProvider>(context, listen: false).addItem(
                  'rx_${item['id']}',
                  'RX: $medicinesList',
                  finalPrice,
                );

                // Close the dialog
                Navigator.pop(context);

                // Remove from the pending list
                setState(() {
                  _prescriptions.removeAt(index);
                });

                // Show Success
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invoice sent to ${item['customer']}\'s cart!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Send Invoice to Customer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Prescriptions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: _prescriptions.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text('All caught up!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
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
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simulated Image Area
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
                              // Calls the updated Reject function
                              onPressed: () => _rejectPrescription(index),
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
                              // Calls our new popup dialog!
                              onPressed: () => _showApprovalDialog(index),
                              icon: const Icon(Icons.receipt_long, color: Colors.white),
                              label: const Text('Process', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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