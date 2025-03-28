import 'package:faults/features/user_auth/presentation/pages/admin/componets/services.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/history.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/navbar.dart';
import 'package:flutter/material.dart';



class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0; // Track selected index

  // Pages list for navigation
  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const ServicesPage(),
    const SettingsPage(),
  ];

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.notifications,
              color: Colors.white,
              size: 30.0,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Only updates visible part
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex, // Pass the current index
        onItemTapped: _onItemTapped, // Handle tab switching
      ),
    );
  }
}

// Placeholder HomePage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Home Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
} 