// AddOrEditUserPage.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddOrEditUserPage extends StatefulWidget {
  final String? userId;
  final Map<String, dynamic>? userData;

  const AddOrEditUserPage({super.key, this.userId, this.userData});

  @override
  State<AddOrEditUserPage> createState() => _AddOrEditUserPageState();
}

class _AddOrEditUserPageState extends State<AddOrEditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _department;
  late TextEditingController _age;
  String _gender = 'male';
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.userData?['name'] ?? '');
    _email = TextEditingController(text: widget.userData?['email'] ?? '');
    _phone = TextEditingController(text: widget.userData?['phone'] ?? '');
    _department = TextEditingController(text: widget.userData?['department'] ?? '');
    _age = TextEditingController(text: widget.userData?['age'] ?? '');
    _gender = widget.userData?['gender'] ?? 'male';
    _role = widget.userData?['role'] ?? 'user';
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.userId == null) {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: "123456",
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _name.text,
          'email': _email.text,
          'phone': _phone.text,
          'department': _department.text,
          'age': _age.text,
          'gender': _gender,
          'role': _role,
          'isFirstLogin': true,
          'createdAt': Timestamp.now(),
        });
      } else {
        await _firestore.collection('users').doc(widget.userId).update({
          'name': _name.text,
          'email': _email.text,
          'phone': _phone.text,
          'department': _department.text,
          'age': _age.text,
          'gender': _gender,
          'role': _role,
        });
      }

      Navigator.pop(context, true); // signal to refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _department.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId == null ? 'Add User' : 'Edit User'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              TextFormField(
                controller: _department,
                decoration: const InputDecoration(labelText: "Department"),
              ),
              TextFormField(
                controller: _age,
                decoration: const InputDecoration(labelText: "Age"),
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['male', 'female'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _gender = val!),
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              DropdownButtonFormField<String>(
                value: _role,
                items: ['user', 'admin'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _role = val!),
                decoration: const InputDecoration(labelText: "Role"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(widget.userId == null ? "Create User" : "Update User"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
