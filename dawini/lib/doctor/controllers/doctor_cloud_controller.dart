// lib/doctor/controllers/doctor_cloud_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_cloud_model.dart';

class DoctorCloudController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'doctors';

  Future<void> saveDoctorData(DoctorCloudModel doctor) async {
    await _firestore.collection(collection).doc(doctor.uid).set(doctor.toMap());
  }

  Future<DoctorCloudModel?> getDoctorData(String uid) async {
    final doc = await _firestore.collection(collection).doc(uid).get();
    if (doc.exists) {
      return DoctorCloudModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// New: Overwrite existing doctor document with updated data
  Future<void> updateDoctorData(DoctorCloudModel doctor) async {
    await _firestore
        .collection(collection)
        .doc(doctor.uid)
        .update(doctor.toMap());
  }
}
