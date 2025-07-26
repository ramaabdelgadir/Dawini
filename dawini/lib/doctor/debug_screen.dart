import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawini/theme/app_colors.dart';

class ImportDoctorsDebugScreen extends StatefulWidget {
  const ImportDoctorsDebugScreen({super.key});

  @override
  State<ImportDoctorsDebugScreen> createState() =>
      _ImportDoctorsDebugScreenState();
}

class _ImportDoctorsDebugScreenState extends State<ImportDoctorsDebugScreen> {
  final bool _verbose = true;
  static const int _delayPerRowSec = 40;

  bool _isImporting = false;
  int _currentRow = 0;

  static const Map<String, String> _headerAlias = {
    'الاسم': 'name',
    'العنوان': 'address',
    'المحافظة': 'city',
    'خط العرض': 'lat',
    'خط الطول': 'lng',
    'التخصص': 'specialization',
    'لينكد إن': 'linkedin',
    'رقم الهاتف': 'phone',
    'التقييم': 'star',
    'كلمة المرور': 'password',
    'البريد الالكتروني': 'email',
  };

  void _log(Object? m) {
    if (_verbose) debugPrint('$m');
  }

  String _cellStr(List<Data?> row, String key, Map<String, int> col) {
    final idx = col[key] ?? -1;
    return (idx >= 0 && idx < row.length && row[idx] != null)
        ? '${row[idx]!.value}'
        : '';
  }

  double _cellDouble(List<Data?> row, String key, Map<String, int> col) =>
      double.tryParse(_cellStr(row, key, col)) ?? 0.0;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textDirection: TextDirection.rtl),
        backgroundColor: AppColors.plum,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _importDoctors() async {
    setState(() {
      _isImporting = true;
      _currentRow = 0;
    });

    int ok = 0, skip = 0, fail = 0;

    try {
      final bytes =
          (await rootBundle.load(
            'assets/images/doctors.xlsx',
          )).buffer.asUint8List();
      final sheet = Excel.decodeBytes(bytes).tables['data22'];
      if (sheet == null) throw Exception('لا توجد ورقة باسم Sheet1 في الملف.');

      final Map<String, int> col = {};
      final headerRow = sheet.row(0);
      for (int c = 0; c < headerRow.length; c++) {
        final raw = headerRow[c]?.value?.toString().trim() ?? '';
        if (raw.isEmpty) continue;
        final key = _headerAlias[raw] ?? raw;
        col[key.toLowerCase()] = c;
      }

      if (!col.containsKey('email') || !col.containsKey('password')) {
        throw Exception(
          'يجب أن يحتوي الملف على عمود البريد الالكتروني وكلمة المرور',
        );
      }

      final auth = FirebaseAuth.instance;
      final fs = FirebaseFirestore.instance;
      const int startRow = 401;
      const int endRow = 402;

      for (int r = startRow; r <= endRow && r < sheet.maxRows; r++) {
        setState(() => _currentRow = r);
        final row = sheet.row(r);

        final email = _cellStr(row, 'email', col).trim().toLowerCase();
        final pass = _cellStr(row, 'password', col).trim();

        if (email.isEmpty || pass.isEmpty) {
          _log('Row $r → empty email/password');
          fail++;
          await Future.delayed(const Duration(seconds: _delayPerRowSec));
          continue;
        }
        if (pass.length < 6) {
          _log('Row $r ($email) → weak password');
          fail++;
          await Future.delayed(const Duration(seconds: _delayPerRowSec));
          continue;
        }

        try {
          final uid =
              (await auth.createUserWithEmailAndPassword(
                email: email,
                password: pass,
              )).user!.uid;

          await fs.collection('doctors').doc(uid).set({
            'uid': uid,
            'name': _cellStr(row, 'name', col),
            'address': _cellStr(row, 'address', col),
            'city': _cellStr(row, 'city', col),
            'latitude': _cellDouble(row, 'lat', col),
            'longitude': _cellDouble(row, 'lng', col),
            'specialization': _cellStr(row, 'specialization', col),
            'linkedinUrl': _cellStr(row, 'linkedin', col),
            'phone': _cellStr(row, 'phone', col),
            'starCount': _cellDouble(row, 'star', col),
            'email': email,
          });

          _log('Row $r ($email) → OK');
          ok++;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            _log('Row $r ($email) → duplicate, skipping');
            skip++;
          } else {
            _log('Row $r ($email) → FirebaseAuthException: ${e.code}');
            fail++;
          }
        } catch (e) {
          _log('Row $r ($email) → $e');
          fail++;
        }

        await Future.delayed(const Duration(seconds: _delayPerRowSec));
      }

      _showSnack('تم: $ok ناجح • $skip مكرر • $fail فشل');
    } catch (e) {
      _showSnack('فشل: $e');
    } finally {
      setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: _isImporting ? null : _importDoctors,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.plum,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child:
          _isImporting
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'جاري الصف $_currentRow...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Jawadtaut',
                      fontSize: 16,
                    ),
                  ),
                ],
              )
              : const Text(
                'استيراد ملف الأطباء',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jawadtaut',
                  fontSize: 18,
                ),
              ),
    );

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('استيراد الأطباء (Debug)'),
        backgroundColor: AppColors.plum,
      ),
      body: Center(child: btn),
    );
  }
}
