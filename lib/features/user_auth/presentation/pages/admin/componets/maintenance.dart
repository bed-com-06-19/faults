import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'history.dart'; // For Maintenance Report button

class MaintenanceInsightsPage extends StatefulWidget {
  const MaintenanceInsightsPage({super.key});

  @override
  State<MaintenanceInsightsPage> createState() => _MaintenanceInsightsPageState();
}

class _MaintenanceInsightsPageState extends State<MaintenanceInsightsPage> {
  Map<String, int> _areaFaultCounts = {};
  Map<String, int> _poleFaultCounts = {};
  List<DateTime> _faultDates = [];

  String _selectedView = 'Weekly'; // Default view

  @override
  void initState() {
    super.initState();
    _loadFaultData();
  }

  Future<void> _loadFaultData() async {
    final snapshot = await FirebaseFirestore.instance.collection('faults').get();

    Map<String, int> areaCounts = {};
    Map<String, int> poleCounts = {};
    List<DateTime> dates = [];

    for (var doc in snapshot.docs) {
      String location = doc['location'] ?? 'Unknown Area';
      String pairName = doc['pairName'] ?? 'Unknown Pole';
      Timestamp? timestamp = doc['timestamp'];

      areaCounts[location] = (areaCounts[location] ?? 0) + 1;
      poleCounts[pairName] = (poleCounts[pairName] ?? 0) + 1;

      if (timestamp != null) {
        dates.add(timestamp.toDate());
      }
    }

    setState(() {
      _areaFaultCounts = areaCounts;
      _poleFaultCounts = poleCounts;
      _faultDates = dates;
    });
  }

  List<BarChartGroupData> _generateChartData() {
    Map<String, int> groupedData = {};

    for (var date in _faultDates) {
      String key;
      try {
        if (_selectedView == 'Daily') {
          key = DateFormat('yyyy-MM-dd').format(date);
        } else if (_selectedView == 'Weekly') {
          int weekOfYear = int.parse(DateFormat('w').format(date));
          key = 'Week $weekOfYear';
        } else {
          key = DateFormat('yyyy-MM').format(date);
        }

        print("Generated key: $key for date: $date");  // Debugging line
        groupedData[key] = (groupedData[key] ?? 0) + 1;
      } catch (e) {
        print("Error formatting date: $date, error: $e");
      }
    }

    List<String> sortedKeys = groupedData.keys.toList()..sort();
    return List.generate(sortedKeys.length, (index) {
      final key = sortedKeys[index];
      final count = groupedData[key]!;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: count.toDouble(), color: Colors.green),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedAreas = _areaFaultCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedPoles = _poleFaultCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Limit the number of poles shown (e.g., top 5 poles)
    final topFaultyPoles = sortedPoles.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Insights'),
        backgroundColor: Colors.green,
      ),
      body: _areaFaultCounts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Top Affected Areas
            const Text("🏠 Top Affected Areas:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...sortedAreas.map((entry) => ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: Text(entry.key),
              subtitle: Text('Faults reported: ${entry.value}'),
            )),

            const SizedBox(height: 16),

            // Most Faulty Poles (Top 5)
            const Text("⚡ Poles with Most Faults:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...topFaultyPoles.map((entry) => ListTile(
              leading: const Icon(Icons.electrical_services, color: Colors.orange),
              title: Text(entry.key),
              subtitle: Text('Faults: ${entry.value}'),
            )),

            const SizedBox(height: 16),

            // Chart with time filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("📈 Faults Over Time:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _selectedView,
                  items: ['Daily', 'Weekly', 'Monthly'].map((view) {
                    return DropdownMenuItem<String>(
                      value: view,
                      child: Text(view),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedView = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: _generateChartData(),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Button to Full Report (HistoryPage)
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryPage()),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Go to Full Maintenance Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
