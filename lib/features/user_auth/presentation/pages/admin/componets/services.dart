import 'package:faults/features/user_auth/presentation/pages/admin/componets/maintenance.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/systemLogs.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/userManagement.dart';
import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Updated list of services
    final List<Map<String, dynamic>> services = [
      {
        "title": "Maintenance Insights", // <-- NEW ITEM
        "icon": Icons.analytics,
        "desc": "View areas most affected and fault trends.",
        "route": const MaintenanceInsightsPage(), // Navigate to Maintenance Insights
      },
      {
        "title": "User Management",
        "icon": Icons.people,
        "desc": "Manage technicians and system users.",
        "route": const UserManagementPage(),
      },
      {
        "title": "System Logs",
        "icon": Icons.history,
        "desc": "View recent login activity of users.",
        "route": const SystemLogsPage(),
      },
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
                  // Navigate if the service has a route
                  if (services[index]['route'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => services[index]['route']),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
