import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';
import '../providers/inventory_provider.dart';

class SupplierScreen extends StatelessWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supplierData = Provider.of<SupplierProvider>(context);
    final offers = supplierData.offers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Inbox', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: offers.isEmpty
          ? const Center(child: Text('No new offers from suppliers.', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];

          // We add a quick 40% markup to the wholesale price for the Customer Retail Price
          final suggestedRetail = offer.wholesalePrice * 1.4;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(offer.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                        child: const Text('NEW OFFER', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                      )
                    ],
                  ),
                  const Divider(),
                  Text('Quantity Offered: ${offer.quantity} units'),
                  Text('Wholesale Price: \$${offer.wholesalePrice.toStringAsFixed(2)} / unit'),
                  Text('Expiry Date: ${offer.expiryDate}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Reject just deletes the offer
                            supplierData.removeOffer(offer.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offer Rejected')));
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text('Reject', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Accept pushes the item into the Customer's Live Inventory!
                            Provider.of<InventoryProvider>(context, listen: false).addProduct(
                              offer.medicineName,
                              suggestedRetail, // 2. Automatically set retail price
                              offer.quantity,  // 3. Stock
                              'https://via.placeholder.com/150/E1BEE7/6200EA?text=Stock', // 4. Image
                              offer.expiryDate, // 5. NEW: Passing the Expiry Date from the supplier!
                            );

                            // Remove the offer from the inbox
                            supplierData.removeOffer(offer.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Stock Added to Inventory!'),
                                    backgroundColor: Colors.green
                                )
                            );
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Accept', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}