// ไฟล์นี้สำหรับเก็บ SQL statements และ API ที่เกี่ยวข้องกับฐานข้อมูล
// สำหรับใช้ในกรณีที่ต้องการเชื่อมต่อกับ Web API

class DatabaseApi {
  // ==================== SQL CREATE TABLE ====================

  static const String createPollingStationTable = '''
    CREATE TABLE polling_station (
      station_id INTEGER PRIMARY KEY,
      station_name TEXT NOT NULL,
      zone TEXT NOT NULL,
      province TEXT NOT NULL
    )
  ''';

  static const String createViolationTypeTable = '''
    CREATE TABLE violation_type (
      type_id INTEGER PRIMARY KEY,
      type_name TEXT NOT NULL,
      severity TEXT NOT NULL
    )
  ''';

  static const String createIncidentReportTable = '''
    CREATE TABLE incident_report (
      report_id INTEGER PRIMARY KEY AUTOINCREMENT,
      station_id INTEGER NOT NULL,
      type_id INTEGER NOT NULL,
      reporter_name TEXT NOT NULL,
      description TEXT,
      evidence_photo TEXT,
      timestamp TEXT NOT NULL,
      ai_result TEXT,
      ai_confidence REAL DEFAULT 0.0,
      FOREIGN KEY (station_id) REFERENCES polling_station(station_id),
      FOREIGN KEY (type_id) REFERENCES violation_type(type_id)
    )
  ''';

  // ==================== SQL INSERT SAMPLE DATA ====================

  static const String insertPollingStations = '''
    INSERT INTO polling_station (station_id, station_name, zone, province) VALUES
    (101, 'โรงเรียนวัดพระมหาธาตุ', 'เขต 1', 'นครศรีธรรมราช'),
    (102, 'เต็นท์หน้าตลาดท่าวัง', 'เขต 1', 'นครศรีธรรมราช'),
    (103, 'ศาลากลางหมู่บ้านคีรีวง', 'เขต 2', 'นครศรีธรรมราช'),
    (104, 'หอประชุมอำเภอทุ่งสง', 'เขต 3', 'นครศรีธรรมราช');
  ''';

  static const String insertViolationTypes = '''
    INSERT INTO violation_type (type_id, type_name, severity) VALUES
    (1, 'ซื้อสิทธิ์ขายเสียง (Buying Votes)', 'High'),
    (2, 'ขนคนไปลงคะแนน (Transportation)', 'High'),
    (3, 'หาเสียงเกินเวลา (Overtime Campaign)', 'Medium'),
    (4, 'ทำลายป้ายหาเสียง (Vandalism)', 'Low'),
    (5, 'เจ้าหน้าที่วางตัวไม่เป็นกลาง (Bias Official)', 'High');
  ''';

  static const String insertIncidentReports = '''
    INSERT INTO incident_report (station_id, type_id, reporter_name, description, evidence_photo, timestamp, ai_result, ai_confidence) VALUES
    (101, 1, 'พลเมืองดี 01', 'พบเห็นการแจกเงินบริเวณหน้าหน่วย', NULL, '2026-02-08 09:30:00', 'Money', 0.95),
    (102, 3, 'สมชาย ใจกล้า', 'มีการเปิดรถแห่เสียงดังรบกวน', NULL, '2026-02-08 10:15:00', 'Crowd', 0.75),
    (103, 5, 'Anonymous', 'เจ้าหน้าที่พูดจาชี้นำผู้ลงคะแนน', NULL, '2026-02-08 11:00:00', NULL, 0.0);
  ''';

  // ==================== SQL QUERIES ====================

  static const String selectAllReportsWithDetails = '''
    SELECT 
      ir.*,
      ps.station_name,
      ps.zone,
      ps.province,
      vt.type_name,
      vt.severity
    FROM incident_report ir
    LEFT JOIN polling_station ps ON ir.station_id = ps.station_id
    LEFT JOIN violation_type vt ON ir.type_id = vt.type_id
    ORDER BY ir.timestamp DESC
  ''';
}
