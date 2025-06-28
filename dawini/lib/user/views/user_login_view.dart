import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/user/controllers/user_auth_controller.dart';
import 'package:flutter/material.dart';

class UserLoginView extends StatelessWidget {
  const UserLoginView({super.key});

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
  final UserAuthController _authController = UserAuthController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.plum,
          child: Icon(Icons.person, size: 70, color: Colors.white),
        ),
        const SizedBox(height: 40),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,

          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'البريد الإلكتروني ',
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
          ),
          style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'كلمة المرور ',
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
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.plum,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () {
            _authController.login(
              _emailController.text,
              _passwordController.text,
              context,
            );
          },
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
              "جديد في داويني؟",
              style: TextStyle(
                color: Color(0xFFB8B6B6),
                fontSize: 16,
                fontFamily: 'Jawadtaut',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'Dawini/User/Signup');
              },
              child: const Text(
                'سجل الآن',
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
