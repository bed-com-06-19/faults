import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004D40), // Dark Green Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40), // Dark Green App Bar
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.amber[600]), // Yellow Text
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Mode Toggle
            SwitchListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(fontSize: 18, color: Colors.amber[600]),
              ),
              value: isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  isDarkMode = value;
                });
              },
              activeColor: Colors.amber[600],
            ),

            const SizedBox(height: 20),

            // Language Selection
            Text(
              'Select Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber[600]),
            ),
            DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: const Color(0xFF004D40),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
              items: ['English', 'French'].map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(
                    language,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
