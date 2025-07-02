import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawini/theme/app_colors.dart';
import '../models/doctor_auth_model.dart';
import '../models/doctor_cloud_model.dart';

class DoctorAuthController {
  final DoctorAuthModel _model = DoctorAuthModel();

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _model.login(email, password);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || !(await _isProfileComplete(uid))) {
        _showError(
          context,
          ' يبدو أن هذا الحساب غير مخصص لهذا القسم\n يُرجى استخدام الحساب المناسب.',
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('Dawini/Doctor/Login', (route) => false);
        await Future.delayed(Duration(milliseconds: 100));

        await FirebaseAuth.instance.signOut();
        return;
      }

      Navigator.of(context).pushNamed('Dawini/Doctor/Profile');
    } on FirebaseAuthException catch (e) {
      _showError(context, _translateError(e.code));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String specialization,
    required String linkedinUrl,
    required BuildContext context,
  }) async {
    try {
      await _model.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
        city: city,
        specialization: specialization,
        linkedinUrl: linkedinUrl,
      );
      if (context.mounted) {
        Navigator.pushNamed(context, 'Dawini/Doctor/Profile');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) _showError(context, _translateError(e.code));
    }
  }

  Future<void> logout(BuildContext context) async {
    if (context.mounted) {
      Navigator.pushNamed(context, 'Dawini/Doctor/Login');
    }
    try {
      await _model.logOut();
    } catch (_) {}
  }

  Future<void> deleteAccount(BuildContext context) async {
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        'Dawini/Doctor/Login',
        (_) => false,
      );
    }
    await _model.deleteAccount();
  }

  Future<DoctorCloudModel?> getDoctorProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) return await _model.getDoctorProfile(uid);
    return null;
  }

  Future<void> updateDoctorProfile({required DoctorCloudModel initial}) async {
    await _model.updateProfile(
      uid: initial.uid,
      name: initial.name,
      specialization: initial.specialization,
      phone: initial.phone,
      address: initial.address,
      city: initial.city,
      linkedinUrl: initial.linkedinUrl,
      email: initial.email,
    );
  }

  Future<void> updatePassword(String newPassword) async =>
      _model.updatePassword(newPassword);

  Future<bool> _isProfileComplete(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('doctors').doc(uid).get();
      if (!doc.exists) return false;
      final data = doc.data();
      final hasName = (data?['name'] as String?)?.trim().isNotEmpty ?? false;
      final hasSpecialization =
          (data?['specialization'] as String?)?.trim().isNotEmpty ?? false;
      final hasEmail = (data?['email'] as String?)?.trim().isNotEmpty ?? false;
      return hasName && hasSpecialization && hasEmail;
    } catch (_) {
      return false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.plum,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _translateError(String code) {
    const map = {
      'invalid-email': 'تنسيق البريد الإلكتروني غير صالح',
      'user-disabled': 'تم تعطيل هذا المستخدم',
      'user-not-found': 'لا يوجد مستخدم بهذا البريد',
      'wrong-password': 'كلمة المرور غير صحيحة',
      'email-already-in-use': 'البريد مستخدم من قبل',
      'weak-password': 'كلمة المرور ضعيفة – استخدم 6 أحرف فأكثر',
      'too-many-requests': 'محاولات كثيرة. انتظر قليلاً',
      'network-request-failed': 'تعذّر الاتصال بالإنترنت',
      'requires-recent-login': 'يجب تسجيل الدخول مجدداً لتنفيذ هذه العملية',
    };
    return map[code] ?? 'خطأ في التسجيل ($code)';
  }
}
