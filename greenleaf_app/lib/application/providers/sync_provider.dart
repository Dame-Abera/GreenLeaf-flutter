import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../infrastructure/sync_service.dart';
import 'local_data_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final localDataSource = ref.watch(localDataSourceProvider);
  return SyncService(
    Dio(),
    baseUrl: 'http://10.0.2.2:8000',
    localDataSource: localDataSource,
  );
});

final syncProvider = StateNotifierProvider<SyncNotifier, bool>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncNotifier(syncService);
});

class SyncNotifier extends StateNotifier<bool> {
  final SyncService _syncService;

  SyncNotifier(this._syncService) : super(false);

  Future<void> sync() async {
    if (state) return; // Don't start sync if already syncing
    state = true;
    try {
      await _syncService.startSync();
    } finally {
      state = false;
    }
  }
} 