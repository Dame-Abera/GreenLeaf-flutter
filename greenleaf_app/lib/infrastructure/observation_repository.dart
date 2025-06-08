import 'package:dio/dio.dart';
import '../domain/observation.dart';
import 'token_storage.dart';

abstract class ObservationRepository {
  Future<List<Observation>> getObservations();
  Future<Observation> getObservation(int id);
  Future<Observation> addObservation(Map<String, dynamic> data, String? imagePath);
  Future<Observation> updateObservation(int id, Map<String, dynamic> data, String? imagePath);
  Future<void> deleteObservation(int id);
}

class RemoteObservationRepository implements ObservationRepository {
  final Dio dio;
  final String baseUrl;

  RemoteObservationRepository(this.dio, {required this.baseUrl});

  @override
  Future<List<Observation>> getObservations() async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    final response = await dio.get(
      '$baseUrl/api/observations/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return (response.data as List).map((e) => Observation.fromJson(e)).toList();
  }

  @override
  Future<Observation> getObservation(int id) async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    final response = await dio.get(
      '$baseUrl/api/observations/$id/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return Observation.fromJson(response.data);
  }

  @override
  Future<Observation> addObservation(Map<String, dynamic> data, String? imagePath) async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    final formData = FormData.fromMap(data);
    if (imagePath != null) {
      formData.files.add(MapEntry(
        'observation_image',
        await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
      ));
    }
    final response = await dio.post(
      '$baseUrl/api/observations/',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      }),
    );
    return Observation.fromJson(response.data);
  }

  @override
  Future<Observation> updateObservation(int id, Map<String, dynamic> data, String? imagePath) async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    final formData = FormData.fromMap(data);
    if (imagePath != null) {
      formData.files.add(MapEntry(
        'observation_image',
        await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
      ));
    }
    final response = await dio.patch(
      '$baseUrl/api/observations/$id/',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      }),
    );
    return Observation.fromJson(response.data);
  }

  @override
  Future<void> deleteObservation(int id) async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    await dio.delete(
      '$baseUrl/api/observations/$id/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }
} 