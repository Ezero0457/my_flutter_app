import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await _dbHelper.getAllIncidentReportsWithDetails();
    setState(() {
      _reports = reports;
    });
  }

  Color _getSeverityColor(String? severity) {
    switch (severity) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteReport(int reportId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบการแจ้งเหตุนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteIncidentReport(reportId);
      _loadReports();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบการแจ้งเหตุสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการแจ้งเหตุ'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _reports.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ไม่มีรายการแจ้งเหตุ',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                final severity = report['severity'] as String?;
                final severityColor = _getSeverityColor(severity);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                report['type_name'] ?? 'ไม่ระบุประเภท',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: severityColor),
                              ),
                              child: Text(
                                severity ?? '-',
                                style: TextStyle(
                                  color: severityColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Station info
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${report['station_name']} (${report['zone']})',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Reporter
                        Row(
                          children: [
                            const Icon(Icons.person,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'ผู้แจ้ง: ${report['reporter_name']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Timestamp
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              report['timestamp'] ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        if (report['description'] != null &&
                            report['description'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            report['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        // AI Result
                        if (report['ai_result'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.smart_toy,
                                  size: 16, color: Colors.purple),
                              const SizedBox(width: 4),
                              Text(
                                'AI: ${report['ai_result']} (${((report['ai_confidence'] ?? 0.0) * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Delete button
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () =>
                                _deleteReport(report['report_id']),
                            icon:
                                const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'ลบ',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
