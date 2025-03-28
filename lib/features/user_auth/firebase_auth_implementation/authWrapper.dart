import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:faults/features/user_auth/presentation/pages/user/user.dart';
import 'package:faults/features/user_auth/presentation/pages/admin.dart';
import 'package:faults/features/user_auth/presentation/pages/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // Function to log user login
  void logUserLogin(User user) async {
    final timestamp = FieldValue.serverTimestamp();
    final deviceInfo = "Device Info: Example"; // You can fetch device information using packages like `device_info`

    await FirebaseFirestore.instance.collection('system_logs').add({
      'email': user.email ?? 'Anonymous', // Store the email instead of username
      'timestamp': timestamp,
      'device': deviceInfo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(  // Listen for user authentication changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If no user is logged in, show login page
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
        }

        // Log the user's login after successful login
        final user = snapshot.data!;
        logUserLogin(user); // Log the user's login

        return FutureBuilder<DocumentSnapshot>(  // Fetch user data from Firestore
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // If user data doesn't exist, log out and show login page
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              FirebaseAuth.instance.signOut();
              return const LoginPage();
            }

            // Fetch the role
            final role = userSnapshot.data!.get('role')?.toString().toLowerCase();
            print("Fetched Role from Firestore: $role");  // Log role from Firestore

            // Check the role fetched from Firestore and navigate accordingly
            if (role == 'admin') {
              print("✅ Navigating to Admin Page");
              return const AdminPage();
            } else if (role == 'user') {
              print("✅ Navigating to User Page");
              return const UserHomePage();
            } else {
              FirebaseAuth.instance.signOut();
              print("⚠️ Role is invalid, signing out...");
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}
