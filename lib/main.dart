import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'providers/user_provider.dart'; // Import your new class
import 'screens/login_screen.dart';
import 'widgets/app_drawer.dart';
import 'screens/dashboard_screens.dart';
import 'providers/cart_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MedShopApp(),
    ),
  );
}

class MedShopApp extends StatelessWidget {
  const MedShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Notice we don't pass the role here anymore!
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // 1. The Local State variable. It defaults to 0 (The Home Screen).
  int _selectedIndex = 0;

  // 2. A list of the screens we created in Step 1.
  // The order here MUST match the order of your BottomNavigationBar items!
  final List<Widget> _pages = [
    const HomeScreen(),
    const CartScreen(), // <--- This was changed!
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedShop'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // 2. Change the icon and label here!
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), // Changed from camera_alt
            label: 'Cart',                   // Changed from 'Scan'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}