import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawini/doctor/controllers/patiant_reports_controller.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class PatientReportsView extends StatefulWidget {
  const PatientReportsView({super.key});

  @override
  State<PatientReportsView> createState() => _PatientReportsViewState();
}

class _PatientReportsViewState extends State<PatientReportsView> {
  final _controller = PatientReportsController();
  bool _loading = true;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final data = await _controller.getPatientReports();
      setState(() {
        _reports = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء تجهيز التقارير: $e',
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
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'تاريخ غير متاح';
    final dt = timestamp.toDate();
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر فتح الرابط', textDirection: TextDirection.rtl),
          backgroundColor: AppColors.plum,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _reportCard(Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkPlum,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'تاريخ الإرسال: ${_formatDate(report['sentAt'])}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Din',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _openPdf(report['pdfUrl']),
            icon: const Icon(
              Icons.picture_as_pdf,
              size: 18,
              color: Colors.white,
            ),
            label: const Text(
              'فتح التقرير',
              style: TextStyle(
                fontFamily: 'Jawadtaut',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.plum,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(118, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,

        actions: [
          IconButton(
            icon: const Directionality(
              textDirection: TextDirection.rtl,
              child: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child:
            _loading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.plum),
                )
                : _reports.isEmpty
                ? const Center(
                  child: Text(
                    'لا توجد تقارير حتى الآن',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _reports.length,
                  itemBuilder: (_, i) => _reportCard(_reports[i]),
                ),
      ),
    );
  }
}
