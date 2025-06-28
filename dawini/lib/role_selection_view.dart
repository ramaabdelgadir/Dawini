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
                  "جاهز نبدأ؟",
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'YaModernPro',
                    color: AppColors.orchidPink,
                    //fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: AppColors.deepShadow,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "حدد نوع حسابك للمتابعة",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21.5,
                    fontFamily: 'Jawadtaut',
                    color: AppColors.berryPurple,
                  ),
                ),
                const SizedBox(height: 33),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ElevatedButton.icon(
                    onPressed:
                        () => Navigator.pushNamed(context, 'Dawini/User'),
                    icon: const Icon(Icons.person, size: 29),
                    label: const Text(
                      "استشارة طبية",
                      style: TextStyle(fontSize: 24, fontFamily: 'Jawadtaut'),
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
                ),
                const SizedBox(height: 20),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ElevatedButton.icon(
                    onPressed:
                        () => Navigator.pushNamed(context, 'Dawini/Doctor'),
                    icon: const Icon(Icons.medical_services, size: 28),
                    label: const Text(
                      "طبيب",
                      style: TextStyle(fontSize: 26, fontFamily: 'Jawadtaut'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softLilac,
                      foregroundColor: AppColors.berryPurple,
                      elevation: 10,
                      shadowColor: AppColors.deepShadow,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(color: AppColors.berryPurple),
                      ),
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
  // void _navigateTo(String routeName) async {
  //   setState(() => _isLoading = true);

  //   await Future.delayed(const Duration(milliseconds: 700)); 

  //   if (mounted) {
  //     setState(() => _isLoading = false);
  //     Navigator.pushNamed(context, routeName);
  //   }
  // }