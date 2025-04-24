import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String pairName;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.pairName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final loc = await _getCurrentLocation();
    if (loc != null) {
      setState(() {
        _userLocation = loc;
      });
    }
  }

  // 📍 1. Get Current User Location
  Future<LatLng?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  // 🌐 2. Launch in Google Maps
  void _openInGoogleMaps() async {
    final googleUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final faultLocation = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fault at ${widget.pairName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions),
            onPressed: _openInGoogleMaps,
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: faultLocation,
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoicm9zaWVtYXJpZSIsImEiOiJjbTk3aDZsNXQwNXQyMm1zZWl5YWsweGtuIn0.4-37gV-0oP-KZl65Sxqxfg',
            additionalOptions: {
              'accessToken': 'pk.eyJ1Ijoicm9zaWVtYXJpZSIsImEiOiJjbTk3aDZsNXQwNXQyMm1zZWl5YWsweGtuIn0.4-37gV-0oP-KZl65Sxqxfg',
            },
          ),

          // 🛠️ Fault Marker
          MarkerLayer(
            markers: [
              Marker(
                point: faultLocation,
                width: 40,
                height: 40,
                builder: (ctx) => const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
              // 📍 Optional User Location Marker
              if (_userLocation != null)
                Marker(
                  point: _userLocation!,
                  width: 40,
                  height: 40,
                  builder: (ctx) => const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                ),
            ],
          ),

          // 🧭 Route Line (Optional)
          if (_userLocation != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [_userLocation!, faultLocation],
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
