import 'package:dawini/doctor/models/doctor_auth_model.dart';
import 'package:dawini/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorAuthController {
  final DoctorAuthModel _authModel = DoctorAuthModel();

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      await _authModel.login(email, password);
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          'Dawini/Doctor/ProfileScreen',
        ); // doctor profile page
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
        Navigator.pushReplacementNamed(context, 'Dawini/Doctor/Profile');
      }
    } catch (e) {
      if (context.mounted) {
        _showError(
          context,
          '(SignUp failed) ${_formatFirebaseError(e.toString())}',
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

  Future<String?> getDoctorName() async {
    final doctorUID = FirebaseAuth.instance.currentUser!.uid;
    return await _authModel.getDoctorName(doctorUID);
  }

  Future<void> updateProfile({
    required String newName,
    required String newSpecialization,
    required BuildContext context,
  }) async {
    try {
      await _authModel.updateProfile(
        newName: newName,
        newSpecialization: newSpecialization,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.plum,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(
          context,
          '(Error updating profile) ${_formatFirebaseError(e.toString())}',
        );
      }
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
