import 'package:faults/features/user_auth/presentation/pages/user/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faults/features/user_auth/presentation/pages/admin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faults/features/app/splash_screen/splash_screen.dart';
import 'package:faults/features/user_auth/presentation/pages/login_page.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for different platforms
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBfyyLutVWu8cOHtZS8NtnJf3IeH3Rx1xI",
        appId: "1:664103674812:web:4408c024503b178b2e01b9",
        messagingSenderId: "664103674812",
        projectId: "faults-2a6ef",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Load dark mode preference before running the app
  final isDarkMode = await _getDarkModePreference();

  runApp(FaultDetectionApp(isDarkMode));
}

// Retrieve dark mode preference
Future<bool> _getDarkModePreference() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDarkMode') ?? false; // Default to light mode if not set
}

class FaultDetectionApp extends StatefulWidget {
  final bool isDarkMode;
  const FaultDetectionApp(this.isDarkMode, {super.key});

  @override
  State<FaultDetectionApp> createState() => _FaultDetectionAppState();
}

class _FaultDetectionAppState extends State<FaultDetectionApp> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void toggleTheme(bool value) async {
    setState(() {
      isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fault Detection System',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(color: Colors.black),
      ),
      theme: ThemeData(
        primaryColor: const Color(0xFF004D40), // Dark Green
        scaffoldBackgroundColor: Colors.white, // White Background
        appBarTheme: const AppBarTheme(color: Color(0xFF004D40)),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Redirect user based on role
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Stream of auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If no user is logged in, show login page
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
        }

        // If user is logged in, fetch the user role from Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // If user data doesn't exist, log out and show login page
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const LoginPage();
            }

            // Get the role from Firestore and navigate accordingly
            final role = userSnapshot.data!.get('role');
            if (role == 'admin') {
              return const AdminPage(); // Show admin page
            } else {
              return const UserHomePage(); // Show user home page
            }
          },
        );
      },
    );
  }
}

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
                title: const Text(
                  "Dark Mode",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  activeColor: Colors.green,
                  onChanged: (value) async {
                    setState(() {
                      isDarkMode = value;
                    });
                    await _saveDarkModePreference(value);
                    // Restart the app to apply theme changes (for now)
                    if (context.findAncestorStateOfType<_SettingsPageState>() != null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
