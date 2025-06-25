import 'package:flutter/material.dart';
import 'package:dawini/theme/app_colors.dart';

class DoctorHomeView extends StatelessWidget {
  const DoctorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    //final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   'assets/images/doctor.gif', // make sure this asset exists
              //   width: screenW * 0.6,
              //   height: screenH * 0.25,
              // ),
              const SizedBox(height: 10),
              const Text(
                'Welcome, Doctor!',
                style: TextStyle(
                  color: AppColors.orchidPink,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Anton',
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 5,
                      color: AppColors.deepShadow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Stay connected with your patients.\nMonitor cases. Share your expertise.\nPowered by AI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.berryPurple,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 5,
                        color: AppColors.deepShadow,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    'Dawini/Doctor/Login',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.plum,
                  minimumSize: Size(screenW * 0.3, 60),
                  elevation: 10,
                  shadowColor: AppColors.deepShadow,
                ),
                child: const Text(
                  'Go to Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'LuckiestGuy',
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 5,
                        color: AppColors.deepShadow,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
