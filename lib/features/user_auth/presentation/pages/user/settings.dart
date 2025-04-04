import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false; // Dark mode toggle
  String selectedLanguage = "English"; // Language selection

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  // Load dark mode preference from SharedPreferences
  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save dark mode preference
  Future<void> _saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
        elevation: 4,
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
                  value: isDarkMode,
                  activeColor: Colors.green,
                  onChanged: (value) async {
                    setState(() {
                      isDarkMode = value;
                    });
                    await _saveDarkModePreference(value);
                    // Restart the app to apply theme changes (for now)
                    // You can use a more elegant solution for theme change
                    if (context.findAncestorStateOfType<_SettingsPageState>() != null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                    }
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
                subtitle: Text(selectedLanguage),
                trailing: DropdownButton<String>(
                  value: selectedLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLanguage = newValue!;
                    });
                  },
                  items: <String>['English', 'French'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Account Settings
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.green, size: 30),
                title: const Text("Account Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () {
                  // Navigate to account settings
                },
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
