import 'package:dawini/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenW * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Who are you?",
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Anton',
                    color: AppColors.orchidPink,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: AppColors.deepShadow,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Choose your role to get started",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Inter',
                    color: AppColors.berryPurple,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed:
                      () => {Navigator.pushNamed(context, 'Dawini/User')},
                  icon: const Icon(Icons.person, size: 28),
                  label: const Text(
                    "I’m a User",
                    style: TextStyle(fontSize: 19, fontFamily: 'Anton'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.berryPurple,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: AppColors.deepShadow,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed:
                      () => {Navigator.pushNamed(context, 'Dawini/Doctor')},
                  icon: const Icon(Icons.medical_services, size: 28),
                  label: const Text(
                    "I’m a Doctor",
                    style: TextStyle(fontSize: 18, fontFamily: 'Anton'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softLilac,
                    foregroundColor: AppColors.berryPurple,
                    elevation: 10,
                    shadowColor: AppColors.deepShadow,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(color: AppColors.berryPurple),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
