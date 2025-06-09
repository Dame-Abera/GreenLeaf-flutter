import 'package:dio/dio.dart';
import '../domain/plant.dart';
import 'token_storage.dart';
import 'local_data_source.dart';

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
  final LocalDataSource localDataSource;

  RemotePlantRepository(this.dio, {required this.baseUrl, required this.localDataSource});

  @override
  Future<List<Plant>> getPlants() async {
    List<Plant> plants = [];
    try {
      final accessToken = TokenStorage.accessToken;
      if (accessToken == null) throw Exception('No access token');
      final response = await dio.get(
        '$baseUrl/api/plants/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      plants = (response.data as List).map((e) => Plant.fromJson(e)).toList();
      // Cache the plants locally
      await localDataSource.cachePlants(plants);
      return plants;
    } on DioException catch (e) {
      print('Dio error fetching plants: ${e.message}');
      // If remote fetch fails, try to get from local cache
      final cachedPlants = localDataSource.getCachedPlants();
      if (cachedPlants.isNotEmpty) {
        print('Returning cached plants.');
        return cachedPlants;
      } else {
        print('No cached plants available. Rethrowing error.');
        rethrow; // Re-throw only if no cached data
      }
    } catch (e) {
      print('Unknown error fetching plants: $e');
      final cachedPlants = localDataSource.getCachedPlants();
      if (cachedPlants.isNotEmpty) {
        print('Returning cached plants.');
        return cachedPlants;
      } else {
        print('No cached plants available. Rethrowing error.');
        rethrow; // Re-throw only if no cached data
      }
    }
  }

  @override
  Future<Plant> getPlant(int id) async {
    try {
      final accessToken = TokenStorage.accessToken;
      if (accessToken == null) throw Exception('No access token');
      final response = await dio.get(
        '$baseUrl/api/plants/$id/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final plant = Plant.fromJson(response.data);
      // Update the plant in local cache
      await localDataSource.updatePlant(plant);
      return plant;
    } catch (e) {
      // If remote fetch fails, try to get from local cache
      final cachedPlants = localDataSource.getCachedPlants();
      final plant = cachedPlants.firstWhere((p) => p.id == id, orElse: () => throw Exception('Plant not found'));
      return plant;
    }
  }

  @override
  Future<Plant> addPlant(Map<String, dynamic> data, String? imagePath) async {
    try {
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
      final plant = Plant.fromJson(response.data);
      await localDataSource.addPlant(plant.copyWith(syncStatus: SyncStatus.synced));
      print('Plant added successfully online and cached.');
      return plant;
    } on DioException catch (e) {
      print('Dio error adding plant online: ${e.message}. Attempting to add locally.');
      final tempId = DateTime.now().microsecondsSinceEpoch; // Generate a unique temporary ID
      final offlinePlant = Plant(
        id: tempId,
        commonName: data['common_name'] as String,
        scientificName: data['scientific_name'] as String,
        habitat: data['habitat'] as String,
        origin: data['origin'] as String,
        description: data['description'] as String,
        plantImage: imagePath, 
        syncStatus: SyncStatus.pending_create,
      );
      await localDataSource.addPlant(offlinePlant);
      print('Plant added successfully to local cache (offline).');
      return offlinePlant; // Return the locally saved plant, no exception
    } catch (e) {
      print('Unknown error adding plant: $e');
      rethrow;
    }
  }

  @override
  Future<Plant> updatePlant(int id, Map<String, dynamic> data, String? imagePath) async {
    try {
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
      final plant = Plant.fromJson(response.data);
      await localDataSource.updatePlant(plant.copyWith(syncStatus: SyncStatus.synced));
      print('Plant updated successfully online and cached.');
      return plant;
    } on DioException catch (e) {
      print('Dio error updating plant online: ${e.message}. Attempting to update locally.');
      final existingPlant = localDataSource.getCachedPlants().firstWhere((p) => p.id == id);
      final offlinePlant = existingPlant.copyWith(
        commonName: data['common_name'] as String? ?? existingPlant.commonName,
        scientificName: data['scientific_name'] as String? ?? existingPlant.scientificName,
        habitat: data['habitat'] as String? ?? existingPlant.habitat,
        origin: data['origin'] as String? ?? existingPlant.origin,
        description: data['description'] as String? ?? existingPlant.description,
        plantImage: imagePath ?? existingPlant.plantImage,
        syncStatus: SyncStatus.pending_update,
      );
      await localDataSource.updatePlant(offlinePlant);
      print('Plant updated successfully in local cache (offline).');
      return offlinePlant; // Return the locally updated plant, no exception
    } catch (e) {
      print('Unknown error updating plant: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePlant(int id) async {
    try {
      final accessToken = TokenStorage.accessToken;
      if (accessToken == null) throw Exception('No access token');
      await dio.delete(
        '$baseUrl/api/plants/$id/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      await localDataSource.deletePlant(id);
      print('Plant deleted successfully online and from cache.');
    } on DioException catch (e) {
      print('Dio error deleting plant online: ${e.message}. Attempting to delete locally.');
      final existingPlant = localDataSource.getCachedPlants().firstWhere((p) => p.id == id);
      await localDataSource.updatePlant(existingPlant.copyWith(syncStatus: SyncStatus.pending_delete));
      print('Plant marked for deletion in local cache (offline).');
      return Future.value(); // Explicitly complete the future successfully
    } catch (e) {
      print('Unknown error deleting plant: $e');
      rethrow;
    }
  }
} 