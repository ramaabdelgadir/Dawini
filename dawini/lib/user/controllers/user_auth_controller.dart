import 'package:dawini/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, 'Dawini/User/ChatScreen');
      }
    } catch (e) {
      if (context.mounted) {
        _showError(
          context,
          '(Login failed) ${_formatFirebaseError(e.toString())}',
        );
      }
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
        Navigator.pushReplacementNamed(context, 'Dawini/User/ChatScreen');
      }
    } catch (e) {
      if (context.mounted) {
        _showError(
          context,
          '(Sign Up failed) ${_formatFirebaseError(e.toString())}',
        );
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _authModel.logOut();
    } catch (e) {
      if (context.mounted) {
        _showError(context, '(Error) ${_formatFirebaseError(e.toString())}');
      }
    }
  }

  Future<String?> getUserName() async {
    final userUID = FirebaseAuth.instance.currentUser!.uid;
    return await _authModel.getUserName(userUID);
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
    } catch (e) {
      errorOccurred = true;
      if (context.mounted) {
        _showError(
          context,
          '(Error updating name) ${_formatFirebaseError(e.toString())}',
        );
      }
    }

    try {
      await _authModel.updateEmail(newEmail);
    } catch (e) {
      errorOccurred = true;
      if (context.mounted) {
        _showError(
          context,
          '(Error updating email) ${_formatFirebaseError(e.toString())}',
        );
      }
    }

    try {
      if (newPassword.isNotEmpty) {
        await _authModel.updatePassword(newPassword);
      }
    } catch (e) {
      errorOccurred = true;
      if (context.mounted) {
        _showError(
          context,
          '(Error updating password) ${_formatFirebaseError(e.toString())}',
        );
      }
    }

    if (!errorOccurred && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your data has been updated successfully'),
          backgroundColor: AppColors.plum,
        ),
      );
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      await _authModel.deleteAccount();
    } catch (e) {
      if (context.mounted) {
        _showError(
          context,
          '(Error deleting account) ${_formatFirebaseError(e.toString())}',
        );
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.plum,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 515, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

String _formatFirebaseError(String error) {
  RegExp regex = RegExp(r'\[firebase_auth/([\w-]+)\]\s*(.+)');
  Match? match = regex.firstMatch(error);
  return match != null ? '${match.group(1)}: ${match.group(2)}' : error;
}
