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
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _signUpDoctor() async {
    if (_nameController.text.trim().isEmpty ||
        _specializationController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _linkedinController.text.trim().isEmpty ||
        _facebookController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تعبئة جميع الحقول',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.plum,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 515, left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        linkedinUrl: _linkedinController.text.trim(),
        facebookUrl: _facebookController.text.trim(),
      );

      await _cloudController.saveDoctorData(doctor);
      Navigator.pushReplacementNamed(context, 'Dawini/Doctor/Profile');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل التسجيل: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.berryPurple,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Jawadtaut',
          shadows: [
            Shadow(
              offset: Offset(1.0, 1.0),
              blurRadius: 5.0,
              color: AppColors.deepShadow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController c,
    required String hint,
    TextInputType type = TextInputType.text,
    bool pass = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: c,
        keyboardType: type,
        obscureText: pass ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          hintText: hint,
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
          suffixIcon:
              pass
                  ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                  )
                  : null,
        ),
        style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
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
                    'إنشاء ملف الطبيب',
                    style: TextStyle(
                      color: AppColors.orchidPink,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),

                  _header('البيانات الشخصية'),
                  _field(c: _nameController, hint: 'الاسم الكامل'),
                  _field(c: _specializationController, hint: 'التخصص'),
                  _field(c: _addressController, hint: 'العنوان الكامل'),
                  _field(c: _cityController, hint: 'المدينة'),

                  _header('بيانات الاتصال'),
                  _field(c: _phoneController, hint: 'رقم الهاتف'),
                  _field(c: _emailController, hint: 'البريد الإلكتروني'),
                  _field(
                    c: _passwordController,
                    hint: 'كلمة المرور',
                    pass: true,
                  ),

                  _header('روابط السوشيال ميديا'),
                  _field(c: _linkedinController, hint: 'رابط حساب لينكدإن'),
                  _field(c: _facebookController, hint: 'رابط حساب فيسبوك'),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUpDoctor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.plum,
                      minimumSize: Size(screenW * 0.6, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 10,
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
                              'إنشاء الملف',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Jawadtaut',
                              ),
                            ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'عندك حساب في داويني؟',
                        style: TextStyle(
                          color: Color(0xFFB8B6B6),
                          fontFamily: 'Jawadtaut',
                        ),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushReplacementNamed(
                              context,
                              'Dawini/Doctor/Login',
                            ),
                        child: const Text(
                          'سجّل دخولك',
                          style: TextStyle(
                            color: AppColors.berryPurple,
                            fontFamily: 'Jawadtaut',
                          ),
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
      ),
    );
  }
}
