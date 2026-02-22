import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../models/polling_station.dart';
import '../models/violation_type.dart';
import '../models/incident_report.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // สร้างตาราง polling_station
    await db.execute('''
      CREATE TABLE ${AppConstants.tablePollingStation} (
        station_id INTEGER PRIMARY KEY,
        station_name TEXT NOT NULL,
        zone TEXT NOT NULL,
        province TEXT NOT NULL
      )
    ''');

    // สร้างตาราง violation_type
    await db.execute('''
      CREATE TABLE ${AppConstants.tableViolationType} (
        type_id INTEGER PRIMARY KEY,
        type_name TEXT NOT NULL,
        severity TEXT NOT NULL
      )
    ''');

    // สร้างตาราง incident_report
    await db.execute('''
      CREATE TABLE ${AppConstants.tableIncidentReport} (
        report_id INTEGER PRIMARY KEY AUTOINCREMENT,
        station_id INTEGER NOT NULL,
        type_id INTEGER NOT NULL,
        reporter_name TEXT NOT NULL,
        description TEXT,
        evidence_photo TEXT,
        timestamp TEXT NOT NULL,
        ai_result TEXT,
        ai_confidence REAL DEFAULT 0.0,
        FOREIGN KEY (station_id) REFERENCES ${AppConstants.tablePollingStation}(station_id),
        FOREIGN KEY (type_id) REFERENCES ${AppConstants.tableViolationType}(type_id)
      )
    ''');

    // เพิ่มข้อมูลตัวอย่าง
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // ข้อมูลตัวอย่าง polling_station
    await db.insert(AppConstants.tablePollingStation, {
      'station_id': 101,
      'station_name': 'โรงเรียนวัดพระมหาธาตุ',
      'zone': 'เขต 1',
      'province': 'นครศรีธรรมราช',
    });
    await db.insert(AppConstants.tablePollingStation, {
      'station_id': 102,
      'station_name': 'เต็นท์หน้าตลาดท่าวัง',
      'zone': 'เขต 1',
      'province': 'นครศรีธรรมราช',
    });
    await db.insert(AppConstants.tablePollingStation, {
      'station_id': 103,
      'station_name': 'ศาลากลางหมู่บ้านคีรีวง',
      'zone': 'เขต 2',
      'province': 'นครศรีธรรมราช',
    });
    await db.insert(AppConstants.tablePollingStation, {
      'station_id': 104,
      'station_name': 'หอประชุมอำเภอทุ่งสง',
      'zone': 'เขต 3',
      'province': 'นครศรีธรรมราช',
    });

    // ข้อมูลตัวอย่าง violation_type
    await db.insert(AppConstants.tableViolationType, {
      'type_id': 1,
      'type_name': 'ซื้อสิทธิ์ขายเสียง (Buying Votes)',
      'severity': 'High',
    });
    await db.insert(AppConstants.tableViolationType, {
      'type_id': 2,
      'type_name': 'ขนคนไปลงคะแนน (Transportation)',
      'severity': 'High',
    });
    await db.insert(AppConstants.tableViolationType, {
      'type_id': 3,
      'type_name': 'หาเสียงเกินเวลา (Overtime Campaign)',
      'severity': 'Medium',
    });
    await db.insert(AppConstants.tableViolationType, {
      'type_id': 4,
      'type_name': 'ทำลายป้ายหาเสียง (Vandalism)',
      'severity': 'Low',
    });
    await db.insert(AppConstants.tableViolationType, {
      'type_id': 5,
      'type_name': 'เจ้าหน้าที่วางตัวไม่เป็นกลาง (Bias Official)',
      'severity': 'High',
    });

    // ข้อมูลตัวอย่าง incident_report
    await db.insert(AppConstants.tableIncidentReport, {
      'station_id': 101,
      'type_id': 1,
      'reporter_name': 'พลเมืองดี 01',
      'description': 'พบเห็นการแจกเงินบริเวณหน้าหน่วย',
      'evidence_photo': null,
      'timestamp': '2026-02-08 09:30:00',
      'ai_result': 'Money',
      'ai_confidence': 0.95,
    });
    await db.insert(AppConstants.tableIncidentReport, {
      'station_id': 102,
      'type_id': 3,
      'reporter_name': 'สมชาย ใจกล้า',
      'description': 'มีการเปิดรถแห่เสียงดังรบกวน',
      'evidence_photo': null,
      'timestamp': '2026-02-08 10:15:00',
      'ai_result': 'Crowd',
      'ai_confidence': 0.75,
    });
    await db.insert(AppConstants.tableIncidentReport, {
      'station_id': 103,
      'type_id': 5,
      'reporter_name': 'Anonymous',
      'description': 'เจ้าหน้าที่พูดจาชี้นำผู้ลงคะแนน',
      'evidence_photo': null,
      'timestamp': '2026-02-08 11:00:00',
      'ai_result': null,
      'ai_confidence': 0.0,
    });
  }

  // ==================== CRUD Operations ====================

  // --- Polling Station ---
  Future<List<PollingStation>> getAllPollingStations() async {
    final db = await database;
    final result = await db.query(AppConstants.tablePollingStation);
    return result.map((map) => PollingStation.fromMap(map)).toList();
  }

  Future<PollingStation?> getPollingStationById(int id) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tablePollingStation,
      where: 'station_id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return PollingStation.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertPollingStation(PollingStation station) async {
    final db = await database;
    return await db.insert(AppConstants.tablePollingStation, station.toMap());
  }

  Future<int> updatePollingStation(PollingStation station) async {
    final db = await database;
    return await db.update(
      AppConstants.tablePollingStation,
      station.toMap(),
      where: 'station_id = ?',
      whereArgs: [station.stationId],
    );
  }

  Future<int> deletePollingStation(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tablePollingStation,
      where: 'station_id = ?',
      whereArgs: [id],
    );
  }

  // --- Violation Type ---
  Future<List<ViolationType>> getAllViolationTypes() async {
    final db = await database;
    final result = await db.query(AppConstants.tableViolationType);
    return result.map((map) => ViolationType.fromMap(map)).toList();
  }

  Future<ViolationType?> getViolationTypeById(int id) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableViolationType,
      where: 'type_id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ViolationType.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertViolationType(ViolationType type) async {
    final db = await database;
    return await db.insert(AppConstants.tableViolationType, type.toMap());
  }

  Future<int> updateViolationType(ViolationType type) async {
    final db = await database;
    return await db.update(
      AppConstants.tableViolationType,
      type.toMap(),
      where: 'type_id = ?',
      whereArgs: [type.typeId],
    );
  }

  Future<int> deleteViolationType(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableViolationType,
      where: 'type_id = ?',
      whereArgs: [id],
    );
  }

  // --- Incident Report ---
  Future<List<IncidentReport>> getAllIncidentReports() async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableIncidentReport,
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => IncidentReport.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllIncidentReportsWithDetails() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        ir.*,
        ps.station_name,
        ps.zone,
        ps.province,
        vt.type_name,
        vt.severity
      FROM ${AppConstants.tableIncidentReport} ir
      LEFT JOIN ${AppConstants.tablePollingStation} ps ON ir.station_id = ps.station_id
      LEFT JOIN ${AppConstants.tableViolationType} vt ON ir.type_id = vt.type_id
      ORDER BY ir.timestamp DESC
    ''');
    return result;
  }

  Future<int> insertIncidentReport(IncidentReport report) async {
    final db = await database;
    final map = report.toMap();
    map.remove('report_id'); // ให้ Auto Increment
    return await db.insert(AppConstants.tableIncidentReport, map);
  }

  Future<int> updateIncidentReport(IncidentReport report) async {
    final db = await database;
    return await db.update(
      AppConstants.tableIncidentReport,
      report.toMap(),
      where: 'report_id = ?',
      whereArgs: [report.reportId],
    );
  }

  Future<int> deleteIncidentReport(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableIncidentReport,
      where: 'report_id = ?',
      whereArgs: [id],
    );
  }

  // ปิดฐานข้อมูล
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
