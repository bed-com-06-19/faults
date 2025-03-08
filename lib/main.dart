import 'package:flutter/material.dart';
import 'pages/landing_page.dart';

void main() {
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
