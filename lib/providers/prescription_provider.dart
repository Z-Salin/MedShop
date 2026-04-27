import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http; // NEW: For talking to ImgBB

class PrescriptionProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // FirebaseStorage is completely gone!

  // CUSTOMER: Uploads an image to ImgBB instead of Google
  Future<void> uploadPrescription(Uint8List bytes, String userEmail) async {
    try {
      // 1. Convert the image bytes into a format ImgBB understands
      String base64Image = base64Encode(bytes);

      // 2. YOUR IMGBB KEY GOES HERE
      const String imgbbKey = '';
      final Uri url = Uri.parse('');

      // 3. Fire it off to their servers
      final response = await http.post(url, body: {
        'key': imgbbKey,
        'image': base64Image,
      });

      if (response.statusCode == 200) {
        // 4. Extract the secure image URL they generated
        final jsonResponse = jsonDecode(response.body);
        final String imageUrl = jsonResponse['data']['url'];

        // 5. Save that URL to our Google Database!
        await _db.collection('prescriptions').add({
          'userEmail': userEmail,
          'imageUrl': imageUrl,
          'status': 'pending',
          'items': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception('Image host rejected the file.');
      }
    } catch (e) {
      throw Exception('App Error: $e');
    }
  }

  // OWNER: Approves the prescription and attaches priced medicines to it
  Future<void> approvePrescription(String docId, List<Map<String, dynamic>> prescribedItems) async {
    await _db.collection('prescriptions').doc(docId).update({
      'status': 'approved',
      'items': prescribedItems,
    });
  }

  // CUSTOMER: Fetch approved items and mark as added to cart
  Future<List<Map<String, dynamic>>> fetchAndClearApproved(String userEmail) async {
    final query = await _db.collection('prescriptions')
        .where('userEmail', isEqualTo: userEmail)
        .where('status', isEqualTo: 'approved')
        .get();

    List<Map<String, dynamic>> itemsToAdd = [];

    for (var doc in query.docs) {
      final items = List<Map<String, dynamic>>.from(doc['items'] ?? []);
      itemsToAdd.addAll(items);
      await _db.collection('prescriptions').doc(doc.id).update({'status': 'in_cart'});
    }
    return itemsToAdd;
  }
}