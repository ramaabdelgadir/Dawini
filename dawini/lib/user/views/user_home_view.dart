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
                width: screenW * 0.6,
                height: screenH * 0.25,
              ),
              const SizedBox(height: 10),
              const Text(
                'Meet Doctor AI!',
                style: TextStyle(
                  color: AppColors.orchidPink,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Anton',
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
                'Describe your symptoms\nAnd let AI guide you\nTo the right care.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.berryPurple,
                  fontSize: 23,
                  fontFamily: 'Inter',
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 5.0,
                      color: AppColors.deepShadow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
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
                      minimumSize: Size(screenW * 0.3, 65),
                      elevation: 10,
                      shadowColor: AppColors.deepShadow,
                    ),
                    child: const Text(
                      'Let\'s Start Chatting ...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'LuckiestGuy',
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
