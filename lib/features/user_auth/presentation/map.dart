import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
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
  List<LatLng> _routePoints = [];

  // accessToken
  final String accessToken = 'pk.eyJ1Ijoicm9zaWVtYXJpZSIsImEiOiJjbTk3aDZsNXQwNXQyMm1zZWl5YWsweGtuIn0.4-37gV-0oP-KZl65Sxqxfg';

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
      _getRoute(loc, LatLng(widget.latitude, widget.longitude));
    }
  }

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

  Future<void> _getRoute(LatLng from, LatLng to) async {
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?geometries=geojson&access_token=$accessToken';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;

      final points = coords.map((c) => LatLng(c[1], c[0])).toList();
      setState(() {
        _routePoints = points;
      });
    }
  }

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
          zoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$accessToken',
            additionalOptions: {
              'accessToken': accessToken,
              'id': 'mapbox.streets',
            },
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: faultLocation,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
              if (_userLocation != null)
                Marker(
                  point: _userLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                ),
            ],
          ),
          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
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
