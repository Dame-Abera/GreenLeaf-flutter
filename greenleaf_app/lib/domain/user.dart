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
  final bool isSuperuser;

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
    this.isSuperuser = false,
  });

  bool get isAdmin {
    // Check if the email matches admin pattern or specific admin emails
    return email.toLowerCase() == 'dameabera@gmail.com' || 
           email.toLowerCase().endsWith('@admin.com') ||
           isStaff ||
           isSuperuser;
  }
} 