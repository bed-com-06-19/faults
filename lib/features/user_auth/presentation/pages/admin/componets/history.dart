import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    fetchAndSaveThingSpeakData();
  }

  Future<void> fetchAndSaveThingSpeakData() async {
    final url = Uri.parse("https://api.thingspeak.com/channels/2931876/feeds.json?results=1");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final latestFeed = data['feeds'][0];

      final electricityStatus = int.tryParse(latestFeed['field1'] ?? '0') ?? 0;
      final createdAt = DateTime.parse(latestFeed['created_at']);

      await FirebaseFirestore.instance.collection('faults').add({
        'electricityStatus': electricityStatus,
        'timestamp': createdAt,
        'status': electricityStatus == 1 ? 'fixed' : 'fault',
      });

      print('✔ Data saved to Firestore');
    } else {
      print('❌ Failed to fetch ThingSpeak data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricity Status History'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faults')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No data found."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final statusValue = data.containsKey('electricityStatus') ? data['electricityStatus'] : null;
              final status = statusValue == 1
                  ? 'Electricity Present'
                  : 'Electricity Absent';

              final timestamp = data.containsKey('timestamp') && data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : DateTime.now();

              final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);

              return ListTile(
                leading: Icon(
                  statusValue == 1 ? Icons.check_circle : Icons.warning,
                  color: statusValue == 1 ? Colors.green : Colors.red,
                ),
                title: Text(status),
                subtitle: Text('Timestamp: $formattedTime'),
              );
            },
          );
        },
      ),
    );
  }
}
