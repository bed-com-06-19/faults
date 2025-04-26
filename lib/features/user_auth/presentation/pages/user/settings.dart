import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faults/features/user_auth/firebase_auth_implementation/authWrapper.dart'; // For navigation

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkModeEnabled = false; // Dark mode toggle
  String currentLanguage = "English"; // Language selection

  @override
  void initState() {
    super.initState();
    _retrieveDarkModePreference();
  }

  // Retrieve dark mode preference from SharedPreferences
  Future<void> _retrieveDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
    });
  }

  // Store dark mode preference
  Future<void> _storeDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkModeEnabled', value);
  }

  // Logout method
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    } catch (e) {
      print("Error during sign out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Mode Toggle
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.green, size: 30),
                title: const Text("Dark Mode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: Switch(
                  value: darkModeEnabled,
                  activeColor: Colors.green,
                  onChanged: (value) async {
                    setState(() {
                      darkModeEnabled = value;
                    });
                    await _storeDarkModePreference(value);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Language Selection
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.language, color: Colors.green, size: 30),
                title: const Text("Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(currentLanguage),
                trailing: DropdownButton<String>(
                  value: currentLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      currentLanguage = newValue!;
                    });
                  },
                  items: <String>['English', 'French']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Logout
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.green, size: 30),
                title: const Text("Logout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: _signOut,
              ),
            ),
            const SizedBox(height: 10),

            // Security Settings
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.green, size: 30),
                title: const Text("Security", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () {
                  // Navigate to security settings
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
