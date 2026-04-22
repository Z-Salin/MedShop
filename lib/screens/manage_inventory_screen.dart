import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'dart:typed_data'; // NEW: For handling Web-Safe image bytes
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // NEW: Firebase Storage!

class ManageInventoryScreen extends StatefulWidget {
  const ManageInventoryScreen({super.key});

  @override
  State<ManageInventoryScreen> createState() => _ManageInventoryScreenState();
}

class _ManageInventoryScreenState extends State<ManageInventoryScreen> {
  // We keep this local list just for the nice UI folders, but the real data lives in Firebase now!
  final List<Map<String, dynamic>> _inventoryCategories = [];

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  void _showAddBatchDialog() {
    _categoryController.clear();
    _priceController.clear();
    _stockController.clear();
    _expiryController.clear();

    // Web-Safe variables for the image
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    bool isUploading = false; // To show a loading spinner

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while uploading
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Add Medicine Batch'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- THE WEB-SAFE IMAGE PICKER ---
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                          if (pickedFile != null) {
                            // Read as bytes! This works flawlessly on Chrome/Web and Mobile.
                            final bytes = await pickedFile.readAsBytes();
                            setDialogState(() {
                              selectedImageBytes = bytes;
                              selectedImageName = pickedFile.name;
                            });
                          }
                        },
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.deepPurple.shade200),
                          ),
                          child: selectedImageBytes != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            // Display the raw bytes
                            child: Image.memory(selectedImageBytes!, fit: BoxFit.cover),
                          )
                              : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.deepPurple),
                              SizedBox(height: 8),
                              Text('Tap to upload photo', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Generic Name (e.g. Napa)', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (\$)', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: _stockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: _expiryController, decoration: const InputDecoration(labelText: 'Expiry Date (e.g. Mar 2027)', border: OutlineInputBorder())),

                      // Show a spinner if we are talking to Firebase
                      if (isUploading) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        const Text('Uploading to Cloud...', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                      ]
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: isUploading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel')
                  ),
                  ElevatedButton(
                    onPressed: isUploading ? null : () async {
                      if (_categoryController.text.isEmpty || _priceController.text.isEmpty) return;

                      // 1. Lock the UI and show the spinner
                      setDialogState(() { isUploading = true; });

                      String finalImageUrl = 'https://via.placeholder.com/150/EEEEEE/9E9E9E?text=No+Img';

                      try {
                        // 2. FIREBASE STORAGE UPLOAD MAGIC
                        if (selectedImageBytes != null && selectedImageName != null) {
                          // Create a unique file path in the cloud
                          final storageRef = FirebaseStorage.instance
                              .ref()
                              .child('medicine_images/${DateTime.now().millisecondsSinceEpoch}_$selectedImageName');

                          // Upload the bytes
                          final uploadTask = await storageRef.putData(selectedImageBytes!);

                          // Get the secure web link!
                          finalImageUrl = await uploadTask.ref.getDownloadURL();
                        }

                        // 3. Save to Firestore (Database)
                        await Provider.of<InventoryProvider>(context, listen: false).addProduct(
                          _categoryController.text.trim(),
                          double.tryParse(_priceController.text) ?? 0.0,
                          int.tryParse(_stockController.text) ?? 0,
                          finalImageUrl,
                          _expiryController.text.trim(),// <--- We pass the secure Firebase link!
                        );

                        // Close the dialog and show success
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Cloud!'), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        setDialogState(() { isUploading = false; });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5), foregroundColor: Colors.white),
                    child: const Text('Save Batch'),
                  ),
                ],
              );
            }
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
      // We will update the list to read from Firebase next, but for now it's just a blank screen with the FAB
      body: const Center(
        child: Text('Click the + button to upload to Firebase!', style: TextStyle(color: Colors.grey, fontSize: 16)),
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