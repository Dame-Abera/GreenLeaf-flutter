import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../infrastructure/plant_repository.dart';
import '../../infrastructure/observation_repository.dart';
import '../../infrastructure/auth_repository.dart';
import '../../infrastructure/user_repository.dart';
import '../../infrastructure/local_data_source.dart';

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000', // Android emulator
    // baseUrl: 'http://localhost:8000', // iOS simulator
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
});

final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final localDataSource = ref.watch(localDataSourceProvider);
  return RemotePlantRepository(dio, baseUrl: dio.options.baseUrl, localDataSource: localDataSource);
});

final observationRepositoryProvider = Provider<ObservationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final localDataSource = ref.watch(localDataSourceProvider);
  return RemoteObservationRepository(dio, baseUrl: dio.options.baseUrl, localDataSource: localDataSource);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return RemoteAuthRepository(dio, baseUrl: dio.options.baseUrl);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return RemoteUserRepository(dio, baseUrl: dio.options.baseUrl);
}); 