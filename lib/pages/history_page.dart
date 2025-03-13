import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004D40), // Dark Green Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40), // Dark Green App Bar
        title: Text(
          'Fixed Faults',
          style: TextStyle(color: Colors.amber[600]), // Yellow Text
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: const [
            FaultCard(title: "Sensor Failure Fixed", time: "Yesterday"),
            FaultCard(title: "Overheating Resolved", time: "2 days ago"),
            FaultCard(title: "Voltage Stabilized", time: "Last Week"),
          ],
        ),
      ),
    );
  }
}

class FaultCard extends StatelessWidget {
  final String title;
  final String time;

  const FaultCard({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[600], // Yellow Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004D40)), // Dark Green Text
        ),
        subtitle: Text(
          time,
          style: const TextStyle(color: Color(0xFF004D40)), // Dark Green Text
        ),
        leading: const Icon(Icons.check_circle, color: Color(0xFF004D40)), // Dark Green Icon
      ),
    );
  }
}
