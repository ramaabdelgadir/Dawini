import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientReportsController {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getPatientReports() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Doctor not logged in');

    final snapshot =
        await _fire
            .collection('doctors')
            .doc(uid)
            .collection('patientReports')
            .orderBy('sentAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
