import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixed Faults'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faults')
            .where('status', isEqualTo: 'fixed') // 🔍 Only fetch fixed ones
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No fixed faults yet."));
          }

          final fixedFaults = snapshot.data!.docs;

          return ListView.builder(
            itemCount: fixedFaults.length,
            itemBuilder: (context, index) {
              final fault = fixedFaults[index];
              final pairName = fault['pairName'];
              final location = fault['location'];
              final timestamp = fault['timestamp'];

              final formattedTime = timestamp != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(
                              timestamp.millisecondsSinceEpoch)
                          .toLocal())
                  : 'Unknown time';

              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(pairName),
                subtitle: Text('Location: $location\nTime: $formattedTime'),
              );
            },
          );
        },
      ),
    );
  }
}
