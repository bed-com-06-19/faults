import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004D40), // Dark Green Background
      appBar: AppBar(
        automaticallyImplyLeading: false, // No back arrow
        backgroundColor: const Color(0xFF004D40), // Dark Green App Bar
        title: Row(
          children: [
            // Logo on the Left
            Image.asset(
              'assets/logo.png',
              width: 40, // Adjust size if needed
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),

            // App Name
            Text(
              'FAULT DETECTION SYSTEM',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber[600], // Yellow text
              ),
            ),
          ],
        ),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Faults Header
            Text(
              'Recent Faults Detected',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber[600], // Yellow text
              ),
            ),
            const SizedBox(height: 15),

            // Recent Faults List (Example Data)
            Expanded(
              child: ListView(
                children: const [
                  FaultCard(title: "Overheating Detected", time: "2 mins ago"),
                  FaultCard(title: "Voltage Spike", time: "10 mins ago"),
                  FaultCard(title: "Low Battery", time: "30 mins ago"),
                  FaultCard(title: "System Malfunction", time: "1 hour ago"),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation with Cards for History & Settings
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Color(0xFF00332E), // Darker Green for contrast
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // History Card Button
            _buildCardButton(
              icon: Icons.history,
              label: "History",
              onTap: () {
                // TODO: Navigate to History Page
              },
            ),
            // Settings Card Button
            _buildCardButton(
              icon: Icons.settings,
              label: "Settings",
              onTap: () {
                // TODO: Navigate to Settings Page
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to Build Card Buttons
  Widget _buildCardButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.amber[600], // Yellow Card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF004D40)), // Dark Green Icon
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40), // Dark Green Text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Fault Card Widget
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
        leading: const Icon(Icons.warning, color: Color(0xFF004D40)), // Dark Green Icon
      ),
    );
  }
}
