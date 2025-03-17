import 'package:faults/features/user_auth/presentation/pages/admin.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/history.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/services.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0; // Tracks the selected index for the navbar

  // Handle navigation when an item is tapped
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Prevents reloading the same page

    if (index == 0) {
      // Navigate to Admin Page when clicking Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      );
    } else if (index == 1) {
      // Navigate to History Page separately
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HistoryPage()), // Remove 'const'
      );
    } else if (index == 2) {
      // Navigate to Services Page separately
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ServicesPage()), // Remove 'const'
      );
    } else if (index == 3) {
      // Navigate to Settings Page separately
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()), // Remove 'const'
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // You can put the content of each page here
        child: Text('Selected Index: $_selectedIndex'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Current selected index
        onTap: _onItemTapped, // Callback when an item is tapped
        type: BottomNavigationBarType.fixed, // Fixed style for more than 3 items
        selectedItemColor: Colors.green, // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        backgroundColor: Colors.white, // White background color for bottom navbar
        elevation: 8, // Add shadow to the bottom navigation bar for a floating effect
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
