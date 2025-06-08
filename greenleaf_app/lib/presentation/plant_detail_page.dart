import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/plant.dart';
import '../application/plant_provider.dart';
import 'add_edit_plant_page.dart';

class PlantDetailPage extends ConsumerWidget {
  final Plant plant;

  const PlantDetailPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantNotifier = ref.read(plantProvider.notifier);
    final plantState = ref.watch(plantProvider);

    void _deletePlant() async {
      await plantNotifier.deletePlant(plant.id);
      Navigator.pop(context); // Go back to the plant list after deletion
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Details'),
        backgroundColor: Colors.green,
      ),
      body: plantState.isLoading && plantState.selectedPlant?.id == plant.id
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant Image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: plant.plantImage != null && plant.plantImage!.isNotEmpty
                            ? NetworkImage(plant.plantImage!) as ImageProvider
                            : const AssetImage('assets/plant_placeholder.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    plant.commonName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.scientificName,
                    style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  Text('Habitat: ${plant.habitat}'),
                  const SizedBox(height: 8),
                  Text('Origin: ${plant.origin}'),
                  const SizedBox(height: 8),
                  Text('Description: ${plant.description}'),
                  const SizedBox(height: 24),
                  if (plantState.error != null && plantState.selectedPlant?.id == plant.id)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        'Error: ${plantState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditPlantPage(plant: plant)));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Edit Plant'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Plant'),
                                  content: const Text('Are you sure you want to delete this plant?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: _deletePlant,
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Delete Plant'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
} 