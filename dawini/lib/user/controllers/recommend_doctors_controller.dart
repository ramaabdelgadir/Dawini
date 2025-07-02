import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/medical_form_model.dart';
import 'package:dawini/doctor/models/doctor_cloud_model.dart';

class RecommendDoctorsController {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const String _reportApi =
      'https://8000-dep-01jywqr3484cy10dx1gxz7mhha-d.cloudspaces.litng.ai/generate-report/';
  static const String _recommendApi =
      'https://8000-dep-01jywqr3484cy10dx1gxz7mhha-d.cloudspaces.litng.ai/recommend-doctor/';

  static final RecommendDoctorsController _instance =
      RecommendDoctorsController._internal();
  factory RecommendDoctorsController() => _instance;
  RecommendDoctorsController._internal();

  List<DoctorCloudModel> _recommendedDoctors = [];
  String? _recommendedClass;

  Future<String> submitForm(MedicalFormModel form) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final docRef = await _fire
        .collection('users')
        .doc(uid)
        .collection('medicalForms')
        .add(form.toMap());

    return docRef.id;
  }

  Future<String> generateAndSaveReport(
    MedicalFormModel form,
    String medicalFormDocId,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final userSnap = await _fire.collection('users').doc(uid).get();
    final userName = userSnap.data()?['name'] ?? 'User';
    final genderCode =
        (form.gender == 'ذكر' || form.gender.toUpperCase() == 'M') ? 'M' : 'F';

    final info = [
      userName,
      form.age,
      genderCode,
      form.ethnicity,
      form.residence,
      form.weight,
      form.height,
      form.caseDetails,
    ];

    final res = await http.post(
      Uri.parse(_reportApi),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'info': info}),
    );
    if (res.statusCode != 200) {
      throw Exception('API error (report): ${res.body}');
    }

    final pdfUrl = (jsonDecode(res.body)['report_url'] ?? '') as String;
    if (pdfUrl.isEmpty) throw Exception('PDF URL missing in response');

    await _fire
        .collection('users')
        .doc(uid)
        .collection('medicalForms')
        .doc(medicalFormDocId)
        .update({'report': pdfUrl});

    return pdfUrl;
  }

  Future<List<DoctorCloudModel>> recommendByCase(String caseDetail) async {
    final res = await http.post(
      Uri.parse(_recommendApi),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'case': caseDetail}),
    );
    if (res.statusCode != 200) {
      throw Exception('API error (recommend): ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    final specialization = decoded['specialization'] as String?;
    if (specialization == null || specialization.isEmpty) {
      throw Exception('Invalid specialization from API');
    }

    _recommendedClass = specialization;
    await getDoctorsByClass(specialization);

    return _recommendedDoctors;
  }

  Future<void> getDoctorsByClass(String doctorClass) async {
    final q =
        await _fire
            .collection('doctors')
            .where('specialization', isEqualTo: doctorClass)
            .get();

    _recommendedDoctors =
        q.docs.map((d) => DoctorCloudModel.fromMap(d.data())).toList();
  }

  Future<List<DoctorCloudModel>> filterDoctorsByLocation(
    Position userPosition, {
    double thresholdKm = 30,
  }) async {
    if (_recommendedDoctors.isEmpty) return [];

    final filtered =
        _recommendedDoctors.where((doc) {
          final meters = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            doc.latitude,
            doc.longitude,
          );
          return meters <= thresholdKm * 1000;
        }).toList();

    _recommendedDoctors = filtered;
    return filtered;
  }

  Future<void> sendReportToDoctor(String doctorUid) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final q =
        await _fire
            .collection('users')
            .doc(uid)
            .collection('medicalForms')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

    if (q.docs.isEmpty) throw Exception('No medical form found');

    final doc = q.docs.first;
    final pdfUrl = doc['report'] as String? ?? '';
    if (pdfUrl.isEmpty) throw Exception('Report not generated yet');

    await _fire
        .collection('doctors')
        .doc(doctorUid)
        .collection('patientReports')
        .add({
          'patientId': uid,
          'pdfUrl': pdfUrl,
          'sentAt': FieldValue.serverTimestamp(),
        });
  }

  List<DoctorCloudModel> getRecommendedDoctors() => _recommendedDoctors;
  String? getRecommendedClass() => _recommendedClass;
}
