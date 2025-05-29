import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:faults/features/user_auth/presentation/fullmap.dart';
import 'package:faults/features/user_auth/presentation/map.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/history.dart';  // For HistoryPage
import 'package:faults/features/user_auth/presentation/pages/admin/componets/services.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/navbar.dart';
import 'package:faults/features/user_auth/presentation/pages/notification.dart';  // NotificationService assumed here

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const HistoryPage(),
      const ServicesPage(),
      const SettingsPage(),
    ];
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

// ------------------- HomePage: Show only detected faults -------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';
  final Set<String> _knownFaultIds = {};
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
            _userName = userDoc['name'];
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
          // Search bar on top
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by pole number or location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('faults')
                  .where('status', isEqualTo: 'fault')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No active faults detected."));
                }

                List<DocumentSnapshot> faultDocs = snapshot.data!.docs;

                // Notify for new faults
                for (var doc in faultDocs) {
                  if (!_knownFaultIds.contains(doc.id)) {
                    _knownFaultIds.add(doc.id);
                    final pairName = doc['pairName'] ?? 'Unknown Pole';
                    NotificationService.showFaultNotification(
                      'New Fault Detected',
                      'Fault detected at $pairName',
                    );
                  }
                }

                // Apply search filter
                if (searchQuery.isNotEmpty) {
                  faultDocs = faultDocs.where((doc) {
                    final pairName = (doc['pairName'] ?? '').toString().toLowerCase();
                    final location = (doc['location'] ?? '').toString().toLowerCase();
                    return pairName.contains(searchQuery) || location.contains(searchQuery);
                  }).toList();
                }

                // Sort faults by timestamp descending
                faultDocs.sort((a, b) {
                  final tsA = a['timestamp'];
                  final tsB = b['timestamp'];
                  if (tsA == null || tsB == null) return 0;
                  return tsB.compareTo(tsA);
                });

                if (faultDocs.isEmpty) {
                  return const Center(child: Text("No faults match your search."));
                }

                return ListView.builder(
                  itemCount: faultDocs.length,
                  itemBuilder: (context, index) {
                    final fault = faultDocs[index];
                    final pairName = fault['pairName'] ?? 'Unknown Pole';
                    final location = fault['location'] ?? 'Unknown Location';
                    final timestamp = fault['timestamp'];
                    final latitude = fault['latitude'];
                    final longitude = fault['longitude'];

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
                          "Location: $location\nStatus: Detected\nTime: $formattedTime\nLatitude: $latitude\nLongitude: $longitude",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: 'Mark as Fixed',
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('faults')
                                  .doc(fault.id)
                                  .update({'status': 'fixed'});

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Fault marked as fixed")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error updating fault: $e")),
                              );
                            }
                          },
                        ),
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
                      ),
                    );
                  },
                );
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
        label: const Text('View All Poles'),
        icon: const Icon(Icons.location_pin),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// ------------------- HistoryPage: Show only fixed faults -------------------

