import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorReportModel {
  final String patientId;
  final String pdfUrl;
  final DateTime uploadedAt;

  DoctorReportModel({
    required this.patientId,
    required this.pdfUrl,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {'patientId': patientId, 'pdfUrl': pdfUrl, 'uploadedAt': uploadedAt};
  }

  factory DoctorReportModel.fromMap(Map<String, dynamic> map) {
    return DoctorReportModel(
      patientId: map['patientId'] as String,
      pdfUrl: map['pdfUrl'] as String,
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
    );
  }
}
