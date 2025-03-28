import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:faults/global/common/toast.dart';
import 'package:faults/features/user_auth/presentation/widgets/form_container_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedRole = 'worker'; // Default role
  String _selectedSex = 'Male'; // Default sex
  bool _isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isSigningUp = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String phone = _phoneController.text.trim();
    String age = _ageController.text.trim();
    String location = _locationController.text.trim();

    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Store user details in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'phone': phone,
          'role': _selectedRole,
          'sex': _selectedSex,
          'age': age,
          'location': location,
          'createdAt': FieldValue.serverTimestamp(),
        });

        showToast(message: "User successfully signed up");

        // Navigate based on role
        if (_selectedRole == 'admin') {
          Navigator.pushNamed(context, '/admin');
        } else if (_selectedRole == 'worker') {
          Navigator.pushNamed(context, '/worker');
        }
      }
    } catch (e) {
      showToast(message: "Error: $e");
      print("❌ Sign-up error: $e");
    } finally {
      setState(() {
        _isSigningUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Arrow and Create Account Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 30, color: Colors.green),
                  ),
                  const Spacer(),
                  const Text(
                    "Create Account",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Username Field
                      FormContainerWidget(
                        controller: _usernameController,
                        hintText: "Username",
                        isPasswordField: false,
                      ),
                      const SizedBox(height: 10),

                      // Email Field
                      FormContainerWidget(
                        controller: _emailController,
                        hintText: "Email",
                        isPasswordField: false,
                      ),
                      const SizedBox(height: 10),

                      // Password Field
                      FormContainerWidget(
                        controller: _passwordController,
                        hintText: "Password",
                        isPasswordField: true,
                      ),
                      const SizedBox(height: 10),

                      // Role Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          underline: Container(),
                          items: ['admin', 'worker'].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sex Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedSex,
                          isExpanded: true,
                          underline: Container(),
                          items: ['Male', 'Female', 'Other'].map((sex) {
                            return DropdownMenuItem(
                              value: sex,
                              child: Text(sex),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSex = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Age Field
                      FormContainerWidget(
                        controller: _ageController,
                        hintText: "Age",
                        isPasswordField: false,
                      ),
                      const SizedBox(height: 10),

                      // Location Field
                      FormContainerWidget(
                        controller: _locationController,
                        hintText: "Location",
                        isPasswordField: false,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Sign Up Button
              GestureDetector(
                onTap: () => _signUp(),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isSigningUp
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Create Account",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
