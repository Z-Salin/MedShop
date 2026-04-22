import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data'; // NEW: Web-safe image handling
import '../providers/prescription_provider.dart';
import '../providers/user_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // 1. Web-Safe variables to store our photo
  Uint8List? _selectedImageBytes;
  String? _fileName;
  bool _isUploading = false; // Controls the loading spinner

  // 2. The tool that talks to the phone's camera/gallery
  final ImagePicker _picker = ImagePicker();

  // 3. Controller for any notes the user wants to add
  final TextEditingController _notesController = TextEditingController();

  // 4. The function that opens the camera or gallery (Web-Safe!)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      // Read as raw bytes so it works flawlessly on Chrome and Mobile
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _fileName = pickedFile.name;
      });
    }
  }

  // 5. The Real Cloud Submit Function
  Future<void> _submitPrescription() async {
    if (_selectedImageBytes == null || _fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first!')),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Grab the logged-in user's email
    final email = Provider.of<UserProvider>(context, listen: false).user?.email ?? 'Unknown_Customer';

    try {
      // Push the image to Firebase Storage and save the record to the Database
      await Provider.of<PrescriptionProvider>(context, listen: false).uploadPrescription(
          _selectedImageBytes!,
          _fileName!,
          email
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription submitted for pharmacist review!'), backgroundColor: Colors.green),
        );

        // Clear the form after success
        setState(() {
          _selectedImageBytes = null;
          _fileName = null;
          _notesController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
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
        title: const Text('Upload Prescription', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Need a restricted medicine?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade200, style: BorderStyle.solid),
              ),
              child: _selectedImageBytes != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                // Use Image.memory for bytes!
                child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
              )
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
                  icon: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                  label: const Text('Camera', style: TextStyle(color: Colors.deepPurple)),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, color: Colors.deepPurple),
                  label: const Text('Gallery', style: TextStyle(color: Colors.deepPurple)),
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
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitPrescription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit for Verification', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}