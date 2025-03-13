import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    // Navigate to the next screen after a delay
    Future.delayed(Duration(seconds: 9), () {
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
            // Image at the top of the splash screen
            Image.asset(
              'assets/logo.png', // Reference your image here
              width: 150, // Set the width of the image
              height: 150, // Set the height of the image
              fit: BoxFit.contain, // Prevent image from being clipped
            ),
            SizedBox(height: 30), // Space between the image and the text
            Text(
              "Faults Detection System",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Space between the title and remarks
            Text(
              "Your gateway to managing faults efficiently!",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16, // Smaller font size for remarks
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
