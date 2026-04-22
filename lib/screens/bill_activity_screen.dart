import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class BillActivityScreen extends StatelessWidget {
  const BillActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the completed orders from our Provider
    final completedOrders = Provider.of<OrderProvider>(context).completedOrders;

    // 2. Dynamically calculate the real revenue
    final totalRevenue = completedOrders.fold(0.0, (sum, order) => sum + order.total);

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
      body: Column(
        children: [
          // Live Summary Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              border: Border(bottom: BorderSide(color: Colors.deepPurple.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Orders', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text('${completedOrders.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Revenue', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text('\$${totalRevenue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),

          // The Live List of Bills
          Expanded(
            child: completedOrders.isEmpty
                ? const Center(child: Text('No completed bills yet.', style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedOrders.length,
              itemBuilder: (context, index) {
                final order = completedOrders[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Navigate to the Detailed Bill Screen with the REAL order data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillDetailScreen(orderData: order),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade50,
                        child: const Icon(Icons.receipt_long, color: Colors.green),
                      ),
                      title: Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${order.date} • ${order.items.length} items'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            order.status,
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Downloading Daily Summary as PDF...'), backgroundColor: Colors.deepPurple),
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
// UPDATED: DETAILED BILL SCREEN
// ==========================================
class BillDetailScreen extends StatelessWidget {
  final OrderModel orderData; // Now accepts our real OrderModel!

  const BillDetailScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${orderData.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Icon(Icons.check_circle, size: 80, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                      '\$${orderData.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)
                  ),
                  Text(
                    orderData.status.toUpperCase(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 2),
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
            _buildDetailRow('Date & Time:', orderData.date),
            _buildDetailRow('Customer:', orderData.customer),
            _buildDetailRow('Payment Method:', 'Credit Card ending in 4242'),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // LIVE Items Purchased List
            const Text('ITEMS PURCHASED', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),

            // We map through the actual items the customer bought!
            ...orderData.items.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.medication),
              title: Text(item.name),
              subtitle: Text('Qty: ${item.quantity}  x  \$${item.price.toStringAsFixed(2)}'),
              trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$${orderData.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sending ${orderData.id} to receipt printer...'), backgroundColor: const Color(0xFF00BFA5)),
          );
        },
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.print),
        label: const Text('Print Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

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