import 'package:flutter/material.dart';

class BillActivityScreen extends StatelessWidget {
  const BillActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data representing recent customer orders
    final List<Map<String, dynamic>> recentBills = [
      {'id': '#ORD-001', 'date': 'Today, 10:30 AM', 'items': 3, 'total': 12.50, 'status': 'Completed', 'customer': 'John Doe'},
      {'id': '#ORD-002', 'date': 'Today, 11:15 AM', 'items': 1, 'total': 4.00, 'status': 'Pending', 'customer': 'Jane Smith'},
      {'id': '#ORD-003', 'date': 'Yesterday, 4:45 PM', 'items': 5, 'total': 22.00, 'status': 'Completed', 'customer': 'Alice Johnson'},
      {'id': '#ORD-004', 'date': 'Yesterday, 6:20 PM', 'items': 2, 'total': 8.50, 'status': 'Completed', 'customer': 'Bob Brown'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6200EA), Color(0xFFB388FF)], // Vibrant Purple Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // A nice summary header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              border: Border(bottom: BorderSide(color: Colors.deepPurple.shade100)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Orders', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text('124', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total Revenue', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text('\$47.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),

          // The list of bills
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recentBills.length,
              itemBuilder: (context, index) {
                final bill = recentBills[index];
                final isCompleted = bill['status'] == 'Completed';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell( // NEW: Makes the whole card clickable
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Navigate to the Detailed Bill Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillDetailScreen(billData: bill),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                        child: Icon(
                          Icons.receipt_long,
                          color: isCompleted ? Colors.green : Colors.orange,
                        ),
                      ),
                      title: Text(bill['id'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${bill['date']} • ${bill['items']} items'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${bill['total'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            bill['status'],
                            style: TextStyle(
                              color: isCompleted ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // NEW: Floating button to download the summary
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Downloading Daily Summary as PDF...'),
              backgroundColor: Colors.deepPurple,
            ),
          );
        },
        backgroundColor: const Color(0xFF6200EA),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.download),
        label: const Text('Download Summary', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ==========================================
// NEW: DETAILED BILL SCREEN
// ==========================================
class BillDetailScreen extends StatelessWidget {
  final Map<String, dynamic> billData;

  const BillDetailScreen({super.key, required this.billData});

  @override
  Widget build(BuildContext context) {
    final isCompleted = billData['status'] == 'Completed';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${billData['id']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Header
            Center(
              child: Column(
                children: [
                  Icon(
                      isCompleted ? Icons.check_circle : Icons.pending,
                      size: 80,
                      color: isCompleted ? Colors.green : Colors.orange
                  ),
                  const SizedBox(height: 16),
                  Text(
                      '\$${billData['total'].toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)
                  ),
                  Text(
                    billData['status'].toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.green : Colors.orange,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Order Info
            const Text('ORDER DETAILS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            _buildDetailRow('Date & Time:', billData['date']),
            _buildDetailRow('Customer:', billData['customer']),
            _buildDetailRow('Payment Method:', 'Credit Card ending in 4242'),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Mock Items Purchased List
            const Text('ITEMS PURCHASED', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.medication),
              title: const Text('Napa Extra 500mg'),
              subtitle: const Text('Qty: 2  x  \$1.50'),
              trailing: const Text('\$3.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.medication_liquid),
              title: const Text('Beximco Cough Syrup'),
              subtitle: const Text('Qty: 1  x  \$4.00'),
              trailing: const Text('\$4.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$${billData['total'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ],
            ),
            const SizedBox(height: 80), // Padding for the floating button
          ],
        ),
      ),
      // NEW: Floating button to print the individual bill
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sending ${billData['id']} to receipt printer...'),
              backgroundColor: const Color(0xFF00BFA5), // Vibrant Teal
            ),
          );
        },
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.print),
        label: const Text('Print Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Helper widget for drawing neat rows of data
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ],
      ),
    );
  }
}