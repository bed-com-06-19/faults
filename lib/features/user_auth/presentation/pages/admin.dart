import 'package:faults/features/user_auth/presentation/pages/admin/componets/history.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/services.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/componets/settings.dart';
import 'package:faults/features/user_auth/presentation/pages/admin/navbar.dart';
import 'package:faults/features/user_auth/presentation/pages/notification.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  final StreamController<List<String>> _faultStreamController = StreamController<List<String>>();
  List<String> _faults = [];

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _startSimulatingFaults();
    _pages.addAll([
      HomePage(faultStream: _faultStreamController.stream),
      const HistoryPage(),
      const ServicesPage(),
      const SettingsPage(),
    ]);
  }

  void _startSimulatingFaults() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      final newFault = "Fault detected at Pole-${_faults.length + 1}";
      _faults.add(newFault);
      _faultStreamController.add(List.from(_faults));
      NotificationService.showFaultNotification("New Fault Detected", newFault);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _faultStreamController.close();
    super.dispose();
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

// HomePage with notification stream
class HomePage extends StatelessWidget {
  final Stream<List<String>> faultStream;
  const HomePage({super.key, required this.faultStream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<String>>(
        stream: faultStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No faults detected."));
          }

          final faults = snapshot.data!;
          return ListView.builder(
            itemCount: faults.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(faults[index]),
              );
            },
          );
        },
      ),
    );
  }
}
