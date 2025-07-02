class DoctorCloudModel {
  final String uid;
  final String name;
  final String specialization;
  final String address;
  final String city;
  final String phone;
  final String email;
  final String linkedinUrl;
  final double latitude;
  final double longitude;
  final double starCount;

  const DoctorCloudModel({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.linkedinUrl,
    required this.latitude,
    required this.longitude,
    required this.starCount,
  });

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
      'latitude': latitude,
      'longitude': longitude,
      'starCount': starCount,
    };
  }

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
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      starCount: (map['starCount'] as num).toDouble(),
    );
  }
}
