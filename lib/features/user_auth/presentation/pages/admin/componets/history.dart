import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String searchQuery = '';

  void _resetFilters() {
    setState(() {
      searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixed Faults History'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by Pole Number or Location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _resetFilters,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('fault')
                  .where('status', isEqualTo: 'fixed')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> faultDocs = snapshot.data!.docs;

                // Apply search filter (by pairName or location)
                faultDocs = faultDocs.where((doc) {
                  final name = doc['pairName'].toString().toLowerCase();
                  final loc = doc['location'].toString().toLowerCase();
                  return name.contains(searchQuery) || loc.contains(searchQuery);
                }).toList();

                if (faultDocs.isEmpty) {
                  return const Center(child: Text("No matching results."));
                }

                faultDocs.sort((a, b) {
                  final tsA = a['timestamp'];
                  final tsB = b['timestamp'];
                  return tsB.compareTo(tsA);
                });

                return ListView.builder(
                  itemCount: faultDocs.length,
                  itemBuilder: (context, index) {
                    final fault = faultDocs[index];
                    final pairName = fault['pairName'];
                    final location = fault['location'];
                    final timestamp = fault['timestamp'];
                    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(timestamp.toDate().toLocal());

                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(pairName),
                      subtitle: Text("Location: $location\nTime Fixed: $formattedTime"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
