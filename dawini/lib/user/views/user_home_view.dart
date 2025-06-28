import 'package:dawini/theme/app_colors.dart';
import 'package:flutter/material.dart';

class UserOpenUpPage extends StatelessWidget {
  const UserOpenUpPage({super.key});
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
                'assets/images/home.png',
                width: screenW * 0.7,
                height: screenH * 0.25,
              ),
              const Text(
                'داويني',
                style: TextStyle(
                  color: AppColors.orchidPink,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TIDO',
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 5.0,
                      color: AppColors.deepShadow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                ' بداية طريقك للعلاج  ',
                style: TextStyle(
                  color: Color.fromARGB(
                    255,
                    175,
                    110,
                    188,
                  ), //Color.fromARGB(255, 140, 88, 151)
                  fontSize: 26,
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
              const SizedBox(height: 10),
              const Text(
                ' من تحليل الأعراض  \nإلى اختيار الطبيب المناسب\n  معاك في كل خطوة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.berryPurple,
                  fontSize: 24,
                  fontFamily: 'Jawadtaut',
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 5.0,
                      color: AppColors.deepShadow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 65),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        'Dawini/User/Login',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.plum,
                      minimumSize: Size(screenW * 0.6, 63),
                      elevation: 10,
                      shadowColor: AppColors.deepShadow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'ابدأ رحلتك مع داويني',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'YaModernPro',
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 5.0,
                            color: AppColors.deepShadow,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -66,
                    left: -30,
                    child: Image.asset(
                      'assets/images/h.gif',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
