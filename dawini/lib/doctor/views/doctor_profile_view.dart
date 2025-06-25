// lib/doctor/views/doctor_profile_view.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dawini/doctor/controllers/doctor_auth_controller.dart';
import 'package:dawini/doctor/controllers/doctor_cloud_controller.dart';
import 'package:dawini/doctor/models/doctor_cloud_model.dart';
import 'package:dawini/theme/app_colors.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  final _auth = FirebaseAuth.instance;
  final DoctorCloudController _cloudController = DoctorCloudController();
  final DoctorAuthController _authController = DoctorAuthController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUpdatingPassword = false;
  bool _isDeletingAccount = false;
  bool _isNewPassVisible = false;
  bool _isConfirmPassVisible = false;

  String? _uid;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pop(context);
      return;
    }
    _uid = user.uid;

    final doctor = await _cloudController.getDoctorData(user.uid);
    if (doctor != null) {
      _nameController.text = doctor.name;
      _specializationController.text = doctor.specialization;
      _addressController.text = doctor.address;
      _landlineController.text = doctor.landline;
      _mobileController.text = doctor.mobile;
      _emailController.text = doctor.email;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfileUpdates() async {
    if (_uid == null) return;

    if (_nameController.text.trim().isEmpty ||
        _specializationController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _landlineController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all profile fields.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updatedDoctor = DoctorCloudModel(
      uid: _uid!,
      name: _nameController.text.trim(),
      specialization: _specializationController.text.trim(),
      address: _addressController.text.trim(),
      landline: _landlineController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim(),
    );

    try {
      await _cloudController.updateDoctorData(updatedDoctor);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both password fields.')),
      );
      return;
    }
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    setState(() => _isUpdatingPassword = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPass);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully.')),
        );
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Password update failed.';
      if (e.code == 'requires-recent-login') {
        message = 'Please log out and log back in to change password.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isUpdatingPassword = false);
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeletingAccount = true);
    await _authController.deleteAccount(context);

    // After deleteAccount, sign‐out to clear any local state, then navigate to login
    try {
      await _auth.signOut();
    } catch (_) {}
    setState(() => _isDeletingAccount = false);
    Navigator.pushNamedAndRemoveUntil(
      context,
      'DoctorAI/Doctor/Login',
      (route) => false,
    );
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
    bool isVisible = false,
    void Function()? toggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && !isVisible,
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
                      isVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: toggleVisibility,
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

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.plum),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // AVATAR + NAME
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.plum,
                          child: Text(
                            _nameController.text.isEmpty
                                ? '?'
                                : _nameController.text[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _nameController.text,
                          style: const TextStyle(
                            color: AppColors.orchidPink,
                            fontSize: 28,
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
                      ),

                      _buildSectionHeader('Personal Information'),
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Full Name',
                      ),

                      _buildSectionHeader('Professional Information'),
                      _buildTextField(
                        controller: _specializationController,
                        hint: 'Specialization',
                      ),
                      _buildTextField(
                        controller: _addressController,
                        hint: 'Address',
                      ),

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

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfileUpdates,
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
                            _isSaving
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),

                      _buildSectionHeader('Change Password'),
                      _buildTextField(
                        controller: _newPasswordController,
                        hint: 'New Password',
                        isPassword: true,
                        isVisible: _isNewPassVisible,
                        toggleVisibility: () {
                          setState(() {
                            _isNewPassVisible = !_isNewPassVisible;
                          });
                        },
                      ),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm Password',
                        isPassword: true,
                        isVisible: _isConfirmPassVisible,
                        toggleVisibility: () {
                          setState(() {
                            _isConfirmPassVisible = !_isConfirmPassVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isUpdatingPassword ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.plum,
                          minimumSize: Size(screenW * 0.6, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.deepShadow,
                        ),
                        child:
                            _isUpdatingPassword
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Update Password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isDeletingAccount ? null : _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPlum,
                          minimumSize: Size(screenW * 0.6, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child:
                            _isDeletingAccount
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
      ),
    );
  }
}
