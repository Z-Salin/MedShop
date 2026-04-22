import 'package:flutter/material.dart';

// The blueprint for a wholesale offer
class SupplierOffer {
  final String id;
  final String medicineName;
  final int quantity;
  final double wholesalePrice;
  final String expiryDate;

  SupplierOffer({
    required this.id,
    required this.medicineName,
    required this.quantity,
    required this.wholesalePrice,
    required this.expiryDate,
  });
}

class SupplierProvider with ChangeNotifier {
  // Mock data representing incoming offers from generic drug manufacturers
  final List<SupplierOffer> _offers = [
    SupplierOffer(id: 'SUP-001', medicineName: 'Amoxicillin 250mg', quantity: 500, wholesalePrice: 0.80, expiryDate: 'Dec 2027'),
    SupplierOffer(id: 'SUP-002', medicineName: 'Omeprazole 20mg', quantity: 200, wholesalePrice: 1.10, expiryDate: 'May 2026'),
    SupplierOffer(id: 'SUP-003', medicineName: 'Paracetamol 500mg', quantity: 1000, wholesalePrice: 0.50, expiryDate: 'Jan 2028'),
  ];

  List<SupplierOffer> get offers => [..._offers];

  // Function to remove an offer if the owner accepts or rejects it
  void removeOffer(String id) {
    _offers.removeWhere((offer) => offer.id == id);
    notifyListeners();
  }
}