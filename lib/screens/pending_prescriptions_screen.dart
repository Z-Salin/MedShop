import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEW: For the live database stream
import '../providers/prescription_provider.dart'; // NEW: The cloud brain

class PendingPrescriptionsScreen extends StatefulWidget {
  const PendingPrescriptionsScreen({super.key});

  @override
  State<PendingPrescriptionsScreen> createState() => _PendingPrescriptionsScreenState();
}

class _PendingPrescriptionsScreenState extends State<PendingPrescriptionsScreen> {
  // Controllers for our pricing popup
  final TextEditingController _medicinesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _medicinesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // 1. REJECT: Updates the cloud status so it disappears from this list
  void _rejectPrescription(String docId) async {
    await FirebaseFirestore.instance.collection('prescriptions').doc(docId).update({
      'status': 'rejected',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription Rejected.'), backgroundColor: Colors.red),
      );
    }
  }

  // 2. PROCESS: Attaches medicines/prices and updates the cloud
  void _showApprovalDialog(String docId, String customerEmail) {
    _medicinesController.clear();
    _priceController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Process Prescription'),
          content: SingleChildScrollView( // Prevents keyboard overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: $customerEmail', style: const TextStyle(fontWeight: FontWeight.bold)),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_priceController.text.isEmpty || _medicinesController.text.isEmpty) return;

                final double finalPrice = double.tryParse(_priceController.text) ?? 0.0;
                final String medicinesList = _medicinesController.text;

                // Format the items exactly how the Cart/Order system expects them
                final prescribedItems = [{
                  'id': 'rx_${DateTime.now().millisecondsSinceEpoch}',
                  'name': 'RX: $medicinesList',
                  'price': finalPrice,
                  'quantity': 1,
                }];

                // Push to the Cloud Provider
                await Provider.of<PrescriptionProvider>(context, listen: false)
                    .approvePrescription(docId, prescribedItems);

                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invoice sent to $customerEmail\'s cart!'), backgroundColor: Colors.green),
                  );
                }
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
      // NEW: The Live StreamBuilder watches the database!
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prescriptions')
            .where('status', isEqualTo: 'pending')
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
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text('All caught up!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
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

              // Safely grab cloud data
              final String customerEmail = data['userEmail'] ?? 'Unknown Customer';
              final String imageUrl = data['imageUrl'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // REAL Image Area
                    Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)),
                    ),

                    // Details and Action Buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Uploaded by:', style: TextStyle(color: Colors.deepPurple.shade300, fontWeight: FontWeight.bold)),
                          Text(customerEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _rejectPrescription(doc.id), // Pass the Cloud ID!
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
                                  onPressed: () => _showApprovalDialog(doc.id, customerEmail), // Pass the Cloud ID!
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
          );
        },
      ),
    );
  }
}