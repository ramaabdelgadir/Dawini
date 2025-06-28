import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dawini/theme/app_colors.dart';
import '../models/doctor_auth_model.dart';

/// High‑level controller: connects UI with DoctorAuthModel,
/// translates Firebase errors ➜ Arabic, shows SnackBars, handles navigation.
class DoctorAuthController {
  final DoctorAuthModel _model = DoctorAuthModel();

  /* ─────────────────────────────── LOGIN ─────────────────────────────── */

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _model.login(email, password);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, 'Dawini/Doctor/Profile');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showError(context, _translateError(e.code));
      }
    }
  }

  /* ────────────────────────────── SIGN UP ────────────────────────────── */

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String specialization,
    required String linkedinUrl,
    required String facebookUrl,
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
        facebookUrl: facebookUrl,
      );
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, 'Dawini/Doctor/Profile');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showError(context, _translateError(e.code));
      }
    }
  }

  /* ─────────────────────────── LOG OUT ──────────────────────────────── */

  Future<void> logout(BuildContext context) async {
    try {
      await _model.logOut();
    } catch (e) {
      if (context.mounted) _showError(context, 'حدث خطأ أثناء تسجيل الخروج');
    }
  }

  /* ─────────────────────── UPDATE PROFILE ───────────────────────────── */

  Future<void> updateProfile({
    String? name,
    String? specialization,
    String? phone,
    String? address,
    String? city,
    String? linkedinUrl,
    String? facebookUrl,
    required BuildContext context,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _model.updateProfile(
        uid: uid,
        name: name,
        specialization: specialization,
        phone: phone,
        address: address,
        city: city,
        linkedinUrl: linkedinUrl,
        facebookUrl: facebookUrl,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث الملف بنجاح'),
            backgroundColor: AppColors.plum,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 515, left: 20, right: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showError(context, 'لم يتم تحديث الملف – جرِّب مرة أخرى');
      }
    }
  }

  /* ────────────────────────── UTILITIES ─────────────────────────────── */

  /* ─── SnackBar helper ─── */
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: AppColors.plum,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 515, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /* ─── Firebase error code ➜ Arabic message ─── */
  String _translateError(String code) {
    const map = <String, String>{
      'invalid-email': 'تنسيق البريد الإلكتروني غير صالح',
      'user-disabled': 'تم تعطيل هذا المستخدم',
      'user-not-found': 'لا يوجد مستخدم بهذا البريد',
      'wrong-password': 'كلمة المرور غير صحيحة',
      'email-already-in-use': 'البريد مستخدم من قبل',
      'weak-password': 'كلمة المرور ضعيفة – استخدم 6 أحرف فأكثر',
      'too-many-requests': 'محاولات كثيرة. انتظر قليلاً',
      'network-request-failed': 'تعذّر الاتصال بالإنترنت',
    };
    return map[code] ?? 'خطأ غير متوقع (${code})';
  }
}
