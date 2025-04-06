import 'package:flutter/material.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/services.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/history.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/navbar.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  // Pages list for navigation
  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const ServicesPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Home Page with Admin Dashboard title
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Admin Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
