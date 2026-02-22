import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../constants/app_constants.dart';
import 'report_form_screen.dart';
import 'report_list_screen.dart';
import 'classifier_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  int _totalReports = 0;
  int _totalStations = 0;
  int _highSeverityCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final reports = await _dbHelper.getAllIncidentReportsWithDetails();
    final stations = await _dbHelper.getAllPollingStations();

    setState(() {
      _totalReports = reports.length;
      _totalStations = stations.length;
      _highSeverityCount =
          reports.where((r) => r['severity'] == 'High').length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'แดชบอร์ด',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDashboardCard(
                  'การแจ้งเหตุทั้งหมด',
                  '$_totalReports',
                  Icons.report,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildDashboardCard(
                  'หน่วยเลือกตั้ง',
                  '$_totalStations',
                  Icons.location_on,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildDashboardCard(
                  'ความรุนแรงสูง',
                  '$_highSeverityCount',
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'เมนู',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context,
              'แจ้งเหตุทุจริต',
              'บันทึกการแจ้งเหตุทุจริตใหม่',
              Icons.add_circle_outline,
              Colors.orange,
              () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportFormScreen()),
                );
                _loadDashboardData();
              },
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context,
              'ตรวจสอบภาพ',
              'ตรวจสอบภาพที่ถูกส่งมา',
              Icons.add_circle_outline,
              Colors.green,
              () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ImageClassifierScreen()),
                );
                _loadDashboardData();
              },
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context,
              'รายการแจ้งเหตุ',
              'ดูรายการแจ้งเหตุทุจริตทั้งหมด',
              Icons.list_alt,
              Colors.indigo,
              () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportListScreen()),
                );
                _loadDashboardData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
