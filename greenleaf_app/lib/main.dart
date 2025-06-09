import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'presentation/login_page.dart';
import 'presentation/signup_page.dart';
import 'presentation/home_page.dart';
import 'presentation/profile_page.dart';
import 'domain/plant.dart';
import 'domain/observation.dart';
import 'application/providers/sync_provider.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('DEBUG: Initializing Hive...');
  
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  print('DEBUG: Hive initialized.');
  
  // Register adapters
  Hive.registerAdapter(PlantAdapter());
  Hive.registerAdapter(ObservationAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  Hive.registerAdapter(SyncStatusAdapter());
  print('DEBUG: Hive adapters registered.');
  
  // Open boxes
  await Hive.openBox('tokens');
  await Hive.openBox<Plant>('plants');
  await Hive.openBox<Observation>('observations');
  print('DEBUG: Hive boxes opened.');

  runApp(
    const ProviderScope(
      child: GreenLeafApp(),
    ),
  );
}
