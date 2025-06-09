import 'package:hive/hive.dart';
import '../domain/plant.dart';
import '../domain/observation.dart';

class LocalDataSource {
  final Box<Plant> _plantBox;
  final Box<Observation> _observationBox;

  LocalDataSource()
      : _plantBox = Hive.box<Plant>('plants'),
        _observationBox = Hive.box<Observation>('observations');

  // Plant operations
  Future<void> cachePlants(List<Plant> plants) async {
    await _plantBox.clear();
    await _plantBox.addAll(plants);
  }

  List<Plant> getCachedPlants() {
    return _plantBox.values.toList();
  }

  Future<void> addPlant(Plant plant) async {
    await _plantBox.add(plant);
  }

  Future<void> updatePlant(Plant plant) async {
    final index = _plantBox.values.toList().indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      await _plantBox.putAt(index, plant);
    }
  }

  Future<void> deletePlant(int id) async {
    final index = _plantBox.values.toList().indexWhere((p) => p.id == id);
    if (index != -1) {
      await _plantBox.deleteAt(index);
    }
  }

  // Observation operations
  Future<void> cacheObservations(List<Observation> observations) async {
    await _observationBox.clear();
    await _observationBox.addAll(observations);
  }

  List<Observation> getCachedObservations() {
    return _observationBox.values.toList();
  }

  Future<void> addObservation(Observation observation) async {
    await _observationBox.add(observation);
  }

  Future<void> updateObservation(Observation observation) async {
    final index = _observationBox.values.toList().indexWhere((o) => o.id == observation.id);
    if (index != -1) {
      await _observationBox.putAt(index, observation);
    }
  }

  Future<void> deleteObservation(int id) async {
    final index = _observationBox.values.toList().indexWhere((o) => o.id == id);
    if (index != -1) {
      await _observationBox.deleteAt(index);
    }
  }

  // Clear all cached data
  Future<void> clearAllData() async {
    await _plantBox.clear();
    await _observationBox.clear();
  }
} 