import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/local_data_source.dart';

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
}); 