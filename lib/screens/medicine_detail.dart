import 'package:flutter/material.dart';

class MedicineDetailScreen extends StatelessWidget {
  final String name;
  final String price;

  const MedicineDetailScreen({super.key, required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.medication, size: 150, color: Colors.deepPurple),
            Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(price, style: const TextStyle(fontSize: 22, color: Colors.green)),
            const SizedBox(height: 20),
            const Text("Detailed description of the medicine, side effects, and usage instructions go here."),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("Back to Dashboard"),
            )
          ],
        ),
      ),
    );
  }
}