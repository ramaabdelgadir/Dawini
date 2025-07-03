import 'package:dawini/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartupView extends StatefulWidget {
  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final doctorDoc =
          await FirebaseFirestore.instance.collection('doctors').doc(uid).get();

      if (userDoc.exists) {
        Navigator.pushReplacementNamed(context, 'Dawini/User/ChatScreen');
      } else if (doctorDoc.exists) {
        Navigator.pushReplacementNamed(context, 'Dawini/Doctor/Profile');
      } else {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, 'Dawini');
      }
    } else {
      Navigator.pushReplacementNamed(context, 'Dawini');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
