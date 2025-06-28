import 'package:flutter/material.dart';
import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/doctor/controllers/doctor_profile_controller.dart';
import 'package:dawini/doctor/models/doctor_cloud_model.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  /* ───────── controller ───────── */
  final DoctorProfileController _profileController = DoctorProfileController();

  /* ───────── form controllers ───────── */
  final TextEditingController _nameC = TextEditingController();
  final TextEditingController _specC = TextEditingController();
  final TextEditingController _addrC = TextEditingController();
  final TextEditingController _cityC = TextEditingController();
  final TextEditingController _phoneC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _lnC = TextEditingController();
  final TextEditingController _fbC = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confPass = TextEditingController();

  /* ───────── flags ───────── */
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUpdatingPassword = false;
  bool _isDeleting = false;
  bool _showNew = false;
  bool _showConf = false;

  String? _uid;

  /* ───────── lifecycle ───────── */
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await _profileController.getDoctorProfile(context);
    if (data != null) {
      _uid = data.uid;
      _nameC.text = data.name;
      _specC.text = data.specialization;
      _addrC.text = data.address;
      _cityC.text = data.city;
      _phoneC.text = data.phone;
      _emailC.text = data.email;
      _lnC.text = data.linkedinUrl;
      _fbC.text = data.facebookUrl;
    }
    setState(() => _isLoading = false);
  }

  /* ───────── validation helper ───────── */
  void _localSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textDirection: TextDirection.rtl),
        backgroundColor: AppColors.plum,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 515, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /* ───────── save profile ───────── */
  Future<void> _saveProfile() async {
    if (_uid == null) return;

    if (_nameC.text.trim().isEmpty ||
        _specC.text.trim().isEmpty ||
        _addrC.text.trim().isEmpty ||
        _cityC.text.trim().isEmpty ||
        _phoneC.text.trim().isEmpty ||
        _emailC.text.trim().isEmpty ||
        _lnC.text.trim().isEmpty ||
        _fbC.text.trim().isEmpty) {
      _localSnack('يرجى تعبئة جميع الحقول');
      return;
    }

    setState(() => _isSaving = true);

    final doc = DoctorCloudModel(
      uid: _uid!,
      name: _nameC.text.trim(),
      specialization: _specC.text.trim(),
      address: _addrC.text.trim(),
      city: _cityC.text.trim(),
      phone: _phoneC.text.trim(),
      email: _emailC.text.trim(),
      linkedinUrl: _lnC.text.trim(),
      facebookUrl: _fbC.text.trim(),
    );

    await _profileController.updateDoctorProfile(doc, context);
    setState(() => _isSaving = false);
  }

  /* ───────── password ───────── */
  Future<void> _changePass() async {
    final newP = _newPass.text.trim();
    final conf = _confPass.text.trim();
    if (newP.isEmpty || conf.isEmpty) {
      _localSnack('يرجى تعبئة حقلي كلمة المرور');
      return;
    }
    if (newP != conf) {
      _localSnack('كلمات المرور غير متطابقة');
      return;
    }
    setState(() => _isUpdatingPassword = true);
    await _profileController.updatePassword(newP, context);
    _newPass.clear();
    _confPass.clear();
    setState(() => _isUpdatingPassword = false);
  }

  /* ───────── delete ───────── */
  Future<void> _deleteAcc() async {
    setState(() => _isDeleting = true);
    await _profileController.deleteAccount(context);
    await _profileController.signOut();
    setState(() => _isDeleting = false);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        'Dawini/Doctor/Login',
        (_) => false,
      );
    }
  }

  /* ───────── UI helpers ───────── */
  Widget _header(String t) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(
      t,
      style: const TextStyle(
        color: AppColors.berryPurple,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Jawadtaut',
        shadows: [
          Shadow(
            offset: Offset(1, 1),
            blurRadius: 5,
            color: AppColors.deepShadow,
          ),
        ],
      ),
    ),
  );

  Widget _field({
    required TextEditingController c,
    required String hint,
    TextInputType type = TextInputType.text,
    bool pass = false,
    bool visible = false,
    VoidCallback? toggle,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: c,
      keyboardType: type,
      obscureText: pass && !visible,
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
                  icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggle,
                )
                : null,
      ),
      style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
    ),
  );

  /* ───────── build ───────── */
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: AppColors.plum),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.plum,
                            child: Text(
                              _nameC.text.isEmpty ? '?' : _nameC.text[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontFamily: 'Jawadtaut',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            _nameC.text,
                            style: const TextStyle(
                              color: AppColors.orchidPink,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jawadtaut',
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

                        /* personal */
                        _header('البيانات الشخصية'),
                        _field(c: _nameC, hint: 'الاسم الكامل'),
                        _field(c: _specC, hint: 'التخصص'),
                        _field(c: _addrC, hint: 'العنوان الكامل'),
                        _field(c: _cityC, hint: 'المدينة'),

                        /* contact */
                        _header('بيانات الاتصال'),
                        _field(
                          c: _phoneC,
                          hint: 'رقم الهاتف',
                          type: TextInputType.phone,
                        ),
                        _field(
                          c: _emailC,
                          hint: 'البريد الإلكتروني',
                          type: TextInputType.emailAddress,
                        ),

                        /* social */
                        _header('روابط السوشيال ميديا'),
                        _field(c: _lnC, hint: 'رابط لينكدإن'),
                        _field(c: _fbC, hint: 'رابط فيسبوك'),

                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
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
                                    'حفظ التغييرات',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Jawadtaut',
                                    ),
                                  ),
                        ),

                        /* password */
                        _header('تغيير كلمة المرور'),
                        _field(
                          c: _newPass,
                          hint: 'كلمة مرور جديدة',
                          pass: true,
                          visible: _showNew,
                          toggle: () => setState(() => _showNew = !_showNew),
                        ),
                        _field(
                          c: _confPass,
                          hint: 'تأكيد كلمة المرور',
                          pass: true,
                          visible: _showConf,
                          toggle: () => setState(() => _showConf = !_showConf),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _isUpdatingPassword ? null : _changePass,
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
                                    'تحديث كلمة المرور',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Jawadtaut',
                                    ),
                                  ),
                        ),

                        /* delete */
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isDeleting ? null : _deleteAcc,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkPlum,
                            minimumSize: Size(screenW * 0.6, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child:
                              _isDeleting
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'حذف الحساب',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Jawadtaut',
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
