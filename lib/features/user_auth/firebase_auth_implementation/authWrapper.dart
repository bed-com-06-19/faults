import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:faults/features/user_auth/presentation/pages/user/user.dart';
import 'package:faults/features/user_auth/presentation/pages/admin.dart';
import 'package:faults/features/user_auth/presentation/pages/login_page.dart';

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
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage(); // If no user, show login
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const LoginPage();
            }

            // Fetching role from Firestore
            final role = userSnapshot.data!.get('role')?.toString().toLowerCase();
            print("Fetched Role from Firestore: $role");

            // Navigate based on role
            if (role == 'admin') {
              return const AdminPage();
            } else if (role == 'user') {
              return const UserHomePage();
            } else {
              FirebaseAuth.instance.signOut();
              return const LoginPage(); // Invalid role, sign out
            }
          },
        );
      },
    );
  }
}
