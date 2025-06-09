import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/plant.dart';
import '../infrastructure/plant_repository.dart';
import 'package:dio/dio.dart';
import 'providers/local_data_provider.dart';

final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  final localDataSource = ref.watch(localDataSourceProvider);
  return RemotePlantRepository(
    Dio(),
    baseUrl: 'http://10.0.2.2:8000',
    localDataSource: localDataSource,
  );
});

class PlantState {
  final List<Plant> plants;
  final Plant? selectedPlant;
  final bool isLoading;
  final String? error;

  PlantState({
    this.plants = const [],
    this.selectedPlant,
    this.isLoading = false,
    this.error,
  });

  PlantState copyWith({
    List<Plant>? plants,
    Plant? selectedPlant,
    bool? isLoading,
    String? error,
  }) {
    return PlantState(
      plants: plants ?? this.plants,
      selectedPlant: selectedPlant ?? this.selectedPlant,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PlantNotifier extends StateNotifier<PlantState> {
  final PlantRepository repository;
  PlantNotifier(this.repository) : super(PlantState());

  Future<void> fetchPlants() async {
    await Future.microtask(() => state = state.copyWith(isLoading: true, error: null));
    try {
      final plants = await repository.getPlants();
      for (var plant in plants) {
        print('Fetched Plant ${plant.commonName} with image URL: ${plant.plantImage}');
      }
      await Future.microtask(() => state = state.copyWith(plants: plants, isLoading: false));
    } catch (e) {
      await Future.microtask(() => state = state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> fetchPlant(int id) async {
    await Future.microtask(() => state = state.copyWith(isLoading: true, error: null));
    try {
      final plant = await repository.getPlant(id);
      await Future.microtask(() => state = state.copyWith(selectedPlant: plant, isLoading: false));
    } catch (e) {
      await Future.microtask(() => state = state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addPlant(Map<String, dynamic> data, String? imagePath) async {
    await Future.microtask(() => state = state.copyWith(isLoading: true, error: null));
    try {
      final plant = await repository.addPlant(data, imagePath);
      print('Added Plant ${plant.commonName} with image URL: ${plant.plantImage}');
      await Future.microtask(() => state = state.copyWith(
        plants: [...state.plants, plant],
        isLoading: false,
      ));
    } catch (e) {
      await Future.microtask(() => state = state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updatePlant(int id, Map<String, dynamic> data, String? imagePath) async {
    await Future.microtask(() => state = state.copyWith(isLoading: true, error: null));
    try {
      final updated = await repository.updatePlant(id, data, imagePath);
      print('Updated Plant ${updated.commonName} with image URL: ${updated.plantImage}');
      final updatedList = state.plants.map((p) => p.id == id ? updated : p).toList();
      await Future.microtask(() => state = state.copyWith(plants: updatedList, isLoading: false));
    } catch (e) {
      await Future.microtask(() => state = state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deletePlant(int id) async {
    await Future.microtask(() => state = state.copyWith(isLoading: true, error: null));
    try {
      await repository.deletePlant(id);
      final updatedList = state.plants.where((p) => p.id != id).toList();
      await Future.microtask(() => state = state.copyWith(plants: updatedList, isLoading: false));
    } catch (e) {
      await Future.microtask(() => state = state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

final plantProvider = StateNotifierProvider<PlantNotifier, PlantState>((ref) {
  final repo = ref.watch(plantRepositoryProvider);
  return PlantNotifier(repo);
}); 