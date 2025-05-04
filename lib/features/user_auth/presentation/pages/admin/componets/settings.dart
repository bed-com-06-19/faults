import 'package:faults/features/user_auth/presentation/pages/admin/componets/changePassword.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingCard(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              trailing: Switch(
                value: isDarkMode,
                activeColor: primaryColor,
                onChanged: (value) async {
                  setState(() => isDarkMode = value);
                  await _saveDarkModePreference(value);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.lock,
              label: "Change Password",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.logout,
              label: "Log Out",
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: Colors.green, size: 28),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: trailing,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}
