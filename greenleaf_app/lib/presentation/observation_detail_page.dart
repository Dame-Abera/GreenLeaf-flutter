import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/observation.dart';
import '../application/observation_provider.dart';
import 'add_edit_observation_page.dart';
import '../application/plant_provider.dart';
import '../domain/plant.dart';

class ObservationDetailPage extends ConsumerWidget {
  final Observation observation;

  const ObservationDetailPage({super.key, required this.observation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observationNotifier = ref.read(observationProvider.notifier);
    final observationState = ref.watch(observationProvider);
    final plantsState = ref.watch(plantProvider);

    // Find the related plant's common name
    final relatedPlant = plantsState.plants.firstWhere(
      (plant) => plant.id == observation.relatedField,
      orElse: () => Plant(
        id: -1,
        commonName: 'Unknown Plant',
        scientificName: 'Unknown',
        habitat: 'Unknown',
        origin: 'Unknown',
        description: 'Unknown',
      ),
    );

    void deleteObservation() async {
      try {
        await observationNotifier.deleteObservation(observation.id);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting observation: $e')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Observation Details'),
        backgroundColor: Colors.green,
      ),
      body: observationState.isLoading && observationState.selectedObservation?.id == observation.id
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Observation Image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: observation.observationImage != null && observation.observationImage!.isNotEmpty
                            ? NetworkImage(observation.observationImage!) as ImageProvider
                            : const AssetImage('assets/plant_placeholder.jpg'),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Error loading observation image: $exception');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    relatedPlant.commonName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${observation.date.day}/${observation.date.month}/${observation.date.year} ${observation.time.hour}:${observation.time.minute.toString().padLeft(2, '0')} ${observation.time.hour >= 12 ? 'PM' : 'AM'}',
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          observation.location,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    observation.note,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  if (observationState.error != null && observationState.selectedObservation?.id == observation.id)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Error: ${observationState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditObservationPage(observation: observation),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Observation'),
                                content: const Text('Are you sure you want to delete this observation? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      deleteObservation();
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
} 