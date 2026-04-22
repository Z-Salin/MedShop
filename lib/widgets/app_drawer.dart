import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/upload_screen.dart';
import '../screens/reminder_screen.dart';
import '../screens/discount_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/pending_orders_screen.dart';
import '../screens/supplier_screen.dart';

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
              'MedShop ($userRole)',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // --- SHARED MENU ITEMS ---
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              // Navigate to Home
              Navigator.pop(context);
            },
          ),

          // --- CUSTOMER ONLY ITEMS ---
          if (!isOwner) ...[
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload Prescription'),
              onTap: () {
                Navigator.pop(context);
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
                Navigator.pop(context);
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
                Navigator.pop(context);
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
              onTap: () {
                // Navigate to Inventory
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined, color: Colors.deepPurple),
              title: const Text('Pending Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PendingOrdersScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Supplier'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplierScreen()));
              },
            ),
          ],

          // --- SHARED SETTINGS ---
          const Divider(),
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