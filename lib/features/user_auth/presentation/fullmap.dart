import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:faults/features/user_auth/presentation/map.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  List<Marker> _markers = [];

  final String accessToken = 'pk.eyJ1Ijoicm9zaWVtYXJpZSIsImEiOiJjbTk3aDZsNXQwNXQyMm1zZWl5YWsweGtuIn0.4-37gV-0oP-KZl65Sxqxfg';

  @override
  void initState() {
    super.initState();
    _loadFaults();
  }

  Future<void> _loadFaults() async {
    final snapshot = await FirebaseFirestore.instance.collection('faults').get();
    List<Marker> tempMarkers = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final latRaw = data['latitude'];
      final lngRaw = data['longitude'];
      final pairName = data['pairName'] ?? 'Unknown Pole';
      final status = data['status'] ?? 'fault';

      double? lat = double.tryParse(latRaw.toString());
      double? lng = double.tryParse(lngRaw.toString());

      if (lat != null && lng != null) {
        tempMarkers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: LatLng(lat, lng),
            child: GestureDetector(
              onTap: () {
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
              },
              child: Icon(
                Icons.location_pin,
                color: status == 'fault' ? Colors.red : Colors.green,
                size: 40,
              ),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = tempMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Poles'),
        backgroundColor: Colors.green,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-15.3850, 35.3182), // Zomba default center
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.all,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}',
            additionalOptions: {
              'accessToken': accessToken,
            },
            userAgentPackageName: 'com.example.faults',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
