import 'package:dawini/theme/app_colors.dart';
import '../controllers/doctor_auth_controller.dart';
import 'package:flutter/material.dart';

class DoctorLoginView extends StatelessWidget {
  const DoctorLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: const LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DoctorAuthController _authController = DoctorAuthController();

  bool _isPasswordVisible = false;

  void _attemptLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إدخال البريد الإلكتروني وكلمة المرور',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.plum,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    _authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.plum,
          child: Icon(Icons.medical_services, size: 70, color: Colors.white),
        ),
        const SizedBox(height: 40),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'البريد الإلكتروني',
            filled: true,
            fillColor: AppColors.deepPurple,
            hintStyle: TextStyle(
              color: Color(0xFFB8B6B6),
              fontFamily: 'Din',
              fontSize: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
          ),
          style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _attemptLogin(),
          decoration: InputDecoration(
            hintText: 'كلمة المرور',
            filled: true,
            fillColor: AppColors.deepPurple,
            hintStyle: const TextStyle(
              color: Color(0xFFB8B6B6),
              fontFamily: 'Din',
              fontSize: 17,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed:
                  () => setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  }),
            ),
          ),
          style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
        ),
        const SizedBox(height: 40),

        ElevatedButton(
          onPressed: _attemptLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.plum,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Jawadtaut',
              fontSize: 17,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'جديد في داويني؟',
              style: TextStyle(
                color: Color(0xFFB8B6B6),
                fontSize: 16,
                fontFamily: 'Jawadtaut',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, 'Dawini/Doctor/Signup');
              },
              child: const Text(
                'أنشئ ملفك',
                style: TextStyle(
                  color: AppColors.berryPurple,
                  fontSize: 16,
                  fontFamily: 'Jawadtaut',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
