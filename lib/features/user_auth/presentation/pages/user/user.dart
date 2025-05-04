import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:faults/features/user_auth/presentation/fullmap.dart';
import 'package:faults/features/user_auth/presentation/map.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/history.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userName = doc['name'] ?? '';
          });
        }
      } catch (e) {
        print("Error fetching user name: $e");
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildUserHomePage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('faults')
          .where('status', isEqualTo: 'fault')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No active faults."));
        }

        final docs = snapshot.data!.docs;

        docs.sort((a, b) {
          final tsA = a['timestamp'];
          final tsB = b['timestamp'];
          if (tsA == null || tsB == null) return 0;
          return tsB.compareTo(tsA);
        });

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final fault = docs[index];
            final pairName = fault['pairName'];
            final location = fault['location'];
            final status = fault['status'];
            final timestamp = fault['timestamp'];
            final lat = fault['latitude'];
            final lng = fault['longitude'];

            final formattedTime = timestamp != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.fromMillisecondsSinceEpoch(
                timestamp.millisecondsSinceEpoch,
              ).toLocal(),
            )
                : 'Unknown time';

            return InkWell(
              onTap: () {
                if (lat != null && lng != null) {
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
                }
              },
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(pairName),
                subtitle: Text("Location: $location\nStatus: $status\nTime: $formattedTime"),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildUserHomePage(),
      const HistoryPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0
            ? (_userName.isNotEmpty ? 'Welcome, $_userName' : 'Welcome')
            : _selectedIndex == 1
            ? 'History'
            : 'Settings'),
        backgroundColor: Colors.green,
        actions: _selectedIndex == 0
            ? [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FullMapScreen()),
              );
            },
          )
        ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FullMapScreen()),
          );
        },
        label: const Text('View All Poles'),
        icon: const Icon(Icons.location_pin),
        backgroundColor: Colors.green,
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
