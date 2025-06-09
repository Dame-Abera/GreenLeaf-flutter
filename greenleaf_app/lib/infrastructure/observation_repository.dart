import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../domain/observation.dart';
import '../domain/plant.dart';
import 'token_storage.dart';
import 'local_data_source.dart';

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
  final LocalDataSource localDataSource;

  RemoteObservationRepository(this.dio, {required this.baseUrl, required this.localDataSource});

  @override
  Future<List<Observation>> getObservations() async {
    List<Observation> observations = [];
    try {
      final accessToken = TokenStorage.accessToken;
      if (accessToken == null) throw Exception('No access token');
      final response = await dio.get(
        '$baseUrl/api/observations/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      observations = (response.data as List).map((e) => Observation.fromJson(e)).toList();
      // Cache the observations locally
      await localDataSource.cacheObservations(observations);
      return observations;
    } on DioException catch (e) {
      print('Dio error fetching observations: ${e.message}');
      // If remote fetch fails, try to get from local cache
      final cachedObservations = localDataSource.getCachedObservations();
      if (cachedObservations.isNotEmpty) {
        print('Returning cached observations.');
        return cachedObservations;
      } else {
        print('No cached observations available. Rethrowing error.');
        rethrow; // Re-throw only if no cached data
      }
    } catch (e) {
      print('Unknown error fetching observations: $e');
      final cachedObservations = localDataSource.getCachedObservations();
      if (cachedObservations.isNotEmpty) {
        print('Returning cached observations.');
        return cachedObservations;
      } else {
        print('No cached observations available. Rethrowing error.');
        rethrow; // Re-throw only if no cached data
      }
    }
  }

  @override
  Future<Observation> getObservation(int id) async {
    try {
      final accessToken = TokenStorage.accessToken;
      if (accessToken == null) throw Exception('No access token');
      final response = await dio.get(
        '$baseUrl/api/observations/$id/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final observation = Observation.fromJson(response.data);
      // Update the observation in local cache
      await localDataSource.updateObservation(observation);
      return observation;
    } catch (e) {
      // If remote fetch fails, try to get from local cache
      final cachedObservations = localDataSource.getCachedObservations();
      final observation = cachedObservations.firstWhere(
        (o) => o.id == id,
        orElse: () => throw Exception('Observation not found'),
      );
      return observation;
    }
  }

  @override
  Future<Observation> addObservation(Map<String, dynamic> data, String? imagePath) async {
    try {
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
      final observation = Observation.fromJson(response.data);
      await localDataSource.addObservation(observation.copyWith(syncStatus: SyncStatus.synced));
      print('Observation added successfully online and cached.');
      return observation;
    } on DioException catch (e) {
      print('Dio error adding observation online: ${e.message}. Attempting to add locally.');
      final tempId = DateTime.now().microsecondsSinceEpoch; // Generate a unique temporary ID
      final offlineObservation = Observation(
        id: tempId,
        relatedField: data['related_field'] as int?, // Assuming it's an int
        date: DateTime.parse(data['date'] as String),
        time: TimeOfDay(hour: int.parse(data['time'].split(':')[0]), minute: int.parse(data['time'].split(':')[1])),
        location: data['location'] as String,
        note: data['note'] as String,
        observationImage: imagePath, // Store local path temporarily, or a placeholder
        syncStatus: SyncStatus.pending_create,
      );
      await localDataSource.addObservation(offlineObservation);
      print('Observation added successfully to local cache (offline).');
      return offlineObservation; // Return the locally saved observation, no exception
    } catch (e) {
      print('Unknown error adding observation: $e');
      rethrow;
    }
  }

  @override
  Future<Observation> updateObservation(int id, Map<String, dynamic> data, String? imagePath) async {
    try {
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
      final observation = Observation.fromJson(response.data);
      await localDataSource.updateObservation(observation.copyWith(syncStatus: SyncStatus.synced));
      print('Observation updated successfully online and cached.');
      return observation;
    } on DioException catch (e) {
      print('Dio error updating observation online: ${e.message}. Attempting to update locally.');
      final existingObservation = localDataSource.getCachedObservations().firstWhere((o) => o.id == id);
      final offlineObservation = existingObservation.copyWith(
        relatedField: data['related_field'] as int? ?? existingObservation.relatedField,
        date: DateTime.parse(data['date'] as String? ?? existingObservation.date.toIso8601String()),
        time: TimeOfDay(hour: int.parse((data['time'] as String? ?? '00:00').split(':')[0]), minute: int.parse((data['time'] as String? ?? '00:00').split(':')[1])), // Handle TimeOfDay parsing
        location: data['location'] as String? ?? existingObservation.location,
        note: data['note'] as String? ?? existingObservation.note,
        observationImage: imagePath ?? existingObservation.observationImage,
        syncStatus: SyncStatus.pending_update,
      );
      await localDataSource.updateObservation(offlineObservation);
      print('Observation updated successfully in local cache (offline).');
      return offlineObservation; // Return the locally updated observation, no exception
    } catch (e) {
      print('Unknown error updating observation: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteObservation(int id) async {
    try {
      final accessToken = TokenStorage.accessToken;
      if (accessToken == null) throw Exception('No access token');
      await dio.delete(
        '$baseUrl/api/observations/$id/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      await localDataSource.deleteObservation(id);
      print('Observation deleted successfully online and from cache.');
    } on DioException catch (e) {
      print('Dio error deleting observation online: ${e.message}. Attempting to delete locally.');
      final existingObservation = localDataSource.getCachedObservations().firstWhere((o) => o.id == id);
      await localDataSource.updateObservation(existingObservation.copyWith(syncStatus: SyncStatus.pending_delete));
      print('Observation marked for deletion in local cache (offline).');
      return Future.value(); // Explicitly complete the future successfully
    } catch (e) {
      print('Unknown error deleting observation: $e');
      rethrow;
    }
  }
} 