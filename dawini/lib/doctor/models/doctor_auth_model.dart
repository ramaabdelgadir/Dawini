import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Low‑level service: handles Firebase Auth + Firestore only.
/// No UI / context references here.
class DoctorAuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  /* ─────────────────────────────── LOGIN ─────────────────────────────── */

  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      // Re‑throw so controller can translate the code.
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  /* ────────────────────────────── SIGN UP ────────────────────────────── */

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String specialization,
    required String linkedinUrl,
    required String facebookUrl,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = cred.user;

      if (user != null) {
        // Persist profile in Firestore
        await _store.collection('doctors').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'city': city,
          'specialization': specialization,
          'linkedinUrl': linkedinUrl,
          'facebookUrl': facebookUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  /* ──────────────────────────── LOG OUT ──────────────────────────────── */

  Future<void> logOut() async {
    await _auth.signOut();
  }

  /* ───────────────────────── UPDATE PROFILE ──────────────────────────── */

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? specialization,
    String? phone,
    String? address,
    String? city,
    String? linkedinUrl,
    String? facebookUrl,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (specialization != null) data['specialization'] = specialization;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;
    if (linkedinUrl != null) data['linkedinUrl'] = linkedinUrl;
    if (facebookUrl != null) data['facebookUrl'] = facebookUrl;

    if (data.isNotEmpty) {
      await _store.collection('doctors').doc(uid).update(data);
      // Sync displayName in Auth if name changed
      if (name != null) {
        await _auth.currentUser?.updateDisplayName(name);
      }
    }
  }
}
