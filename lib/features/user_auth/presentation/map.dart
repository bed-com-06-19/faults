import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String pairName;

  const MapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.pairName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapCenter = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fault Location: $pairName'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: mapCenter,
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoicm9zaWVtYXJpZSIsImEiOiJjbTk3aDZsNXQwNXQyMm1zZWl5YWsweGtuIn0.4-37gV-0oP-KZl65Sxqxfg",
            additionalOptions: {
              'accessToken': 'pk.eyJ1Ijoicm9zaWVtYXJpZSIsImEiOiJjbTk3aDZsNXQwNXQyMm1zZWl5YWsweGtuIn0.4-37gV-0oP-KZl65Sxqxfg',
              'style': 'mapbox/streets-v11',
            },
            tileProvider: NetworkTileProvider(),
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: mapCenter,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
