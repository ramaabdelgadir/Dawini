import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dawini/doctor/models/doctor_cloud_model.dart';
import 'package:dawini/doctor/controllers/doctor_cloud_controller.dart';
import 'package:dawini/theme/app_colors.dart';

class DoctorSignUpView extends StatefulWidget {
  const DoctorSignUpView({super.key});

  @override
  State<DoctorSignUpView> createState() => _DoctorSignUpViewState();
}

class _DoctorSignUpViewState extends State<DoctorSignUpView> {
  final _auth = FirebaseAuth.instance;
  final DoctorCloudController _cloudController = DoctorCloudController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _signUpDoctor() async {
    if (_nameController.text.trim().isEmpty ||
        _specializationController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _landlineController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;
      final doctor = DoctorCloudModel(
        uid: uid,
        name: _nameController.text.trim(),
        specialization: _specializationController.text.trim(),
        address: _addressController.text.trim(),
        landline: _landlineController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
      );

      await _cloudController.saveDoctorData(doctor);
      Navigator.pushReplacementNamed(context, 'DoctorAI/Doctor/Profile');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.berryPurple,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.deepPurple,
          hintStyle: const TextStyle(color: Color(0xFFB8B6B6)),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                  : null,
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    //final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                // Top Avatar + Title
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.plum,
                  child: Icon(
                    Icons.medical_services,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Doctor Profile',
                  style: TextStyle(
                    color: AppColors.orchidPink,
                    //fontSize:  thirty,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Anton',
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 5,
                        color: AppColors.deepShadow,
                      ),
                    ],
                  ),
                ),

                // PERSONAL INFORMATION
                _buildSectionHeader('Personal Information'),
                _buildTextField(controller: _nameController, hint: 'Full Name'),

                // PROFESSIONAL INFORMATION
                _buildSectionHeader('Professional Information'),
                _buildTextField(
                  controller: _specializationController,
                  hint: 'Specialization',
                ),
                _buildTextField(
                  controller: _addressController,
                  hint: 'Address',
                ),

                // CONTACT INFORMATION
                _buildSectionHeader('Contact Information'),
                _buildTextField(
                  controller: _landlineController,
                  hint: 'Landline Number',
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  controller: _mobileController,
                  hint: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  isPassword: true,
                ),

                const SizedBox(height: 30),

                // SIGN UP BUTTON
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUpDoctor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.plum,
                    minimumSize: Size(screenW * 0.6, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 10,
                    shadowColor: AppColors.deepShadow,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Create Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                ),

                const SizedBox(height: 20),
                // LOGIN REDIRECT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Color(0xFFB8B6B6)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          'Dawini/Doctor/Login',
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: AppColors.berryPurple),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
