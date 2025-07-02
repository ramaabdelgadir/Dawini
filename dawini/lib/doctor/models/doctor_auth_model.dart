import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import '../models/doctor_cloud_model.dart';

class DoctorAuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  /* ───────── LOGIN ───────── */
  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return cred.user;
  }

  /* ───────── SIGN‑UP ───────── */
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String specialization,
    required String linkedinUrl,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = cred.user;
    if (user == null) return;

    double lat = 0, lng = 0;
    try {
      final loc = await locationFromAddress('$address, $city');
      if (loc.isNotEmpty) {
        lat = loc.first.latitude;
        lng = loc.first.longitude;
      }
    } catch (_) {}

    final doc = DoctorCloudModel(
      uid: user.uid,
      name: name,
      specialization: specialization,
      address: address,
      city: city,
      phone: phone,
      email: email,
      linkedinUrl: linkedinUrl,
      latitude: lat,
      longitude: lng,
      starCount: 0,
    );

    await _store.collection('doctors').doc(user.uid).set(doc.toMap());
  }

  /* ───────── BASIC ACTIONS ───────── */
  Future<void> logOut() async => _auth.signOut();

  Future<DoctorCloudModel?> getDoctorProfile(String uid) async {
    final snap = await _store.collection('doctors').doc(uid).get();
    return snap.exists ? DoctorCloudModel.fromMap(snap.data()!) : null;
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? specialization,
    String? phone,
    String? address,
    String? city,
    String? linkedinUrl,
    String? email,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (specialization != null) data['specialization'] = specialization;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;
    if (linkedinUrl != null) data['linkedinUrl'] = linkedinUrl;
    if (email != null) data['email'] = email;

    if (address != null || city != null) {
      final addr = address ?? '';
      final cty = city ?? '';
      try {
        final loc = await locationFromAddress('$addr, $cty');
        if (loc.isNotEmpty) {
          data['latitude'] = loc.first.latitude;
          data['longitude'] = loc.first.longitude;
        }
      } catch (_) {}
    }

    if (data.isNotEmpty) {
      await _store.collection('doctors').doc(uid).update(data);
      if (name != null) await _auth.currentUser?.updateDisplayName(name);
      if (email != null)
        await _auth.currentUser?.verifyBeforeUpdateEmail(email);
    }
  }

  Future<void> updatePassword(String newPassword) async =>
      _auth.currentUser?.updatePassword(newPassword.trim());

  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _store.collection('doctors').doc(uid).delete();
      await _auth.currentUser?.delete();
    }
  }
}
