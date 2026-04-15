import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for our toggle switches
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // Section 1: Preferences
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('PREFERENCES', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive order updates and reminders'),
            secondary: const Icon(Icons.notifications_active_outlined),
            activeColor: Colors.deepPurple,
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch to a dark theme'),
            secondary: const Icon(Icons.dark_mode_outlined),
            activeColor: Colors.deepPurple,
            value: _darkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
              });
              // Note: Actually changing the app's theme requires a ThemeProvider,
              // which we can add later if you want to make it fully functional!
            },
          ),

          const Divider(),

          // Section 2: General
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('GENERAL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Text('English (US)', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About MedShop'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}