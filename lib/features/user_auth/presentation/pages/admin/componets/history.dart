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
  // Replace with your actual Channel ID and Read API Key
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
          final field1 = latestFeed['field1'];
          final createdAt = latestFeed['created_at'];

          if (field1 != null && createdAt != null) {
            final electricityStatus = int.tryParse(field1.toString()) ?? 0;
            final timestamp = DateTime.parse(createdAt);

            await FirebaseFirestore.instance.collection('fault').add({
              'electricityStatus': electricityStatus,
              'timestamp': timestamp,
              'status': electricityStatus == 1 ? 'fixed' : 'fault',
            });

            print('✅ Data saved: $electricityStatus at $timestamp');
          } else {
            print('⚠️ Missing field1 or created_at in the feed.');
          }
        } else {
          print('⚠️ No feeds available.');
        }
      } else {
        print('❌ Failed to fetch data. Status code: ${response.statusCode}');
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
              final electricityStatus = data['electricityStatus'] as int? ?? 0;
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formattedTime =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);

              return ListTile(
                leading: Icon(
                  electricityStatus == 1
                      ? Icons.check_circle
                      : Icons.warning,
                  color:
                      electricityStatus == 1 ? Colors.green : Colors.red,
                ),
                title: Text(
                  electricityStatus == 1
                      ? 'Electricity Present'
                      : 'Electricity Absent',
                ),
                subtitle: Text('Timestamp: $formattedTime'),
              );
            },
          );
        },
      ),
    );
  }
}
