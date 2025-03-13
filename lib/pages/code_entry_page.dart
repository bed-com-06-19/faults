import 'package:flutter/material.dart';
import 'home_page.dart'; // Import HomePage

class CodeEntryPage extends StatefulWidget {
  const CodeEntryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CodeEntryPageState createState() => _CodeEntryPageState();
}

class _CodeEntryPageState extends State<CodeEntryPage> {
  TextEditingController codeController = TextEditingController();
  final String correctCode = "1234"; // Change this to your actual access code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004D40), // Dark Green Background
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back arrow
        backgroundColor: const Color(0xFF004D40), // Dark Green App Bar
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Text(
              'FAULT DETECTION SYSTEM',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber[600], // Yellow text
              ),
            ),
          ],
        ),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instruction Text
            Text(
              'Please enter your fault detection code:',
              style: TextStyle(fontSize: 18, color: Colors.amber[600]), // Yellow Text
            ),
            const SizedBox(height: 20),

            // Input Field
            TextField(
              controller: codeController,
              obscureText: true, // Hides the code for security
              style: const TextStyle(color: Colors.white), // White text
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber[600]!), // Yellow Border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber[600]!, width: 2), // Thicker Yellow Border
                ),
                labelText: 'Enter Code',
                labelStyle: TextStyle(color: Colors.amber[600]), // Yellow Label
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                String enteredCode = codeController.text;
                if (enteredCode == correctCode) {
                  // Navigate to Home Page if code is correct
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                } else {
                  // Show Error Message if code is incorrect
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid Code! Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
