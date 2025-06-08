import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/observation.dart';
import '../infrastructure/observation_repository.dart';
import 'package:dio/dio.dart';

final observationRepositoryProvider = Provider<ObservationRepository>((ref) {
  return RemoteObservationRepository(
    Dio(),
    baseUrl: 'http://10.0.2.2:8000',
  );
});

class ObservationState {
  final List<Observation> observations;
  final Observation? selectedObservation;
  final bool isLoading;
  final String? error;

  ObservationState({
    this.observations = const [],
    this.selectedObservation,
    this.isLoading = false,
    this.error,
  });

  ObservationState copyWith({
    List<Observation>? observations,
    Observation? selectedObservation,
    bool? isLoading,
    String? error,
  }) {
    return ObservationState(
      observations: observations ?? this.observations,
      selectedObservation: selectedObservation ?? this.selectedObservation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ObservationNotifier extends StateNotifier<ObservationState> {
  final ObservationRepository repository;
  ObservationNotifier(this.repository) : super(ObservationState());

  Future<void> fetchObservations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final observations = await repository.getObservations();
      state = state.copyWith(observations: observations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchObservation(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final observation = await repository.getObservation(id);
      state = state.copyWith(selectedObservation: observation, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addObservation(Map<String, dynamic> data, String? imagePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final observation = await repository.addObservation(data, imagePath);
      state = state.copyWith(
        observations: [...state.observations, observation],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateObservation(int id, Map<String, dynamic> data, String? imagePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await repository.updateObservation(id, data, imagePath);
      final updatedList = state.observations.map((o) => o.id == id ? updated : o).toList();
      state = state.copyWith(observations: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteObservation(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.deleteObservation(id);
      final updatedList = state.observations.where((o) => o.id != id).toList();
      state = state.copyWith(observations: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final observationProvider = StateNotifierProvider<ObservationNotifier, ObservationState>((ref) {
  final repo = ref.watch(observationRepositoryProvider);
  return ObservationNotifier(repo);
}); 