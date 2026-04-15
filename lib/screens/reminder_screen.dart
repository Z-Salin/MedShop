import 'package:flutter/material.dart';

// 1. The Data Model
class MedicineReminder {
  final String id;
  final String name;
  final String dosage;
  final TimeOfDay time;
  bool isActive;

  MedicineReminder({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.isActive = true, // Reminders are ON by default
  });
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // 2. Our local list of reminders
  final List<MedicineReminder> _reminders = [];

  // Controllers for the popup form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // 3. The function that opens the native clock interface
  Future<void> _pickTime(BuildContext context, StateSetter setModalState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    // If they picked a time, update the dialog's state
    if (picked != null && picked != _selectedTime) {
      setModalState(() {
        _selectedTime = picked;
      });
    }
  }

  // 4. The function that shows the "Add Reminder" popup
  void _showAddDialog() {
    // Clear old text before opening
    _nameController.clear();
    _dosageController.clear();
    _selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder gives the dialog its own 'setState'
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('New Reminder'),
              content: Column(
                mainAxisSize: MainAxisSize.min, // Shrinks the box to fit the content
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      prefixIcon: Icon(Icons.medication),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage (e.g., 1 Pill)',
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Time: ${_selectedTime.format(context)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _pickTime(context, setModalState),
                        icon: const Icon(Icons.access_time),
                        label: const Text('Pick Time'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Prevent saving if the name is empty
                    if (_nameController.text.isEmpty) return;

                    // Update the MAIN screen's state to add the item
                    setState(() {
                      _reminders.add(MedicineReminder(
                        id: DateTime.now().toString(),
                        name: _nameController.text,
                        dosage: _dosageController.text,
                        time: _selectedTime,
                      ));
                    });

                    // Close the popup
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      // 5. The list of created reminders
      body: _reminders.isEmpty
          ? const Center(
        child: Text('No reminders set. Tap + to add one!', style: TextStyle(color: Colors.grey, fontSize: 16)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: reminder.isActive ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.alarm,
                  color: reminder.isActive ? Colors.deepPurple : Colors.grey,
                ),
              ),
              title: Text(reminder.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('${reminder.dosage} • ${reminder.time.format(context)}'),

              // 6. The Toggle Switch AND Delete Button (UPDATED)
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: reminder.isActive,
                    activeColor: Colors.deepPurple,
                    onChanged: (bool value) {
                      setState(() {
                        reminder.isActive = value;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // Tell Flutter to remove this specific item and redraw
                      setState(() {
                        _reminders.removeAt(index);
                      });

                      // Show a quick confirmation pop-up
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${reminder.name} reminder deleted'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // 7. The Floating Action Button (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}