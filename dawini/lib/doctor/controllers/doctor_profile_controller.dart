import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dawini/doctor/controllers/doctor_cloud_controller.dart';
import 'package:dawini/doctor/models/doctor_cloud_model.dart';
import 'package:dawini/theme/app_colors.dart';

class DoctorProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DoctorCloudController _cloudController = DoctorCloudController();

  String? getCurrentUID() => _auth.currentUser?.uid;

  Future<DoctorCloudModel?> getDoctorProfile(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await _cloudController.getDoctorData(user.uid);
    } catch (e) {
      _showSnackBar(context, 'خطأ في جلب البيانات: ${e.toString()}');
      return null;
    }
  }

  Future<void> updateDoctorProfile(
    DoctorCloudModel doctor,
    BuildContext context,
  ) async {
    try {
      await _cloudController.updateDoctorData(doctor);
      _showSnackBar(context, 'تم تحديث الملف بنجاح');
    } catch (e) {
      _showSnackBar(context, 'فشل تحديث الملف: ${e.toString()}');
    }
  }

  Future<void> updatePassword(String newPassword, BuildContext context) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      _showSnackBar(context, 'تم تحديث كلمة المرور بنجاح');
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'فشل تحديث كلمة المرور.';
      if (e.code == 'requires-recent-login') {
        message =
            'يرجى تسجيل الخروج ثم تسجيل الدخول مرة أخرى لتغيير كلمة المرور.';
      }
      _showSnackBar(context, message);
    } catch (e) {
      _showSnackBar(context, 'حدث خطأ: ${e.toString()}');
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      await _cloudController.deleteDoctorData(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
      _showSnackBar(context, 'تم حذف الحساب بنجاح');
    } catch (e) {
      _showSnackBar(context, 'فشل حذف الحساب: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: AppColors.plum,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 515, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
