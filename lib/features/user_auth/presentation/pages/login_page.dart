import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:faults/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:faults/global/common/toast.dart';
import '../../firebase_auth_implementation/firebase_auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // Large green faults icon
                const Icon(
                  Icons.warning_amber_rounded, // Faults-related icon
                  size: 100, // Large size
                  color: Colors.green, // Green color
                ),
                const SizedBox(height: 20),
                // Title centered at the top
                const Text(
                  "Fault Detection System",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green, // Green color for the title
                    fontSize: 24, // Adjust the font size as needed
                  ),
                ),
                const SizedBox(height: 30),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    _signIn();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.green, // Green color for the container
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _isSigning
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white, // White color for the text
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to handle the email/password sign-in
  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String? role = userDoc['role'];

          if (role != null) {
            showToast(message: "User successfully signed in");

            if (role == 'admin') {
              Navigator.pushNamed(context, '/admin');
            }  else if (role == 'worker') {
              Navigator.pushNamed(context, '/worker');
            } else {
              showToast(message: "Invalid user role");
            }
          } else {
            showToast(message: "User role not found");
          }
        } else {
          showToast(message: "User document does not exist in Firestore");
        }
      } else {
        showToast(message: "Sign-in failed");
      }
    } catch (e) {
      showToast(message: "Error occurred: $e");
    } finally {
      setState(() {
        _isSigning = false;
      });
    }
  }
}
