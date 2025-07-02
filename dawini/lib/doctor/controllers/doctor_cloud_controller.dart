// lib/doctor/controllers/doctor_cloud_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_cloud_model.dart';

class DoctorCloudController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'doctors';

  Future<void> saveDoctorData(DoctorCloudModel doctor) async {
    await _firestore.collection(collection).doc(doctor.uid).set(doctor.toMap());
  }

  Future<void> deleteDoctorData(String uid) async {
    await _firestore.collection(collection).doc(uid).delete();
  }

  Future<DoctorCloudModel?> getDoctorData(String uid) async {
    final doc = await _firestore.collection(collection).doc(uid).get();
    if (doc.exists) {
      return DoctorCloudModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateDoctorData(DoctorCloudModel doctor) async {
    await _firestore
        .collection(collection)
        .doc(doctor.uid)
        .update(doctor.toMap());
  }
}
