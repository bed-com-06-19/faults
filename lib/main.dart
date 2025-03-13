import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'pages/landing_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only once depending on the platform
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBfyyLutVWu8cOHtZS8NtnJf3IeH3Rx1xI",
        appId: "1:664103674812:web:4408c024503b178b2e01b9",
        messagingSenderId: "664103674812",
        projectId: "faults-2a6ef",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const FaultDetectionApp());
}

class FaultDetectionApp extends StatelessWidget {
  const FaultDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fault Detection System',
      theme: ThemeData(
        primaryColor: const Color(0xFF004D40), // Dark Green
        scaffoldBackgroundColor: Colors.white, // White Background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[600], // Yellow Button
            foregroundColor: Colors.black, // Button Text
          ),
        ),
      ),
      home: const LandingPage(),
    );
  }
}
