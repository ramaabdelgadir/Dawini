class DoctorCloudModel {
  final String uid;
  final String name;
  final String specialization;
  final String address;
  final String landline;
  final String mobile;
  final String email;

  DoctorCloudModel({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.address,
    required this.landline,
    required this.mobile,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'specialization': specialization,
      'address': address,
      'landline': landline,
      'mobile': mobile,
      'email': email,
    };
  }

  factory DoctorCloudModel.fromMap(Map<String, dynamic> map) {
    return DoctorCloudModel(
      uid: map['uid'],
      name: map['name'],
      specialization: map['specialization'],
      address: map['address'],
      landline: map['landline'],
      mobile: map['mobile'],
      email: map['email'],
    );
  }
}
