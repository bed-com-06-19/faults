import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Fault History"), backgroundColor: Colors.green),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('faults')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'fixed')
          .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data!.docs;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              var fault = history[index];
              return Card(
                child: ListTile(
                  title: Text(fault['description']),
                  subtitle: Text("Fixed on: ${fault['fixedDate']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
