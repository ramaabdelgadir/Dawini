/// Model that represents a doctor record stored in Cloud Firestore.
///
/// NOTE
/// ----
/// • `longitude` / `latitude`, `starCount` and other future attributes
///   can be added later without breaking this model – Firestore is schema‑less.
/// • Keep this file *pure data* – no UI or network code here.
class DoctorCloudModel {
  final String uid;
  final String name;
  final String specialization; // التصنيف / التخصص
  final String address; // العنوان كاملاً
  final String city; // المدينة
  final String phone; // رقم الهاتف (واحد فقط)
  final String email; // البريد الإلكتروني
  final String linkedinUrl; // رابط لينكدإن
  final String facebookUrl; // رابط فيسبوك

  DoctorCloudModel({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.linkedinUrl,
    required this.facebookUrl,
  });

  /// Convert object ➜ Map<String, dynamic> for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'specialization': specialization,
      'address': address,
      'city': city,
      'phone': phone,
      'email': email,
      'linkedinUrl': linkedinUrl,
      'facebookUrl': facebookUrl,
      // يمكن إضافة longitude/latitude لاحقاً
    };
  }

  /// Create object from Firestore document
  factory DoctorCloudModel.fromMap(Map<String, dynamic> map) {
    return DoctorCloudModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      specialization: map['specialization'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      linkedinUrl: map['linkedinUrl'] as String,
      facebookUrl: map['facebookUrl'] as String,
    );
  }
}
