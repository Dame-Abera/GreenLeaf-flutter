import 'package:dio/dio.dart';
import '../domain/plant.dart';
import 'token_storage.dart';

abstract class PlantRepository {
  Future<List<Plant>> getPlants();
  Future<Plant> getPlant(int id);
  Future<Plant> addPlant(Map<String, dynamic> data, String? imagePath);
  Future<Plant> updatePlant(int id, Map<String, dynamic> data, String? imagePath);
  Future<void> deletePlant(int id);
}

class RemotePlantRepository implements PlantRepository {
  final Dio dio;
  final String baseUrl;
  RemotePlantRepository(this.dio, {required this.baseUrl});

  @override
  Future<List<Plant>> getPlants() async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    final response = await dio.get(
      '$baseUrl/api/plants/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return (response.data as List).map((e) => Plant.fromJson(e)).toList();
  }

  @override
  Future<Plant> getPlant(int id) async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    final response = await dio.get(
      '$baseUrl/api/plants/$id/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return Plant.fromJson(response.data);
  }

  @override
  Future<Plant> addPlant(Map<String, dynamic> data, String? imagePath) async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    final formData = FormData.fromMap(data);
    if (imagePath != null) {
      formData.files.add(MapEntry(
        'plant_image',
        await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
      ));
    }
    final response = await dio.post(
      '$baseUrl/api/plants/',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      }),
    );
    return Plant.fromJson(response.data);
  }

  @override
  Future<Plant> updatePlant(int id, Map<String, dynamic> data, String? imagePath) async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    final formData = FormData.fromMap(data);
    if (imagePath != null) {
      formData.files.add(MapEntry(
        'plant_image',
        await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
      ));
    }
    final response = await dio.patch(
      '$baseUrl/api/plants/$id/',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      }),
    );
    return Plant.fromJson(response.data);
  }

  @override
  Future<void> deletePlant(int id) async {
    final accessToken = TokenStorage.accessToken;
    if (accessToken == null) throw Exception('No access token');
    await dio.delete(
      '$baseUrl/api/plants/$id/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }
} 