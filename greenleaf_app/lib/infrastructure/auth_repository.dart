import 'package:dio/dio.dart';
import '../domain/user.dart';
import '../domain/auth_failure.dart';
import 'token_storage.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> signup(String email, String password, String confirmPassword);
  Future<User> fetchProfile(String? token);
  Future<void> logout();
  Future<User> updateProfile(Map<String, dynamic> data, [String? imagePath]);
  Future<void> deleteAccount();
}

class RemoteAuthRepository implements AuthRepository {
  final Dio dio;
  final String baseUrl;

  RemoteAuthRepository(this.dio, {required this.baseUrl});

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/account/api/token/',
        data: {'email': email, 'password': password},
      );
      final access = response.data['access'];
      final refresh = response.data['refresh'];
      await TokenStorage.saveTokens(access, refresh);
      return fetchProfile(access);
    } catch (e) {
      print('Login error: $e');
      if (e is DioException) {
        print('DioError response: \\${e.response}');
        final errorMsg = e.response?.data['detail']?.toString() ??
            e.response?.data['error']?.toString() ??
            e.response?.data.toString() ??
            'Login failed';
        throw AuthFailure(errorMsg);
      }
      throw AuthFailure('Login failed');
    }
  }

  @override
  Future<User> signup(String email, String password, String confirmPassword) async {
    try {
      final response = await dio.post(
        '$baseUrl/account/api/register/',
        data: {
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );
      final access = response.data['access'];
      final refresh = response.data['refresh'];
      await TokenStorage.saveTokens(access, refresh);
      return fetchProfile(access);
    } catch (e) {
      print('Signup error: $e');
      if (e is DioException) {
        print('DioError response: \\${e.response}');
        final errorMsg = e.response?.data['detail']?.toString() ??
            e.response?.data['error']?.toString() ??
            e.response?.data.toString() ??
            'Signup failed';
        throw AuthFailure(errorMsg);
      }
      throw AuthFailure('Signup failed');
    }
  }

  @override
  Future<User> fetchProfile(String? token) async {
    try {
      final accessToken = token ?? TokenStorage.accessToken;
      if (accessToken == null) throw AuthFailure('No access token');
      final response = await dio.get(
        '$baseUrl/account/api/profile/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final data = response.data;
      print('DEBUG: Raw profile data from backend: $data');
      return User(
        firstName: data['first_name'],
        lastName: data['last_name'],
        email: data['email'],
        profileImage: data['profile_image'],
        birthdate: data['birthdate'] != null ? DateTime.tryParse(data['birthdate']) : null,
        gender: data['gender'],
        phoneNumber: data['phone_number'],
        isStaff: data['is_staff'] == true,
        isSuperuser: data['is_superuser'] == true,
        isActive: data['is_active'] == true,
      );
    } catch (e) {
      print('Fetch profile error: $e');
      if (e is DioException) {
        print('DioError response: \\${e.response}');
        final errorMsg = e.response?.data['detail']?.toString() ??
            e.response?.data['error']?.toString() ??
            e.response?.data.toString() ??
            'Fetch profile failed';
        throw AuthFailure(errorMsg);
      }
      throw AuthFailure('Fetch profile failed');
    }
  }

  Future<void> refreshToken() async {
    final refresh = TokenStorage.refreshToken;
    if (refresh == null) throw AuthFailure('No refresh token');
    try {
      final response = await dio.post(
        '$baseUrl/account/api/token/refresh/',
        data: {'refresh': refresh},
      );
      final newAccess = response.data['access'];
      await TokenStorage.saveTokens(newAccess, refresh);
    } catch (e) {
      throw AuthFailure('Token refresh failed');
    }
  }

  @override
  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }

  @override
  Future<User> updateProfile(Map<String, dynamic> data, [String? imagePath]) async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw AuthFailure('No access token');
    try {
      FormData formData = FormData.fromMap(data);
      if (imagePath != null) {
        formData.files.add(MapEntry(
          'profile_image',
          await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
        ));
      }
      final response = await dio.patch(
        '$baseUrl/account/api/profile/',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/form-data',
        }),
      );
      final respData = response.data;
      return User(
        firstName: respData['first_name'],
        lastName: respData['last_name'],
        email: respData['email'],
        profileImage: respData['profile_image'],
        birthdate: respData['birthdate'] != null ? DateTime.tryParse(respData['birthdate']) : null,
        gender: respData['gender'],
        phoneNumber: respData['phone_number'],
        isStaff: (respData['is_staff'] is bool) ? respData['is_staff'] : false,
        isSuperuser: (respData['is_superuser'] is bool) ? respData['is_superuser'] : false,
      );
    } catch (e) {
      print('Update profile error: $e');
      if (e is DioException) {
        final errorMsg = e.response?.data['detail']?.toString() ??
            e.response?.data['error']?.toString() ??
            e.response?.data.toString() ??
            'Update profile failed';
        throw AuthFailure(errorMsg);
      }
      throw AuthFailure('Update profile failed');
    }
  }

  @override
  Future<void> deleteAccount() async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw AuthFailure('No access token');
    try {
      await dio.delete(
        '$baseUrl/account/api/profile/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      await TokenStorage.clearTokens();
    } catch (e) {
      print('Delete account error: $e');
      if (e is DioException) {
        final errorMsg = e.response?.data['detail']?.toString() ??
            e.response?.data['error']?.toString() ??
            e.response?.data.toString() ??
            'Delete account failed';
        throw AuthFailure(errorMsg);
      }
      throw AuthFailure('Delete account failed');
    }
  }
} 