import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/history.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this for date formatting if needed

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  String _userName = ''; // Store the user's name

  final List<Widget> _pages = [
    const UserDashboard(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  // Fetch the logged-in user's name from Firestore
  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Get the user's document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name']; // Assuming 'name' is the field in Firestore
          });
        }
      } catch (e) {
        print("Error fetching user name: $e");
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user name when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userName.isNotEmpty ? 'Welcome, $_userName' : 'Loading...'), // Dynamically set the title
        backgroundColor: Colors.green,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("Welcome to your dashboard!")),
    );
  }
}
