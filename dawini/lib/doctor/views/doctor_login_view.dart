import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/doctor/controllers/doctor_auth_controller.dart';
import 'package:flutter/material.dart';

class DoctorLoginView extends StatelessWidget {
  const DoctorLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Padding(padding: const EdgeInsets.all(20.0), child: LoginForm()),
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
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Email',
            filled: true,
            fillColor: AppColors.deepPurple,
            hintStyle: const TextStyle(color: Color(0xFFB8B6B6)),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Password',
            filled: true,
            fillColor: AppColors.deepPurple,
            hintStyle: const TextStyle(color: Color(0xFFB8B6B6)),
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
          style: const TextStyle(color: Colors.white),
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
            'LogIn',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        const SizedBox(height: 20),

        /* 
            * future work 
            // Forgot Password Text
            TextButton(
              onPressed: () {
                // Handle Forgot Password 
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: Color(0xFFB8B6B6)),
              ),
            ), */

        // Sign Up Text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Not a member?",
              style: TextStyle(color: Color(0xFFB8B6B6)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'Dawini/Doctor/Signup');
              },
              child: const Text(
                'Signup now',
                style: TextStyle(color: AppColors.berryPurple),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
