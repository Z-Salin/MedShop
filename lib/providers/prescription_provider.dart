import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class PrescriptionProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // CUSTOMER: Uploads an image to Firebase
  Future<void> uploadPrescription(Uint8List bytes, String fileName, String userEmail) async {
    // 1. Upload the physical image to Firebase Storage
    final ref = _storage.ref().child('prescriptions/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    await ref.putData(bytes);
    final imageUrl = await ref.getDownloadURL();

    // 2. Save the database record
    await _db.collection('prescriptions').add({
      'userEmail': userEmail,
      'imageUrl': imageUrl,
      'status': 'pending', // Starts as pending for the Owner to review
      'items': [], // Owner will fill this out later!
      'createdAt': FieldValue.serverTimestamp(),
    });
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
      // Grab the items the owner priced out
      final items = List<Map<String, dynamic>>.from(doc['items'] ?? []);
      itemsToAdd.addAll(items);

      // Update status so we don't add them to the cart twice!
      await _db.collection('prescriptions').doc(doc.id).update({'status': 'in_cart'});
    }
    return itemsToAdd;
  }
}