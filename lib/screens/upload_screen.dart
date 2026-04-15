import 'dart:io'; // Required to handle files on the device
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // 1. The variable to store our photo
  File? _selectedImage;

  // 2. The tool that talks to the phone's camera/gallery
  final ImagePicker _picker = ImagePicker();

  // 3. Controller for any notes the user wants to add
  final TextEditingController _notesController = TextEditingController();

  // 4. The function that opens the camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    // Wait for the user to take a photo or pick one
    final XFile? pickedFile = await _picker.pickImage(source: source);

    // If they actually picked something, update our state
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 5. A mock submit function
  void _submitPrescription() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first!')),
      );
      return;
    }

    // In a real app, you would send _selectedImage and _notesController.text to Firebase here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prescription submitted for pharmacist review!')),
    );

    // Clear the form after submission
    setState(() {
      _selectedImage = null;
      _notesController.clear();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Prescription'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // SingleChildScrollView prevents errors when the keyboard pops up
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Need a restricted medicine?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a clear photo of your doctor\'s prescription. Our pharmacists will verify it and notify you when you can complete your order.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // --- THE IMAGE DISPLAY AREA ---
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              ),
              child: _selectedImage != null
              // If we have an image, show it!
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
              // If we don't, show a placeholder icon
                  : const Center(
                child: Icon(Icons.image_search, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // --- THE CAMERA / GALLERY BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- NOTES FIELD ---
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional Notes for Pharmacist (Optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // --- SUBMIT BUTTON ---
            ElevatedButton(
              onPressed: _submitPrescription,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit for Verification', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}