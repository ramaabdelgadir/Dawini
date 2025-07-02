import 'package:dawini/doctor/controllers/doctor_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:dawini/theme/app_colors.dart';

class DoctorSignUpView extends StatefulWidget {
  const DoctorSignUpView({super.key});

  @override
  State<DoctorSignUpView> createState() => _DoctorSignUpViewState();
}

class _DoctorSignUpViewState extends State<DoctorSignUpView> {
  final DoctorAuthController _authContr = DoctorAuthController();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _specialization = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _linkedin = TextEditingController();
  final TextEditingController _facebook = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _showPass = false;
  bool _loading = false;

  void _signUp() async {
    if (_name.text.isEmpty ||
        _specialization.text.isEmpty ||
        _address.text.isEmpty ||
        _city.text.isEmpty ||
        _phone.text.isEmpty ||
        _linkedin.text.isEmpty ||
        _facebook.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تعبئة جميع الحقول',
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

    setState(() => _loading = true);

    try {
      await _authContr.signUp(
        email: _email.text,
        password: _password.text,
        name: _name.text,
        phone: _phone.text,
        address: _address.text,
        city: _city.text,
        specialization: _specialization.text,
        linkedinUrl: _linkedin.text,
        context: context,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التسجيل: $e'),
          backgroundColor: AppColors.plum,

          margin: const EdgeInsets.only(bottom: 700, left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _field({
    required TextEditingController c,
    required String hint,
    TextInputType type = TextInputType.text,
    bool pass = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        keyboardType: type,
        obscureText: pass && !_showPass,
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
                      _showPass ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  )
                  : null,
        ),
        style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                const SizedBox(height: 12),
                const Text(
                  'إنشاء ملف الطبيب',
                  style: TextStyle(
                    color: AppColors.orchidPink,
                    fontSize: 27,
                    fontFamily: 'Jawadtaut',
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '  المعلومات الشخصية',
                    style: TextStyle(
                      color: AppColors.berryPurple,
                      fontSize: 25,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _field(c: _name, hint: 'الاسم الكامل'),
                _field(c: _specialization, hint: 'التخصص'),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '  معلومات العنوان',
                    style: TextStyle(
                      color: AppColors.berryPurple,
                      fontSize: 25,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _field(c: _address, hint: 'العنوان الكامل'),
                _field(c: _city, hint: 'المدينة'),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '  بيانات الاتصال',
                    style: TextStyle(
                      color: AppColors.berryPurple,
                      fontSize: 25,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _field(
                  c: _phone,
                  hint: 'رقم الهاتف',
                  type: TextInputType.phone,
                ),
                _field(
                  c: _email,
                  hint: 'البريد الإلكتروني',
                  type: TextInputType.emailAddress,
                ),
                _field(c: _password, hint: 'كلمة المرور', pass: true),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '  الروابط المهنية',
                    style: TextStyle(
                      color: AppColors.berryPurple,
                      fontSize: 25,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _field(c: _linkedin, hint: 'رابط لينكدإن'),
                _field(c: _facebook, hint: 'رابط فيسبوك'),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _loading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.plum,
                    minimumSize: Size(w * .6, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child:
                      _loading
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
                              fontSize: 17,
                              fontFamily: 'Jawadtaut',
                            ),
                          ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'عندك حساب؟',
                      style: TextStyle(
                        color: Color(0xFFB8B6B6),
                        fontFamily: 'Jawadtaut',
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.pushNamed(
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
    );
  }
}
