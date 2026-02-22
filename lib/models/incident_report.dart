class IncidentReport {
  final int? reportId;
  final int stationId;
  final int typeId;
  final String reporterName;
  final String description;
  final String? evidencePhoto;
  final String timestamp;
  final String? aiResult;
  final double aiConfidence;

  IncidentReport({
    this.reportId,
    required this.stationId,
    required this.typeId,
    required this.reporterName,
    required this.description,
    this.evidencePhoto,
    required this.timestamp,
    this.aiResult,
    this.aiConfidence = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'report_id': reportId,
      'station_id': stationId,
      'type_id': typeId,
      'reporter_name': reporterName,
      'description': description,
      'evidence_photo': evidencePhoto,
      'timestamp': timestamp,
      'ai_result': aiResult,
      'ai_confidence': aiConfidence,
    };
  }

  factory IncidentReport.fromMap(Map<String, dynamic> map) {
    return IncidentReport(
      reportId: map['report_id'],
      stationId: map['station_id'],
      typeId: map['type_id'],
      reporterName: map['reporter_name'],
      description: map['description'],
      evidencePhoto: map['evidence_photo'],
      timestamp: map['timestamp'],
      aiResult: map['ai_result'],
      aiConfidence: (map['ai_confidence'] ?? 0.0).toDouble(),
    );
  }
}
