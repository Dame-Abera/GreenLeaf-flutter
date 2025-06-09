import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/plant.dart';
import '../domain/observation.dart';
import 'local_data_source.dart';
import 'token_storage.dart';

class SyncService {
  final Dio dio;
  final String baseUrl;
  final LocalDataSource localDataSource;
  bool _isSyncing = false;

  SyncService(this.dio, {required this.baseUrl, required this.localDataSource});

  Future<void> startSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No network connection available for sync');
        return;
      }

      // Check if we have a valid token
      final accessToken = TokenStorage.accessToken;
      if (accessToken == null) {
        print('No access token available for sync');
        return;
      }

      // Sync plants first
      await _syncPlants(accessToken);
      
      // Then sync observations
      await _syncObservations(accessToken);

    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncPlants(String accessToken) async {
    final plants = localDataSource.getCachedPlants();
    
    // Handle pending creates
    for (final plant in plants.where((p) => p.syncStatus == SyncStatus.pending_create)) {
      try {
        final formData = FormData.fromMap({
          'common_name': plant.commonName,
          'scientific_name': plant.scientificName,
          'habitat': plant.habitat,
          'origin': plant.origin,
          'description': plant.description,
        });

        if (plant.plantImage != null && !plant.plantImage!.startsWith('http')) {
          formData.files.add(MapEntry(
            'plant_image',
            await MultipartFile.fromFile(plant.plantImage!, filename: plant.plantImage!.split('/').last),
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

        final syncedPlant = Plant.fromJson(response.data);
        await localDataSource.updatePlant(syncedPlant.copyWith(syncStatus: SyncStatus.synced));
        print('Successfully synced plant creation: ${plant.commonName}');
      } catch (e) {
        print('Failed to sync plant creation: ${plant.commonName}, error: $e');
      }
    }

    // Handle pending updates
    for (final plant in plants.where((p) => p.syncStatus == SyncStatus.pending_update)) {
      try {
        final formData = FormData.fromMap({
          'common_name': plant.commonName,
          'scientific_name': plant.scientificName,
          'habitat': plant.habitat,
          'origin': plant.origin,
          'description': plant.description,
        });

        if (plant.plantImage != null && !plant.plantImage!.startsWith('http')) {
          formData.files.add(MapEntry(
            'plant_image',
            await MultipartFile.fromFile(plant.plantImage!, filename: plant.plantImage!.split('/').last),
          ));
        }

        final response = await dio.patch(
          '$baseUrl/api/plants/${plant.id}/',
          data: formData,
          options: Options(headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          }),
        );

        final syncedPlant = Plant.fromJson(response.data);
        await localDataSource.updatePlant(syncedPlant.copyWith(syncStatus: SyncStatus.synced));
        print('Successfully synced plant update: ${plant.commonName}');
      } catch (e) {
        print('Failed to sync plant update: ${plant.commonName}, error: $e');
      }
    }

    // Handle pending deletes
    for (final plant in plants.where((p) => p.syncStatus == SyncStatus.pending_delete)) {
      try {
        await dio.delete(
          '$baseUrl/api/plants/${plant.id}/',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        await localDataSource.deletePlant(plant.id);
        print('Successfully synced plant deletion: ${plant.commonName}');
      } catch (e) {
        print('Failed to sync plant deletion: ${plant.commonName}, error: $e');
      }
    }
  }

  Future<void> _syncObservations(String accessToken) async {
    final observations = localDataSource.getCachedObservations();
    
    // Handle pending creates
    for (final observation in observations.where((o) => o.syncStatus == SyncStatus.pending_create)) {
      try {
        final formData = FormData.fromMap({
          'related_field': observation.relatedField,
          'date': observation.date.toIso8601String(),
          'time': '${observation.time.hour.toString().padLeft(2, '0')}:${observation.time.minute.toString().padLeft(2, '0')}',
          'location': observation.location,
          'note': observation.note,
        });

        if (observation.observationImage != null && !observation.observationImage!.startsWith('http')) {
          formData.files.add(MapEntry(
            'observation_image',
            await MultipartFile.fromFile(observation.observationImage!, filename: observation.observationImage!.split('/').last),
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

        final syncedObservation = Observation.fromJson(response.data);
        await localDataSource.updateObservation(syncedObservation.copyWith(syncStatus: SyncStatus.synced));
        print('Successfully synced observation creation');
      } catch (e) {
        print('Failed to sync observation creation, error: $e');
      }
    }

    // Handle pending updates
    for (final observation in observations.where((o) => o.syncStatus == SyncStatus.pending_update)) {
      try {
        final formData = FormData.fromMap({
          'related_field': observation.relatedField,
          'date': observation.date.toIso8601String(),
          'time': '${observation.time.hour.toString().padLeft(2, '0')}:${observation.time.minute.toString().padLeft(2, '0')}',
          'location': observation.location,
          'note': observation.note,
        });

        if (observation.observationImage != null && !observation.observationImage!.startsWith('http')) {
          formData.files.add(MapEntry(
            'observation_image',
            await MultipartFile.fromFile(observation.observationImage!, filename: observation.observationImage!.split('/').last),
          ));
        }

        final response = await dio.patch(
          '$baseUrl/api/observations/${observation.id}/',
          data: formData,
          options: Options(headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          }),
        );

        final syncedObservation = Observation.fromJson(response.data);
        await localDataSource.updateObservation(syncedObservation.copyWith(syncStatus: SyncStatus.synced));
        print('Successfully synced observation update');
      } catch (e) {
        print('Failed to sync observation update, error: $e');
      }
    }

    // Handle pending deletes
    for (final observation in observations.where((o) => o.syncStatus == SyncStatus.pending_delete)) {
      try {
        await dio.delete(
          '$baseUrl/api/observations/${observation.id}/',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        await localDataSource.deleteObservation(observation.id);
        print('Successfully synced observation deletion');
      } catch (e) {
        print('Failed to sync observation deletion, error: $e');
      }
    }
  }
} 