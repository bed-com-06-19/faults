import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SystemLogsPage extends StatefulWidget {
  const SystemLogsPage({super.key});

  @override
  State<SystemLogsPage> createState() => _SystemLogsPageState();
}

class _SystemLogsPageState extends State<SystemLogsPage> {
  Map<String, int> loginsPerDay = {};

  @override
  void initState() {
    super.initState();
    _fetchLoginLogs();
  }

  Future<void> _fetchLoginLogs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('login_logs')
        .orderBy('timestamp', descending: true)
        .get();

    final data = <String, int>{};

    for (var doc in snapshot.docs) {
      final timestamp = (doc['timestamp'] as Timestamp?)?.toDate();
      if (timestamp != null) {
        final formattedDate = DateFormat('MMM d').format(timestamp); // e.g., Apr 25
        data.update(formattedDate, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    setState(() {
      loginsPerDay = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final barGroups = <BarChartGroupData>[];
    final sortedKeys = loginsPerDay.keys.toList()..sort((a, b) {
      final da = DateFormat('MMM d').parse(a);
      final db = DateFormat('MMM d').parse(b);
      return da.compareTo(db);
    });

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final count = loginsPerDay[key]!;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.green,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
        backgroundColor: Colors.green,
      ),
      body: loginsPerDay.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '📅 Logins per Day',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sortedKeys.length) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              sortedKeys[index],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  barGroups: barGroups,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'Recent Login Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('login_logs')
                    .orderBy('timestamp', descending: true)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final logs = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final email = log['email'] ?? 'Unknown';
                      final timestamp =
                          (log['timestamp'] as Timestamp?)?.toDate() ??
                              DateTime.now();

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.history, color: Colors.green),
                          title: Text(
                            email,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Logged in at: ${DateFormat.yMMMd().add_jm().format(timestamp)}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
