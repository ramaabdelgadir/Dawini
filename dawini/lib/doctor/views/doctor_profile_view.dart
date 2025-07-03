import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../controllers/doctor_auth_controller.dart';
import '../models/doctor_cloud_model.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  final _authCtrl = DoctorAuthController();

  final _name = TextEditingController();
  final _spec = TextEditingController();
  final _addr = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _ln = TextEditingController();
  final _password = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _editing = false;

  DoctorCloudModel? _initial;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    _initial = await _authCtrl.getDoctorProfile();
    if (_initial != null) {
      _name.text = _initial!.name;
      _spec.text = _initial!.specialization;
      _addr.text = _initial!.address;
      _city.text = _initial!.city;
      _phone.text = _initial!.phone;
      _email.text = _initial!.email;
      _ln.text = _initial!.linkedinUrl;
    }
    setState(() => _loading = false);
  }

  /* -------------- حفظ التعديلات -------------- */
  Future<void> _save() async {
    if (_initial == null) return;

    final changed =
        _name.text.trim() != _initial!.name ||
        _spec.text.trim() != _initial!.specialization ||
        _addr.text.trim() != _initial!.address ||
        _city.text.trim() != _initial!.city ||
        _phone.text.trim() != _initial!.phone ||
        _email.text.trim() != _initial!.email ||
        _ln.text.trim() != _initial!.linkedinUrl;

    if (!changed && _password.text.trim().isEmpty) {
      setState(() => _editing = false);
      _toast('لم يتم تعديل أي بيانات');
      return;
    }

    setState(() => _saving = true);
    final updated = DoctorCloudModel(
      uid: _initial!.uid,
      name: _name.text.trim(),
      specialization: _spec.text.trim(),
      address: _addr.text.trim(),
      city: _city.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      linkedinUrl: _ln.text.trim(),
      latitude: _initial!.latitude,
      longitude: _initial!.longitude,
      starCount: _initial!.starCount,
    );

    await _authCtrl.updateDoctorProfile(initial: updated);

    // Update password only if not empty
    if (_password.text.trim().isNotEmpty) {
      await _authCtrl.updatePassword(_password.text.trim());
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
      _editing = false;
      _initial = updated;
      _password.clear();
    });
    _toast('تم الحفظ بنجاح');
  }

  /* -------------- حذف الحساب -------------- */
  Future<void> _confirmAndDelete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            backgroundColor: AppColors.darkBackground,
            title: const Text(
              'حذف الحساب',
              style: const TextStyle(color: Colors.white),
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                child: const Text('حذف', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
    if (yes == true) await _authCtrl.deleteAccount(context);
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, textDirection: TextDirection.rtl),
      backgroundColor: AppColors.plum,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget _infoCard(String label, Widget child) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    decoration: BoxDecoration(
      color: AppColors.darkPlum,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.plumPurple,
              fontFamily: 'Jawadtaut',
              fontSize: 19,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );

  Widget _textOrField(
    TextEditingController c, {
    TextInputType type = TextInputType.text,
  }) {
    if (!_editing) {
      return Text(
        c.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontFamily: 'Din',
        ),
      );
    }
    return TextField(
      controller: c,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
      decoration: const InputDecoration(
        filled: true,
        fillColor: AppColors.deepPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: AppColors.darkPlum),
            onPressed: _confirmAndDelete,
            tooltip: 'حذف الحساب',
          ),
          IconButton(
            icon:
                _saving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Icon(
                      _editing ? Icons.save : Icons.edit,
                      color: Colors.white,
                    ),
            onPressed:
                _saving
                    ? null
                    : _editing
                    ? _save
                    : () => setState(() => _editing = true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.plum),
              )
              : Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.plum,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const CircleAvatar(
                                    radius: 48,
                                    backgroundColor: AppColors.darkPlum,
                                    backgroundImage: AssetImage(
                                      'assets/images/doctor_default.png',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Editable info cards
                            _infoCard('الاسم الكامل', _textOrField(_name)),
                            _infoCard('التخصص', _textOrField(_spec)),
                            _infoCard('العنوان', _textOrField(_addr)),
                            _infoCard('المدينة', _textOrField(_city)),
                            _infoCard(
                              'رقم الهاتف',
                              _textOrField(_phone, type: TextInputType.phone),
                            ),
                            _infoCard(
                              'البريد الإلكتروني',
                              _textOrField(
                                _email,
                                type: TextInputType.emailAddress,
                              ),
                            ),
                            _infoCard('لينكدإن', _textOrField(_ln)),

                            // Password field visible only when editing
                            if (_editing)
                              _infoCard(
                                'كلمة المرور الجديدة',
                                TextField(
                                  controller: _password,
                                  obscureText: true,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Din',
                                  ),
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.deepPurple,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            ElevatedButton(
                              onPressed:
                                  () async => await _authCtrl.logout(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkPlum,
                                minimumSize: const Size(170, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: const Text(
                                'تسجيل الخروج',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Jawadtaut',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: ElevatedButton.icon(
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                'Dawini/Doctor/PatientReports',
                              ),
                          icon: const Icon(
                            Icons.picture_as_pdf_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'تقارير المرضى',
                            style: TextStyle(
                              fontFamily: 'Jawadtaut',
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.plum,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
