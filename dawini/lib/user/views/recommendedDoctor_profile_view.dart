import 'package:flutter/material.dart';
import 'package:dawini/theme/app_colors.dart';
import 'package:dawini/doctor/models/doctor_cloud_model.dart';
import 'package:dawini/user/controllers/recommend_doctors_controller.dart';

class RecommendedDoctorProfileView extends StatefulWidget {
  final DoctorCloudModel doctor;
  const RecommendedDoctorProfileView({super.key, required this.doctor});

  @override
  State<RecommendedDoctorProfileView> createState() =>
      _RecommendedDoctorProfileViewState();
}

class _RecommendedDoctorProfileViewState
    extends State<RecommendedDoctorProfileView> {
  final _controller = RecommendDoctorsController();
  bool _sending = false;

  Future<void> _handleSendReport() async {
    setState(() => _sending = true);
    try {
      await _controller.sendReportToDoctor(widget.doctor.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إرسال التقرير للطبيب بنجاح',
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذّر إرسال التقرير: $e',
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
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkPlum,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.plumPurple, size: 19),
          const SizedBox(width: 7),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Din', fontSize: 16),
                children: [
                  TextSpan(
                    text: '$label:  ',
                    style: const TextStyle(
                      color: AppColors.plumPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (index) {
      if (index < rating.floor()) {
        return const Icon(Icons.star, color: Colors.amber, size: 24);
      } else if (index < rating && rating - index >= 0.5) {
        return const Icon(Icons.star_half, color: Colors.amber, size: 24);
      } else {
        return const Icon(Icons.star_border, color: Colors.amber, size: 24);
      }
    }),
  );

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.plum,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: AppColors.plum,
                      backgroundImage: AssetImage(
                        'assets/images/doctor_default.png',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Jawadtaut',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStarRating(doctor.starCount),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _infoTile(
                icon: Icons.badge,
                label: 'التخصص',
                value: doctor.specialization,
              ),
              _infoTile(
                icon: Icons.location_on,
                label: 'العنوان',
                value: doctor.address,
              ),
              _infoTile(
                icon: Icons.location_city,
                label: 'المدينة',
                value: doctor.city,
              ),
              _infoTile(
                icon: Icons.phone,
                label: 'رقم الهاتف',
                value: doctor.phone,
              ),
              _infoTile(
                icon: Icons.email,
                label: 'البريد الإلكتروني',
                value: doctor.email,
              ),
              if (doctor.linkedinUrl.isNotEmpty)
                _infoTile(
                  icon: Icons.link,
                  label: 'لينكدإن',
                  value: doctor.linkedinUrl,
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _handleSendReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.plum,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:
                      _sending
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'إرسال التقرير للطبيب',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Jawadtaut',
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
