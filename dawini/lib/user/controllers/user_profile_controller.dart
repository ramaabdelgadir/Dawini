import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/user/controllers/user_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileController extends ChangeNotifier {
  final UserAuthController _authController = UserAuthController();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<String> get userName async =>
      (await _authController.getUserName()) ?? '';

  String get email => currentUser?.email ?? '';

  Future<void> updateProfile({
    required String newName,
    required String newEmail,
    String newPassword = '',
    required BuildContext context,
  }) async {
    final currentEmail = email.trim();
    final currentName = (await userName).trim();

    if (newName.trim() == currentName &&
        newEmail.trim() == currentEmail &&
        newPassword.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'لا توجد تغييرات للتحديث',
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
    } else {
      if (context.mounted) {
        await _authController.updateProfile(
          newName: newName.trim(),
          newEmail: newEmail.trim(),
          newPassword: newPassword.trim(),
          context: context,
        );
      }
    }
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await _authController.logout(context);
    notifyListeners();
  }

  Future<void> deleteAccount(BuildContext context) async {
    await _authController.deleteAccount(context);
    notifyListeners();
  }
}
