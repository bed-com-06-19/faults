import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of services (Replace with real data)
    final List<Map<String, dynamic>> services = [
      {"title": "Fault Detection", "icon": Icons.warning_amber, "desc": "Monitor and detect faults in real-time."},
      {"title": "Maintenance Reports", "icon": Icons.receipt_long, "desc": "Generate reports for fixed faults."},
      {"title": "User Management", "icon": Icons.people, "desc": "Manage technicians and system users."},
      {"title": "System Logs", "icon": Icons.history, "desc": "Track system activities and fault history."},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Services"),
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(services[index]['icon'], color: Colors.green, size: 30),
                title: Text(
                  services[index]['title'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(services[index]['desc']),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () {
                  // Handle service click (e.g., navigate to service details)
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add service action
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
