// user_management_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/addPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _users = [];
  bool _loading = true;

  Future<void> _loadUsers() async {
    final snapshot = await _firestore.collection('users').get();
    setState(() {
      _users = snapshot.docs;
      _loading = false;
    });
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting user: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2,
          ),
          itemCount: _users.length,
          itemBuilder: (context, index) {
            var user = _users[index];
            var data = user.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${data['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Email: ${data['email']}"),
                    Text("Phone: ${data['phone']}"),
                    Text("Department: ${data['department']}"),
                    Text("Age: ${data['age']}"),
                    Text("Gender: ${data['gender']}"),
                    Text("Role: ${data['role']}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddOrEditUserPage(
                                  userId: user.id,
                                  userData: data,
                                ),
                              ),
                            );
                            if (result == true) _loadUsers();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddOrEditUserPage()),
          );
          if (result == true) _loadUsers();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
