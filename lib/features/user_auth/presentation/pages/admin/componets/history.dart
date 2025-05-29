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
  static const String channelId = '2931876';
  static const String readApiKey = 'AZBAY4XTSCGO9FCH';

  @override
  void initState() {
    super.initState();
    fetchAndSaveThingSpeakData();
  }

  Future<void> fetchAndSaveThingSpeakData() async {
    final url = Uri.parse(
      'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$readApiKey&results=1',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final feeds = data['feeds'] as List<dynamic>;

        if (feeds.isNotEmpty) {
          final latestFeed = feeds[0];

          final field1 = int.tryParse(latestFeed['field1'] ?? '0') ?? 0;
          final field2 = latestFeed['field2'] ?? 'Unknown';
          final field3 = latestFeed['field3'] ?? '0.0';
          final field4 = latestFeed['field4'] ?? '0.0';
          final field5 = latestFeed['field5'] ?? 'Unknown';
          final field6 = latestFeed['field6'] == 'true';
          final field7 = latestFeed['field7'] ?? 'fault';
          final field8 = latestFeed['field8'] ?? latestFeed['created_at'];

          final timestamp = DateTime.tryParse(field8) ?? DateTime.now();

          await FirebaseFirestore.instance.collection('fault').add({
            'electricityStatus': field1,
            'pairName': field2,
            'latitude': field3,
            'longitude': field4,
            'location': field5,
            'notified': field6,
            'status': field7,
            'timestamp': timestamp,
          });

          print('✅ Data saved to Firestore');
        } else {
          print('⚠️ No feeds available.');
        }
      } else {
        print('❌ Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching data: $e');
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
            .collection('fault')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final electricityStatus = data['electricityStatus'] ?? 0;
              final pairName = data['pairName'] ?? 'Unknown';
              final location = data['location'] ?? 'Unknown';
              final notified = data['notified'] ?? false;
              final status = data['status'] ?? 'fault';
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formattedTime =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);

              return Card(
                child: ListTile(
                  leading: Icon(
                    electricityStatus == 1
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    color: electricityStatus == 1 ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    electricityStatus == 1
                        ? 'Electricity Present'
                        : 'Electricity Absent',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pole: $pairName'),
                      Text('Location: $location'),
                      Text('Notified: $notified'),
                      Text('Status: $status'),
                      Text('Time: $formattedTime'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
