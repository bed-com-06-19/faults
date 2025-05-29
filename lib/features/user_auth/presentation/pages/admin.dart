import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:faults/features/user_auth/presentation/fullmap.dart';
import 'package:faults/features/user_auth/presentation/map.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/history.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/services.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/navbar.dart';

class ThingSpeakService {
  static const String channelId = '2931876';
  static const String readApiKey = 'AZBAY4XTSCGO9FCH';

  static Future<void> fetchAndSaveThingSpeakData() async {
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
          final createdAt = latestFeed['created_at'];

          final field1 = int.tryParse(latestFeed['field1'] ?? '0') ?? 0;
          final field2 = latestFeed['field2'] ?? 'Unknown';
          final field3 = latestFeed['field3'] ?? '0.0';
          final field4 = latestFeed['field4'] ?? '0.0';
          final field5 = latestFeed['field5'] ?? 'Unknown';
          final field6 = latestFeed['field6'] == 'true';
          final field7 = latestFeed['field7'] ?? 'fault';
          final timestamp = DateTime.tryParse(createdAt) ?? DateTime.now();

          final lastDocQuery = await FirebaseFirestore.instance
              .collection('fault')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (lastDocQuery.docs.isNotEmpty) {
            final lastDoc = lastDocQuery.docs.first;
            if (lastDoc.get('electricityStatus') == field1) {
              print('🔁 No change in status, skipping Firestore update.');
              return;
            }
          }

          await FirebaseFirestore.instance.collection('fault').add({
            'electricityStatus': field1,
            'pairName': field2,
            'latitude': field3,
            'longitude': field4,
            'location': field5,
            'notified': field6,
            'status': field7,
            'timestamp': timestamp,
            'field8': createdAt,
          });

          print('✅ New data saved to Firestore.');
        }
      } else {
        print('❌ Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Fetch error: $e');
    }
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  Timer? _fetchTimer;

  @override
  void initState() {
    super.initState();

    _pages = const [
      HomePage(),
      HistoryPage(),
      ServicesPage(),
      SettingsPage(),
    ];

    // Initial fetch
    ThingSpeakService.fetchAndSaveThingSpeakData();

    // Fetch every 5 seconds
    _fetchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      ThingSpeakService.fetchAndSaveThingSpeakData();
    });
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.get('name') ?? '';
          });
        }
      } catch (e) {
        debugPrint("Error fetching user name: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userName.isNotEmpty ? 'Welcome, $_userName' : 'Loading...'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FullMapScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by pole number or location...',
                prefixIcon: const Icon(Icons.search),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('fault')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(searchQuery.isEmpty
                        ? 'No fault data found.'
                        : 'No results for your search.'),
                  );
                }

                final doc = snapshot.data!.docs.first;

                final pairName = doc.get('pairName').toString().toLowerCase();
                final location = doc.get('location').toString().toLowerCase();
                final electricityStatus = doc.get('electricityStatus') ?? 0;
                final status = doc.get('status') ?? '';

                final matchesSearch = searchQuery.isEmpty ||
                    pairName.contains(searchQuery.toLowerCase()) ||
                    location.contains(searchQuery.toLowerCase());

                if (!matchesSearch) {
                  return const Center(child: Text('No faults match your search.'));
                }

                if (electricityStatus == 1 || status.toLowerCase() != 'fault') {
                  return Center(
                    child: Text(
                      'No fault detected',
                      style: TextStyle(fontSize: 20, color: Colors.green),
                    ),
                  );
                }

                return _buildFaultCard(doc);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FullMapScreen()),
          );
        },
        label: const Text("View Map"),
        icon: const Icon(Icons.map),
      ),
    );
  }

  Widget _buildFaultCard(DocumentSnapshot fault) {
    final pairName = fault.get('pairName') ?? 'Unknown Pole';
    final location = fault.get('location') ?? 'Unknown Location';
    final timestamp = fault.get('timestamp');
    final latitude = fault.get('latitude');
    final longitude = fault.get('longitude');

    final formattedTime = timestamp != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss')
        .format((timestamp as Timestamp).toDate().toLocal())
        : 'Unknown time';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: Text(pairName),
        subtitle: Text(
          "Location: $location\nStatus: Fault Detected\nTime: $formattedTime",
        ),
        onTap: () {
          try {
            final lat = double.parse(latitude.toString());
            final lng = double.parse(longitude.toString());

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapScreen(
                  latitude: lat,
                  longitude: lng,
                  pairName: pairName,
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid location data.")),
            );
          }
        },
      ),
    );
  }
}
