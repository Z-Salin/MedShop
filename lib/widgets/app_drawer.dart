import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../providers/user_provider.dart'; // Import your provider class
import '../screens/upload_screen.dart';
import '../screens/reminder_screen.dart';
import '../screens/discount_screen.dart';
import '../screens/settings_screen.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // This single line grabs the role from the cloud!
    // It also automatically rebuilds the drawer if the role changes.
    final userRole = Provider.of<UserProvider>(context).role;
    bool isOwner = userRole == 'owner';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'MedShop ($userRole)', // Let's show the role here so you can see it
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),


          // --- SHARED MENU ITEMS ---
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () { /* Navigate to Home */ },
          ),

          // --- CUSTOMER ONLY ITEMS ---
          if (!isOwner) ...[
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload Prescription'),
              onTap: () {
                // 1. Close the drawer first
                Navigator.pop(context);
                // 2. Navigate to the new screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Reminder'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Discounts'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DiscountScreen()),
                );
              },
            ),
          ],

          // --- SHOP OWNER ONLY ITEMS ---
          if (isOwner) ...[
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Inventory'),
              onTap: () { /* Navigate to Inventory */ },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Verification'),
              onTap: () { /* Navigate to Verification */ },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Expiry Tracker'),
              onTap: () { /* Navigate to Expiry */ },
            ),
            ListTile(
              leading: const Icon(Icons.send_outlined),
              title: const Text('Orders'),
              onTap: () { /* Navigate to Orders */ },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Supplier'),
              onTap: () { /* Navigate to Supplier */ },
            ),
          ],

          // --- SHARED SETTINGS ---
          const Divider(), // A visual line separator
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}