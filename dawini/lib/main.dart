import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/role_selection_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dawini/user/views/user_home_view.dart';
import 'package:dawini/user/views/user_login_view.dart';
import 'package:dawini/user/views/user_signup_view.dart';
import 'package:dawini/user/views/chat_view.dart';
import 'package:dawini/user/views/user_profile_view.dart';
import 'package:dawini/user/controllers/user_profile_controller.dart';
import 'package:dawini/doctor/views/doctor_home_view.dart';
import 'package:dawini/doctor/views/doctor_login_view.dart';
import 'package:dawini/doctor/views/doctor_signup_view.dart';
import 'package:dawini/doctor/views/doctor_profile_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAaRKxxiSCmGFAO3QJqGYuW3d1Pvccq6ro",
        authDomain: "doctor-ai-61457.firebaseapp.com",
        projectId: "doctor-ai-61457",
        storageBucket: "doctor-ai-61457.firebasestorage.app",
        messagingSenderId: "153963561564",
        appId: "1:153963561564:web:09d34508a1d6408ab61c99",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dawini',
      theme: ThemeData(scaffoldBackgroundColor: AppColors.darkBackground),
      initialRoute: 'Dawini',
      routes: {
        'Dawini': (context) => const RoleSelectionView(),
        'Dawini/User': (context) => const UserOpenUpPage(),
        'Dawini/User/Login': (context) => const UserLoginView(),
        'Dawini/User/Signup': (context) => const UserSignUpView(),
        'Dawini/User/ChatScreen': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return ChatView(chatID: args);
        },
        'Dawini/User/Profile': (context) => const UserProfileView(),
        'Dawini/Doctor': (context) => const DoctorHomeView(),
        'Dawini/Doctor/Login': (context) => const DoctorLoginView(),
        'Dawini/Doctor/Signup': (context) => const DoctorSignUpView(),
        'Dawini/Doctor/Profile': (context) => const DoctorProfileView(),
      },
    );
  }
}
