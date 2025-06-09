import 'package:dio/dio.dart';
import '../domain/user.dart';
import 'token_storage.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();
  // Add methods for update/delete/create users if needed for admin dashboard
  // Future<User> updateUser(int id, Map<String, dynamic> data);
  // Future<void> deleteUser(int id);
}

class RemoteUserRepository implements UserRepository {
  final Dio dio;
  final String baseUrl;

  RemoteUserRepository(this.dio, {required this.baseUrl});

  @override
  Future<List<User>> getUsers() async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    final response = await dio.get(
      '$baseUrl/account/api/users/list/', // Corrected endpoint for listing users
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return (response.data as List).map((e) => User(
      firstName: (e['first_name'] is String) ? e['first_name'] as String? : null,
      lastName: (e['last_name'] is String) ? e['last_name'] as String? : null,
      email: e['email'] as String,
      profileImage: (e['profile_image'] is String && e['profile_image'].isNotEmpty) ? e['profile_image'] as String? : null,
      birthdate: (e['birthdate'] is String && e['birthdate'].isNotEmpty) ? DateTime.tryParse(e['birthdate']) : null,
      gender: (e['gender'] is String) ? e['gender'] as String? : null,
      phoneNumber: (e['phone_number'] is String) ? e['phone_number'] as String? : null,
      isActive: e['is_active'] == true, // Ensure correct boolean parsing
      isStaff: e['is_staff'] == true,     // Ensure correct boolean parsing
      isSuperuser: e['is_superuser'] == true, // Ensure correct boolean parsing
    )).toList();
  }
} 