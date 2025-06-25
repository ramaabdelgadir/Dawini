import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/user/controllers/user_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileController extends ChangeNotifier {
  final UserAuthController _authController = UserAuthController();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<String> get userName async {
    String? name = await _authController.getUserName();
    return name ?? '';
  }

  String get email => currentUser?.email ?? '';

  Future<void> updateProfile({
    required String newName,
    required String newEmail,
    String newPassword = '',
    required BuildContext context,
  }) async {
    final currentEmail = email;
    final currentName = await userName;

    // Check if there are any changes.
    if (newName == currentName &&
        newEmail == currentEmail &&
        newPassword.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No changes to update.'),
            backgroundColor: AppColors.plum,
          ),
        );
      }
    } else {
      if (context.mounted) {
        await _authController.updateProfile(
          newName: newName,
          newEmail: newEmail,
          newPassword: newPassword,
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
