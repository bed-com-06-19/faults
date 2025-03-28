import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SystemLogsPage extends StatelessWidget {
  const SystemLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Logs"),
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('system_logs') // Fetch logs from the 'system_logs' collection
            .orderBy('timestamp', descending: true) // Order by timestamp to show the latest first
            .get(),
        builder: (context, snapshot) {
          // Loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If no data or empty collection
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No logs found"));
          }

          // Display logs in a list
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final log = snapshot.data!.docs[index];
              final username = log['email'] ?? 'Unknown'; // Get username from log
              final timestamp = (log['timestamp'] as Timestamp).toDate(); // Convert timestamp to DateTime
              final loginDevice = log['device'] ?? 'Unknown Device'; // Get device info

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    username,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Logged in at: $timestamp\nDevice: $loginDevice'),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
