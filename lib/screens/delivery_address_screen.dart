import 'package:flutter/material.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  int _defaultAddressIndex = 0;

  final List<Map<String, String>> _addresses = [
    {
      'title': 'Home',
      'address': 'Savar, Dhaka',
      'phone': '+880 1712-345678'
    },
    {
      'title': 'University',
      'address': 'Daffodil Smart City, Ashulia, Savar',
      'phone': '+880 1712-345678'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Addresses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          final isDefault = _defaultAddressIndex == index;

          return Card(
            elevation: isDefault ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDefault ? Colors.deepPurple : Colors.transparent, width: 2),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _defaultAddressIndex = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: isDefault ? Colors.deepPurple : Colors.grey),
                            const SizedBox(width: 8),
                            Text(address['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8)),
                            child: const Text('DEFAULT', style: TextStyle(color: Colors.deepPurple, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(address['address']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Phone: ${address['phone']}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Address form goes here!')));
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add New Address'),
      ),
    );
  }
}