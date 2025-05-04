import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:faults/features/user_auth/presentation/pages/user/user.dart';
import 'package:faults/features/user_auth/presentation/pages/admin.dart';
import 'package:faults/features/user_auth/presentation/pages/login_page.dart';

/// Records the user's login timestamp to Firestore
Future<void> recordLoginData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance.collection('login_logs').add({
      'email': user.email,
      'uid': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

/// Wrapper that listens to auth state and routes user to the correct page
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // User not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
        }

        // User logged in, fetch their role
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const LoginPage(); // No user data, treat as not logged in
            }

            final role = userSnapshot.data!.get('role')?.toString().toLowerCase();
            print("Fetched Role from Firestore: $role");

            recordLoginData(); // Log login

            // Navigate based on role
            if (role == 'admin') {
              return const AdminPage();
            } else if (role == 'user') {
              return const UserPage();
            } else {
              FirebaseAuth.instance.signOut(); // Invalid role
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}
