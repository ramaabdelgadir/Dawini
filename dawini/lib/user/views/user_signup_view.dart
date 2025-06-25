import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/user/controllers/user_auth_controller.dart';
import 'package:flutter/material.dart';

class UserSignUpView extends StatelessWidget {
  const UserSignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Padding(padding: const EdgeInsets.all(20.0), child: SignUpForm()),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
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
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Enter Your First Name',
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
          onPressed: () {
            _authController.signUp(
              _emailController.text,
              _passwordController.text,
              _nameController.text,
              context,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.plum,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'SignUp',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already a member?",
              style: TextStyle(color: Color(0xFFB8B6B6)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'Dawini/User/Login');
              },
              child: const Text(
                'Login',
                style: TextStyle(color: AppColors.berryPurple),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
