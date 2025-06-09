import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user.dart';
import '../infrastructure/user_repository.dart';
import 'package:dio/dio.dart'; // Assuming Dio is used by UserRepository

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return RemoteUserRepository(
    Dio(),
    baseUrl: 'http://10.0.2.2:8000', // Make sure this matches your backend URL
  );
});

class UserState {
  final List<User> users;
  final bool isLoading;
  final String? error;

  UserState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository repository;
  UserNotifier(this.repository) : super(UserState());

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await repository.getUsers();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserNotifier(repo);
}); 