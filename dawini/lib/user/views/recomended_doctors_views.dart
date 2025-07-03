import 'package:dawini/user/views/recommendedDoctor_profile_view.dart';
import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/user/controllers/recommend_doctors_controller.dart';
import 'package:dawini/doctor/models/doctor_cloud_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RecommendedDoctorsView extends StatefulWidget {
  @override
  State<RecommendedDoctorsView> createState() => _RecommendedDoctorsViewState();
}

class _RecommendedDoctorsViewState extends State<RecommendedDoctorsView> {
  final RecommendDoctorsController _controller = RecommendDoctorsController();

  late final List<DoctorCloudModel> _allDoctors;
  late List<DoctorCloudModel> _displayedDoctors;
  bool _isFiltered = false;

  @override
  void initState() {
    super.initState();
    _allDoctors = _controller.getRecommendedDoctors();
    _displayedDoctors = List.from(_allDoctors);
  }

  void _showSnack(String message, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: bg ?? AppColors.plum,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleFilterByLocation() async {
    if (_isFiltered) {
      setState(() {
        _displayedDoctors = List.from(_allDoctors);
        _isFiltered = false;
      });
      _showSnack('تم إلغاء التصفية، عرض جميع الأطباء');
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      _showSnack('رجاء تفعيل خدمة الموقع', bg: AppColors.plum);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnack('لا يمكن الوصول إلى موقعك', bg: AppColors.plum);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final nearbyDoctors = await _controller.filterDoctorsByLocation(position);

    setState(() {
      _displayedDoctors = nearbyDoctors;
      _isFiltered = true;
    });

    if (nearbyDoctors.isEmpty) {
      _showSnack('لم يُعثر على أطباء قريبين');
    } else {
      _showSnack('تم تصفية الأطباء حسب موقعك (${nearbyDoctors.length})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            _isFiltered ? Icons.filter_alt_off : Icons.filter_alt_outlined,
            color: Colors.white,
          ),
          tooltip: _isFiltered ? 'إلغاء التصفية' : 'تصفية حسب الموقع',
          onPressed: _toggleFilterByLocation,
        ),
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          'الأطباء المقترحون',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Jawadtaut',
            fontSize: 20,
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
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child:
            _displayedDoctors.isEmpty
                ? const Center(
                  child: Text(
                    'لا يوجد أطباء مقترحون حالياً',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontFamily: 'Jawadtaut',
                    ),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _displayedDoctors.length,
                  itemBuilder: (context, index) {
                    final doc = _displayedDoctors[index];
                    return Card(
                      color: AppColors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        leading: const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.plum,
                          child: Icon(
                            Icons.medical_services,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          doc.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Jawadtaut',
                          ),
                        ),
                        subtitle: Text(
                          doc.specialization,
                          style: const TextStyle(
                            color: Color(0xFFB8B6B6),
                            fontSize: 15,
                            fontFamily: 'Din',
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 18,
                        ),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => RecommendedDoctorProfileView(
                                      doctor: doc,
                                    ),
                              ),
                            ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
