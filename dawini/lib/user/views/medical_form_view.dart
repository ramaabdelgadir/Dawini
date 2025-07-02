import 'package:flutter/material.dart';
import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/user/controllers/recommend_doctors_controller.dart';
import 'package:dawini/user/models/medical_form_model.dart';

class MedicalFormView extends StatefulWidget {
  const MedicalFormView({Key? key}) : super(key: key);

  @override
  State<MedicalFormView> createState() => _MedicalFormViewState();
}

class _MedicalFormViewState extends State<MedicalFormView> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _caseDetailsController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _residenceController = TextEditingController();

  final _controller = RecommendDoctorsController();
  final GlobalKey<TooltipState> _helpKey = GlobalKey<TooltipState>();

  String _gender = 'ذكر';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _helpKey.currentState?.ensureTooltipVisible();
    });
  }

  Future<void> _handleSubmit() async {
    if (_ageController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _ethnicityController.text.isEmpty ||
        _residenceController.text.isEmpty ||
        _caseDetailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
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

    final form = MedicalFormModel(
      age: _ageController.text.trim(),
      weight: _weightController.text.trim(),
      height: _heightController.text.trim(),
      ethnicity: _ethnicityController.text.trim(),
      residence: _residenceController.text.trim(),
      gender: _gender,
      caseDetails: _caseDetailsController.text.trim(),
      createdAt: DateTime.now(),
      report: '',
    );

    try {
      final docId = await _controller.submitForm(form);
      await _controller.generateAndSaveReport(form, docId);
      await _controller.recommendByCase(form.caseDetails);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم إنشاء التقرير واقتراح الأطباء بنجاح',
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
      Navigator.pushNamed(context, 'Dawini/User/RecommendedDoctors');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e', textDirection: TextDirection.rtl),
          backgroundColor: AppColors.plum,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: Tooltip(
          key: _helpKey,
          message:
              'سيُنشئ النظام تقريراً طبياً من بيانات النموذج، ثم تظهر قائمة الأطباء لإرسال التقرير.  بياناتك محفوظة بسرية تامة.',
          textStyle: const TextStyle(
            fontFamily: 'Din',
            color: Colors.white,
            fontSize: 13,
          ),
          decoration: BoxDecoration(
            color: AppColors.darkPlum,
            borderRadius: BorderRadius.circular(10),
          ),
          waitDuration: const Duration(milliseconds: 100),
          showDuration: const Duration(seconds: 6),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: const Icon(Icons.help_outline, color: Color(0xFFB8B6B6)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Directionality(
              textDirection: TextDirection.rtl,
              child: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
        toolbarHeight: 48,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'البيانات الأساسية',
                    style: TextStyle(
                      color: AppColors.berryPurple,
                      fontSize: 27,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_ageController, 'العمر')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          _weightController,
                          'الوزن',
                          suffix: 'كجم',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          _heightController,
                          'الطول',
                          suffix: 'سم',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'الموقع والجنسية',
                    style: TextStyle(
                      color: AppColors.berryPurple,
                      fontSize: 25,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_ethnicityController, 'الجنسية'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          _residenceController,
                          'مكان الإقامة',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'الجنس',
                    style: TextStyle(
                      color: AppColors.berryPurple,
                      fontSize: 25,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          activeColor: AppColors.plum,
                          title: const Text(
                            'ذكر',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Din',
                            ),
                          ),
                          value: 'ذكر',
                          groupValue: _gender,
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RadioListTile<String>(
                          activeColor: AppColors.plum,
                          title: const Text(
                            'أنثى',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Din',
                            ),
                          ),
                          value: 'أنثى',
                          groupValue: _gender,
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تفاصيل الحالة',
                    style: TextStyle(
                      color: AppColors.berryPurple,
                      fontSize: 25,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _caseDetailsController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.deepPurple,
                      hintText: 'اكتب العرض الرئيسي وتسلسل الأعراض...',
                      hintStyle: const TextStyle(color: Color(0xFFB8B6B6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.plum,
                        padding: const EdgeInsets.symmetric(
                          vertical: 17,
                          horizontal: 50,
                        ),
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
                                'إرسال البيانات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Jawadtaut',
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        filled: true,
        fillColor: AppColors.deepPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Color(0xFFB8B6B6), fontFamily: 'Din'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
    );
  }
}
