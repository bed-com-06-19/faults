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

  Future<void> _deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await _auth.currentUser?.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting user: $e")),
      );
    }
  }

  void _showUserDialog({
    String? userId,
    String? name,
    String? phone,
    String? department,
    String? gender,
    String? age,
    String? email,
    String? role,
  }) {
    final TextEditingController _nameController = TextEditingController(text: name ?? '');
    final TextEditingController _phoneController = TextEditingController(text: phone ?? '');
    final TextEditingController _departmentController = TextEditingController(text: department ?? '');
    final TextEditingController _ageController = TextEditingController(text: age ?? '');
    final TextEditingController _emailController = TextEditingController(text: email ?? '');
    String selectedGender = gender ?? 'male';
    String selectedRole = role ?? 'user';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(userId == null ? "Add New User" : "Edit User"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                TextField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: "Department"),
                ),
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: "Age"),
                ),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  items: ['male', 'female'].map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (value) => selectedGender = value!,
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ['user', 'admin'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) => selectedRole = value!,
                  decoration: const InputDecoration(labelText: "Role"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_emailController.text.isNotEmpty) {
                  try {
                    if (userId == null) {
                      // Create new user with a default password (123456)
                      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                        email: _emailController.text,
                        password: "123456",
                      );

                      // Save user details to Firestore
                      await _firestore.collection('users').doc(userCredential.user!.uid).set({
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'phone': _phoneController.text,
                        'department': _departmentController.text,
                        'age': _ageController.text,
                        'gender': selectedGender,
                        'role': selectedRole,
                        'isFirstLogin': true,
                        'createdAt': Timestamp.now(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User created successfully")),
                      );
                    } else {
                      // Update existing user details
                      await _firestore.collection('users').doc(userId).update({
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'phone': _phoneController.text,
                        'department': _departmentController.text,
                        'age': _ageController.text,
                        'gender': selectedGender,
                        'role': selectedRole,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User updated successfully")),
                      );
                    }

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: const Text("Save"),
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
        title: const Text("User Management"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${user['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Email: ${user['email']}"),
                        Text("Phone: ${user['phone']}"),
                        Text("Department: ${user['department']}"),
                        Text("Age: ${user['age']}"),
                        Text("Gender: ${user['gender']}"),
                        Text("Role: ${user['role']}"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showUserDialog(
                                userId: user.id,
                                name: user['name'],
                                phone: user['phone'],
                                department: user['department'],
                                gender: user['gender'],
                                age: user['age'],
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
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
