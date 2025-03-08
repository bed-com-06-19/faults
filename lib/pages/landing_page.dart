import 'package:flutter/material.dart';
import 'code_entry_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004D40), // Dark Green Background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image at the top
            Image.asset(
              'assets/logo.png', // Ensure this matches your asset path
              width: 250, // Increased size
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            // App Name (Larger Text)
            Text(
              'FAULT DETECTION SYSTEM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32, // Larger font size
                fontWeight: FontWeight.bold,
                color: Colors.amber[600], // Yellow Text
              ),
            ),
            const SizedBox(height: 40),

            // Get Started Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CodeEntryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700], // Yellow Button
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(color: Colors.black), // Black text for contrast
              ),
            ),
          ],
        ),
      ),
    );
  }
}
