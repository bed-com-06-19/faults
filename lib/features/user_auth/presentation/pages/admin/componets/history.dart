import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;
  String selectedLocation = 'All';

  Future<List<QueryDocumentSnapshot>> _fetchFixedFaults() async {
    Query query = FirebaseFirestore.instance
        .collection('faults')
        .where('status', isEqualTo: 'fixed');

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs;
  }

  void _resetFilters() {
    setState(() {
      searchQuery = '';
      startDate = null;
      endDate = null;
      selectedLocation = 'All';
    });
  }

  Future<void> _exportAsPDF(List<QueryDocumentSnapshot> faults) async {
    final pdfDoc = pw.Document();
    pdfDoc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text("Fixed Faults Report")),
          pw.Table.fromTextArray(
            headers: ["Pair Name", "Location", "Time Fixed"],
            data: faults.map((fault) {
              final timestamp = fault['timestamp'];
              final formattedTime = timestamp != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      timestamp.toDate().toLocal())
                  : 'Unknown';
              return [
                fault['pairName'],
                fault['location'],
                formattedTime,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/FixedFaults.pdf");
    await file.writeAsBytes(await pdfDoc.save());
    OpenFile.open(file.path);
  }

  Future<void> _exportAsExcel(List<QueryDocumentSnapshot> faults) async {
    final workbook = excel.Workbook();
    final sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('Pair Name');
    sheet.getRangeByName('B1').setText('Location');
    sheet.getRangeByName('C1').setText('Time Fixed');

    for (int i = 0; i < faults.length; i++) {
      final fault = faults[i];
      final timestamp = fault['timestamp'];
      final formattedTime = timestamp != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate().toLocal())
          : 'Unknown';
      sheet.getRangeByIndex(i + 2, 1).setText(fault['pairName']);
      sheet.getRangeByIndex(i + 2, 2).setText(fault['location']);
      sheet.getRangeByIndex(i + 2, 3).setText(formattedTime);
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/FixedFaults.xlsx");
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixed Faults History'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () async {
              final data = await _fetchFixedFaults();
              _exportAsPDF(data);
            },
          ),
          IconButton(
            icon: const Icon(Icons.grid_on),
            tooltip: 'Export Excel',
            onPressed: () async {
              final data = await _fetchFixedFaults();
              _exportAsExcel(data);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Pair Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _resetFilters,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(startDate != null
                      ? DateFormat('yyyy-MM-dd').format(startDate!)
                      : "Start Date"),
                  leading: const Icon(Icons.date_range),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 30)),
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(endDate != null
                      ? DateFormat('yyyy-MM-dd').format(endDate!)
                      : "End Date"),
                  leading: const Icon(Icons.date_range),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        endDate = picked;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('faults')
                  .where('status', isEqualTo: 'fixed')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                List<QueryDocumentSnapshot> faultDocs = snapshot.data!.docs;

                // Apply filters
                faultDocs = faultDocs.where((doc) {
                  final name = doc['pairName'].toString().toLowerCase();
                  final loc = doc['location'].toString().toLowerCase();
                  final ts = doc['timestamp'];

                  final matchesSearch = name.contains(searchQuery);
                  final matchesDate = (startDate == null || ts.toDate().isAfter(startDate!)) &&
                      (endDate == null || ts.toDate().isBefore(endDate!.add(const Duration(days: 1))));

                  return matchesSearch && matchesDate;
                }).toList();

                if (faultDocs.isEmpty) {
                  return const Center(child: Text("No matching results."));
                }

                faultDocs.sort((a, b) {
                  final tsA = a['timestamp'];
                  final tsB = b['timestamp'];
                  return tsB.compareTo(tsA);
                });

                return ListView.builder(
                  itemCount: faultDocs.length,
                  itemBuilder: (context, index) {
                    final fault = faultDocs[index];
                    final pairName = fault['pairName'];
                    final location = fault['location'];
                    final timestamp = fault['timestamp'];
                    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(timestamp.toDate().toLocal());

                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(pairName),
                      subtitle: Text("Location: $location\nTime Fixed: $formattedTime"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
