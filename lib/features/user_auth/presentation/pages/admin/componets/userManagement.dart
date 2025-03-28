import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to delete a user
  Future<void> _deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Function to add or update a user
  void _showUserDialog({String? userId, String? email, String? role}) {
    final TextEditingController _emailController = TextEditingController(text: email ?? '');
    String selectedRole = role ?? 'User';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(userId == null ? "Add New User" : "Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['User', 'Admin'].map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) => selectedRole = value!,
                decoration: const InputDecoration(labelText: "Role"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (_emailController.text.isNotEmpty) {
                  if (userId == null) {
                    // Add new user
                    try {
                      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                        email: _emailController.text,
                        password: "User@123", // Default password
                      );

                      await _firestore.collection('users').doc(userCredential.user!.uid).set({
                        'email': _emailController.text,
                        'role': selectedRole,
                        'lastLogin': DateTime.now(),
                      });

                      // Send password reset email
                      await _auth.sendPasswordResetEmail(email: _emailController.text);

                    } catch (e) {
                      print("Error adding user: $e");
                    }
                  } else {
                    // Update existing user role
                    await _firestore.collection('users').doc(userId).update({
                      'email': _emailController.text,
                      'role': selectedRole,
                    });
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(userId == null ? "Add User" : "Update User"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text("User Management");
            return Text("Users (${snapshot.data!.docs.length})");
          },
        ),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.green, size: 30),
                  title: Text(user['email'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text("Role: ${user['role']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUserDialog(
                          userId: user.id,
                          email: user['email'],
                          role: user['role'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
