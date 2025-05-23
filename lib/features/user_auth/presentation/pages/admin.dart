import 'package:faults/features/user_auth/presentation/fullmap.dart';
import 'package:faults/features/user_auth/presentation/map.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/history.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/services.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/navbar.dart';
import 'package:faults/features/user_auth/presentation/pages/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startSimulatingFaults();
    _pages.addAll([
      const HomePage(),
      const HistoryPage(),
      const ServicesPage(),
      const SettingsPage(),
    ]);
  }

  void _startSimulatingFaults() {
    Timer.periodic(const Duration(seconds: 50000), (timer) async {
      try {
        final double baseLat = -15.3850; // Central Zomba
        final double baseLng = 35.3182;

        double offsetLat = (_random.nextDouble() - 0.5) / 100; // ~±0.005
        double offsetLng = (_random.nextDouble() - 0.5) / 100;

        final pairName = "Pole-${DateTime.now().millisecondsSinceEpoch % 10000}";

        final docRef = await FirebaseFirestore.instance.collection('faults').add({
          'pairName': pairName,
          'location': "Zomba Area",
          'status': "fault",
          'timestamp': FieldValue.serverTimestamp(),
          'notified': true,
          'latitude': baseLat + offsetLat,
          'longitude': baseLng + offsetLng,
        });

        final newFault = "Fault detected at ${docRef.id}";
        NotificationService.showFaultNotification("New Fault Detected", newFault);
        print("✅ Simulated and stored fault: $newFault");
      } catch (e) {
        print("❌ Failed to simulate fault: $e");
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
  String _userName = ''; // Store the logged-in user's name

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Fetch the logged-in user's name from Firestore
  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Get the user's document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name']; // Assuming 'name' is the field in Firestore
          });
        }
      } catch (e) {
        print("Error fetching user name: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userName.isNotEmpty ? 'Welcome, $_userName' : 'Loading...'), // Dynamically display the user's name
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faults')
            .where('status', isEqualTo: 'fault')
            .snapshots(),
        builder: (context, faultSnapshot) {
          if (faultSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!faultSnapshot.hasData || faultSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No active faults in the system."));
          }

          final faultDocs = faultSnapshot.data!.docs;

          faultDocs.sort((a, b) {
            final tsA = a['timestamp'];
            final tsB = b['timestamp'];
            if (tsA == null || tsB == null) return 0;
            return tsB.compareTo(tsA);
          });

          return ListView.builder(
            itemCount: faultDocs.length,
            itemBuilder: (context, index) {
              final fault = faultDocs[index];
              final pairName = fault['pairName'];
              final location = fault['location'];
              final status = fault['status'];
              final timestamp = fault['timestamp'];
              final latitude = fault['latitude'];
              final longitude = fault['longitude'];

              final formattedTime = timestamp != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    timestamp.millisecondsSinceEpoch,
                  ).toLocal())
                  : 'Unknown time';

              return InkWell(
                onTap: () {
                  if (latitude != null && longitude != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          latitude: latitude,
                          longitude: longitude,
                          pairName: pairName,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No location data available.")),
                    );
                  }
                },
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(pairName),
                  subtitle: Text(
                    "Location: $location\nStatus: $status\nTime: $formattedTime",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('faults')
                          .doc(fault.id)
                          .update({'status': 'fixed'});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fault marked as fixed")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FullMapScreen()),
          );
        },
        label: const Text('View All Poles'),
        icon: const Icon(Icons.location_pin),
        backgroundColor: Colors.green,
      ),
    );
  }
}
