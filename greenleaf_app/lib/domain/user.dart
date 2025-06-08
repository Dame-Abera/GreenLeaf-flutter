class User {
  final String? firstName;
  final String? lastName;
  final String email;
  final String? profileImage;
  final DateTime? birthdate;
  final String? gender;
  final String? phoneNumber;
  final bool isActive;
  final bool isStaff;

  User({
    this.firstName,
    this.lastName,
    required this.email,
    this.profileImage,
    this.birthdate,
    this.gender,
    this.phoneNumber,
    this.isActive = true,
    this.isStaff = false,
  });
} 