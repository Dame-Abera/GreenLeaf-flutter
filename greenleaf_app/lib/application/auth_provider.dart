import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user.dart';
import '../domain/auth_failure.dart';
import '../infrastructure/auth_repository.dart';
import 'package:dio/dio.dart';
import 'providers/sync_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return RemoteAuthRepository(
    Dio(),
    baseUrl: 'http://10.0.2.2:8000', // Changed from localhost to 10.0.2.2 for Android emulator
  );
});

class AuthState {
  final User? user;
  final bool isLoading;
  final AuthFailure? failure;

  AuthState({this.user, this.isLoading = false, this.failure});

  AuthState copyWith({User? user, bool? isLoading, AuthFailure? failure}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final Ref ref;

  AuthNotifier(this.repository, this.ref) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, failure: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final user = await repository.login(email, password);
      await Future.delayed(const Duration(milliseconds: 100));
      state = state.copyWith(
        user: user,
        isLoading: false,
        failure: null,
      );
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 100));
      state = state.copyWith(
        isLoading: false,
        failure: AuthFailure(e.toString()),
      );
    }
  }

  Future<void> signup(String email, String password, String confirmPassword) async {
    state = state.copyWith(isLoading: true, failure: null);
    try {
      final user = await repository.signup(email, password, confirmPassword);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, failure: AuthFailure(e.toString()));
    }
  }

  Future<void> fetchProfile(String? token) async {
    state = state.copyWith(isLoading: true, failure: null);
    try {
      final user = await repository.fetchProfile(token);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, failure: AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    // Try to sync any pending changes before logout
    try {
      await ref.read(syncProvider.notifier).sync();
    } catch (e) {
      print('Failed to sync before logout: $e');
    }
    await repository.logout();
    state = AuthState();
  }

  Future<void> init() async {
    try {
      final user = await repository.fetchProfile(null);
      state = state.copyWith(user: user);
    } catch (_) {
      // No valid token or failed to fetch profile
      state = AuthState();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data, [String? imagePath]) async {
    state = state.copyWith(isLoading: true, failure: null);
    try {
      final user = await repository.updateProfile(data, imagePath);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, failure: AuthFailure(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, failure: null);
    try {
      await repository.deleteAccount();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, failure: AuthFailure(e.toString()));
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo, ref);
}); 