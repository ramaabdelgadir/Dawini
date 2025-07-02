import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalFormModel {
  final String age;
  final String weight;
  final String height;
  final String ethnicity;
  final String residence;
  final String gender;
  final String caseDetails;
  final DateTime createdAt;
  final String report;

  MedicalFormModel({
    required this.age,
    required this.weight,
    required this.height,
    required this.ethnicity,
    required this.residence,
    required this.gender,
    required this.caseDetails,
    required this.createdAt,
    required this.report,
  });

  Map<String, dynamic> toMap() {
    return {
      'العمر': age,
      'الوزن': weight,
      'الطول': height,
      'الجنسية': ethnicity,
      'مكان الإقامة': residence,
      'الجنس': gender,
      'تفاصيل الحالة': caseDetails,
      'createdAt': createdAt,
      'report': report,
    };
  }

  factory MedicalFormModel.fromMap(Map<String, dynamic> map) {
    return MedicalFormModel(
      age: map['العمر'] ?? '',
      weight: map['الوزن'] ?? '',
      height: map['الطول'] ?? '',
      ethnicity: map['الجنسية'] ?? '',
      residence: map['مكان الإقامة'] ?? '',
      gender: map['الجنس'] ?? '',
      caseDetails: map['تفاصيل الحالة'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      report: map['report'] ?? '',
    );
  }
}
