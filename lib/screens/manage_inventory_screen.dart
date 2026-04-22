import 'package:flutter/material.dart';

class ManageInventoryScreen extends StatefulWidget {
  const ManageInventoryScreen({super.key});

  @override
  State<ManageInventoryScreen> createState() => _ManageInventoryScreenState();
}

class _ManageInventoryScreenState extends State<ManageInventoryScreen> {
  // 1. ADVANCED DATA STRUCTURE: Grouped by Generic Name/Category
  final List<Map<String, dynamic>> _inventoryCategories = [
    {
      'category': 'Napa Extra 500mg',
      'batches': [
        {'id': 'B-101', 'price': 1.50, 'stock': 100, 'expiry': 'Oct 2026'},
        {'id': 'B-102', 'price': 1.60, 'stock': 50, 'expiry': 'Jan 2027'}, // Different price & expiry!
      ]
    },
    {
      'category': 'Vitamin C Zinc',
      'batches': [
        {'id': 'B-205', 'price': 2.50, 'stock': 85, 'expiry': 'Dec 2025'},
      ]
    },
    {
      'category': 'Beximco Cough Syrup',
      'batches': [
        {'id': 'B-310', 'price': 4.00, 'stock': 12, 'expiry': 'Aug 2024'}, // Low stock
      ]
    },
  ];

  // Controllers for adding a new batch
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  void _showAddBatchDialog() {
    _categoryController.clear();
    _priceController.clear();
    _stockController.clear();
    _expiryController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Medicine Batch'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Generic Name (e.g. Napa)',
                    border: OutlineInputBorder(),
                    helperText: 'Will group with existing if name matches',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (\$)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _expiryController,
                  decoration: const InputDecoration(labelText: 'Expiry Date (e.g. Mar 2027)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_categoryController.text.isEmpty || _priceController.text.isEmpty || _stockController.text.isEmpty) {
                  return;
                }

                setState(() {
                  String newCategory = _categoryController.text.trim();
                  Map<String, dynamic> newBatch = {
                    'id': 'B-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}', // Auto-generate an ID
                    'price': double.tryParse(_priceController.text) ?? 0.0,
                    'stock': int.tryParse(_stockController.text) ?? 0,
                    'expiry': _expiryController.text.isEmpty ? 'N/A' : _expiryController.text,
                  };

                  // Check if this category already exists
                  int existingIndex = _inventoryCategories.indexWhere(
                          (item) => item['category'].toString().toLowerCase() == newCategory.toLowerCase()
                  );

                  if (existingIndex >= 0) {
                    // Category exists! Add this new batch to its folder
                    _inventoryCategories[existingIndex]['batches'].add(newBatch);
                  } else {
                    // Create a brand new category folder
                    _inventoryCategories.add({
                      'category': newCategory,
                      'batches': [newBatch]
                    });
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Batch added successfully!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5), foregroundColor: Colors.white),
              child: const Text('Save Batch'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Inventory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        // Our Vibrant UI Gradient!
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _inventoryCategories.length,
        itemBuilder: (context, index) {
          final categoryItem = _inventoryCategories[index];
          final List batches = categoryItem['batches'];

          // Calculate total stock across all batches for this generic
          int totalStock = batches.fold(0, (sum, batch) => sum + (batch['stock'] as int));
          bool isLowStock = totalStock < 20;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            // The ExpansionTile creates the dropdown folder effect
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: isLowStock ? Colors.red.shade50 : Colors.blue.shade50,
                child: Icon(Icons.folder_open, color: isLowStock ? Colors.red : Colors.blue),
              ),
              title: Text(categoryItem['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text('Total Stock: $totalStock  •  Batches: ${batches.length}', style: TextStyle(color: isLowStock ? Colors.red : Colors.grey)),

              // These are the items inside the folder
              children: batches.map((batch) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(top: BorderSide(color: Colors.grey.shade200))
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 72, right: 16), // Indent to show hierarchy
                    title: Text('Batch ${batch['id']}  •  Exp: ${batch['expiry']}'),
                    subtitle: Text('Price: \$${batch['price'].toStringAsFixed(2)}  |  Stock: ${batch['stock']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () {
                        setState(() {
                          batches.remove(batch);
                          // If that was the last batch, remove the whole category folder
                          if (batches.isEmpty) {
                            _inventoryCategories.removeAt(index);
                          }
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBatchDialog,
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Batch', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}