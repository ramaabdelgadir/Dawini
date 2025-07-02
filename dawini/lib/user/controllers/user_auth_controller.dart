import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/user/models/user_auth_model.dart';

class UserAuthController {
  final UserAuthModel _authModel = UserAuthModel();

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      await _authModel.login(email, password);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || !(await _isProfileComplete(uid))) {
        _showError(
          context,
          ' يبدو أن هذا الحساب غير مخصص لهذا القسم\n يُرجى استخدام الحساب المناسب.',
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('Dawini/User/Login', (route) => false);
        await Future.delayed(Duration(milliseconds: 100));

        await FirebaseAuth.instance.signOut();
        return;
      }

      if (context.mounted) {
        Navigator.pushNamed(context, 'Dawini/User/ChatScreen');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) _showError(context, _translateError(e.code));
    } catch (_) {
      if (context.mounted) _showError(context, 'حدث خطأ غير متوقع');
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
    BuildContext context,
  ) async {
    try {
      await _authModel.signUp(email, password, name);
      if (context.mounted) {
        Navigator.pushNamed(context, 'Dawini/User/ChatScreen');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) _showError(context, _translateError(e.code));
    } catch (_) {
      if (context.mounted) _showError(context, 'حدث خطأ غير متوقع');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _authModel.logOut();
    } on FirebaseAuthException catch (e) {
      if (context.mounted) _showError(context, _translateError(e.code));
    } catch (_) {
      if (context.mounted) _showError(context, 'حدث خطأ أثناء تسجيل الخروج');
    }
  }

  Future<void> updateProfile({
    required String newName,
    required String newEmail,
    String newPassword = '',
    required BuildContext context,
  }) async {
    bool errorOccurred = false;

    try {
      await _authModel.updateName(newName);
    } on FirebaseAuthException catch (e) {
      errorOccurred = true;
      if (context.mounted) _showError(context, _translateError(e.code));
    }

    try {
      await _authModel.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      errorOccurred = true;
      if (context.mounted) _showError(context, _translateError(e.code));
    }

    if (newPassword.isNotEmpty) {
      try {
        await _authModel.updatePassword(newPassword);
      } on FirebaseAuthException catch (e) {
        errorOccurred = true;
        if (context.mounted) _showError(context, _translateError(e.code));
      }
    }

    if (!errorOccurred && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم تحديث بياناتك بنجاح',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.plum,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      await _authModel.deleteAccount();
    } on FirebaseAuthException catch (e) {
      if (context.mounted) _showError(context, _translateError(e.code));
    } catch (_) {
      if (context.mounted) _showError(context, 'حدث خطأ أثناء حذف الحساب');
    }
  }

  Future<String?> getUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      return await _authModel.getUserName(uid);
    }
    return null;
  }

  Future<bool> _isProfileComplete(String uid) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!snapshot.exists) return false;

      final data = snapshot.data();
      final hasName = (data?['name'] as String?)?.trim().isNotEmpty ?? false;
      final hasEmail = (data?['email'] as String?)?.trim().isNotEmpty ?? false;

      return hasName && hasEmail;
    } catch (e) {
      return false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: AppColors.plum,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
      'requires-recent-login': 'يجب تسجيل الدخول مجدداً لتنفيذ هذه العملية',
    };
    return map[code] ?? 'خطأ غير متوقع ($code)';
  }
}
