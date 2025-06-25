import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<User?> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('doctors').doc(user.uid).set({
          'name': name,
          'email': email,
        });
      }

      return user;
    } catch (e) {
      throw Exception("SignUp failed: ${e.toString()}");
    }
  }

  Future<void> logOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _auth.signOut();
      }
    } catch (e) {
      throw Exception('Sign Out failed: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<void> updateProfile(
      {required String newName, required String newSpecialization}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Update Firebase Auth display name (optional)
      await user.updateDisplayName(newName);

      // Update Firestore doc
      await _firestore.collection('doctors').doc(user.uid).update({
        'name': newName,
        'specialization': newSpecialization,
      });
    }
  }

  Future<String?> getDoctorName(String doctorUID) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('doctors').doc(doctorUID).get();
      if (doc.exists) {
        return doc.get('name') as String?;
      }
    } catch (e) {
      print('Error getting doctor name: $e');
    }
    return null;
  }

  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('doctors').doc(user.uid).delete();
      await user.delete();
    }
  }
}
