import 'package:flutter/material.dart';
import 'package:dawini/theme/app_colors.dart';

class DoctorHomeView extends StatelessWidget {
  const DoctorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/dhome.png',
                width: screenW * 0.9,
                height: screenH * 0.25,
              ),
              const SizedBox(height: 10),
              const Text(
                'أهلاً بك في داويني',
                style: TextStyle(
                  color: AppColors.orchidPink,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'YaModernPro',
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 5.0,
                      color: AppColors.deepShadow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'شبكة تربط المرضى بالأطباء المختصين \nابدأ بإعداد ملفك الطبي \nوكن جزءًا من شبكة داويني',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.berryPurple,
                    fontSize: 24,
                    fontFamily: 'Jawadtaut',
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
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'Dawini/Doctor/Login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.plum,
                  minimumSize: Size(screenW * 0.6, 60),
                  elevation: 10,
                  shadowColor: AppColors.deepShadow,
                ),
                child: const Text(
                  'ابدأ الآن',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontFamily: 'YaModernPro',
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
