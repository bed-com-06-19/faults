import 'package:faults/features/user_auth/presentation/pages/admin/navbar.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        title: const Align(
          alignment: Alignment.centerLeft, // Align text to the left
          child: Text(
            'Admin Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Make text bold
              color: Colors.white, // Make text white
            ),
          ),
        ),
        backgroundColor: Colors.green,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.notifications, // Notification icon
              color: Colors.white,
              size: 30.0, // Increased size of notification icon
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Faults Icon and Text aligned horizontally
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined, // Fault icon
                  color: Colors.orange,
                  size: 50.0, // Adjusted icon size
                ),
                const SizedBox(width: 10), // Spacing between icon and text
                const Text(
                  '20 faults detected',
                  style: TextStyle(
                    fontSize: 22, // Slightly increased text size
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Space before NavBar
            const Expanded(child: NavBar()), // Use NavBar
          ],
        ),
      ),
    );
  }
}
