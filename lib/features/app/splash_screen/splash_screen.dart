import 'package:flutter/material.dart';
// Ensure you import icons

class SplashScreen extends StatelessWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    // Navigate to the next screen after a delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => child!),
          (route) => false);
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Large green faults icon
            Icon(
              Icons.warning_amber_rounded, // Faults-related icon
              size: 150, // Large size
              color: Colors.green, // Green color
            ),
            SizedBox(height: 30), // Space between the icon and the text
            Text(
              "Faults Detection System",
              style: TextStyle(
                color: Colors.green, // Green color for the text
                fontSize: 24,
                fontWeight: FontWeight.bold, // Bold text
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
