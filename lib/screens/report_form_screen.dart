import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../models/polling_station.dart';
import '../models/violation_type.dart';
import '../models/incident_report.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<PollingStation> _stations = [];
  List<ViolationType> _violationTypes = [];

  int? _selectedStationId;
  int? _selectedTypeId;
  final TextEditingController _reporterNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final stations = await _dbHelper.getAllPollingStations();
    final types = await _dbHelper.getAllViolationTypes();
    setState(() {
      _stations = stations;
      _violationTypes = types;
    });
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedStationId == null || _selectedTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณาเลือกหน่วยเลือกตั้งและประเภทความผิด'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final report = IncidentReport(
        stationId: _selectedStationId!,
        typeId: _selectedTypeId!,
        reporterName: _reporterNameController.text.trim(),
        description: _descriptionController.text.trim(),
        evidencePhoto: null,
        timestamp: now,
        aiResult: null,
        aiConfidence: 0.0,
      );

      await _dbHelper.insertIncidentReport(report);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกการแจ้งเหตุสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _reporterNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แจ้งเหตุทุจริต'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // เลือกหน่วยเลือกตั้ง
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('หน่วยเลือกตั้ง',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedStationId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'เลือกหน่วยเลือกตั้ง',
                        ),
                        items: _stations.map((station) {
                          return DropdownMenuItem<int>(
                            value: station.stationId,
                            child: Text(
                              '${station.stationId} - ${station.stationName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStationId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'กรุณาเลือกหน่วยเลือกตั้ง' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // เลือกประเภทความผิด
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ประเภทความผิด',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedTypeId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'เลือกประเภทความผิด',
                        ),
                        items: _violationTypes.map((type) {
                          return DropdownMenuItem<int>(
                            value: type.typeId,
                            child: Text(
                              type.typeName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTypeId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'กรุณาเลือกประเภทความผิด' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ชื่อผู้แจ้ง
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ข้อมูลผู้แจ้ง',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reporterNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'ชื่อผู้แจ้งเหตุ',
                          hintText: 'กรอกชื่อผู้แจ้งเหตุ',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'กรุณากรอกชื่อผู้แจ้ง'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // รายละเอียด
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('รายละเอียด',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'รายละเอียดเพิ่มเติม',
                          hintText: 'อธิบายเหตุการณ์ที่พบเห็น',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ปุ่มบันทึก
              ElevatedButton.icon(
                onPressed: _submitReport,
                icon: const Icon(Icons.save),
                label: const Text('บันทึกการแจ้งเหตุ',
                    style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
