import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/plant_provider.dart';
import '../domain/plant.dart';
import '../application/observation_provider.dart';
import '../domain/observation.dart';
import 'add_edit_plant_page.dart';
import 'plant_detail_page.dart'; // Will be created soon
import 'add_edit_observation_page.dart'; // Import the new observation page
import 'observation_detail_page.dart'; // Import the new observation detail page
import 'admin_dashboard_page.dart'; // Import AdminDashboardPage
import '../application/auth_provider.dart'; // Import auth_provider

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch plants and observations when the Home Page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(plantProvider).isLoading) {
        ref.read(plantProvider.notifier).fetchPlants();
      }
      if (!ref.read(observationProvider).isLoading) {
        ref.read(observationProvider.notifier).fetchObservations();
      }
      // Also ensure user profile is fetched to check admin status
      ref.read(authProvider.notifier).fetchProfile(null as String?);
    });
  }

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantProvider);
    final observationState = ref.watch(observationProvider);
    final authState = ref.watch(authProvider); // Watch authState for user info
    final user = authState.user;

    final bool isAdmin = user?.isAdmin ?? false;

    List<BottomNavigationBarItem> bottomNavItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
    ];

    if (isAdmin) {
      bottomNavItems.add(const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenLeaf'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _tabIndex = 0),
                  child: Column(
                    children: [
                      Text('Plants',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _tabIndex == 0 ? Colors.green : Colors.black,
                          )),
                      if (_tabIndex == 0)
                        Container(
                          height: 3,
                          width: 40,
                          color: Colors.green,
                          margin: const EdgeInsets.only(top: 2),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _tabIndex = 1),
                  child: Column(
                    children: [
                      Text('Field observations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _tabIndex == 1 ? Colors.green : Colors.black,
                          )),
                      if (_tabIndex == 1)
                        Container(
                          height: 3,
                          width: 80,
                          color: Colors.green,
                          margin: const EdgeInsets.only(top: 2),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tabIndex == 0 ? _buildPlantsTab(plantState) : _buildObservationsTab(observationState),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              // Navigate to Home page (current page)
            } else if (index == 1) {
              Navigator.pushNamed(context, '/profile');
            } else if (isAdmin && index == 2) { // Admin tab is only available if isAdmin is true and it's the 3rd item
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
            }
          });
        },
        items: bottomNavItems,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabIndex == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditPlantPage()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditObservationPage()));
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlantsTab(PlantState plantState) {
    if (plantState.plants.isEmpty && !plantState.isLoading) {
      return const Center(child: Text('No plants found.'));
    }
    
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plantState.plants.length,
          itemBuilder: (context, index) {
            final plant = plantState.plants[index];
            return _plantCard(plant);
          },
        ),
        if (plantState.isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildObservationsTab(ObservationState observationState) {
    if (observationState.observations.isEmpty && !observationState.isLoading) {
      return const Center(child: Text('No observations found.'));
    }
    
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: observationState.observations.length,
          itemBuilder: (context, index) {
            final observation = observationState.observations[index];
            return _observationCard(observation);
          },
        ),
        if (observationState.isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _plantCard(Plant plant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: (plant.plantImage is String && plant.plantImage!.isNotEmpty)
                    ? NetworkImage(plant.plantImage!) as ImageProvider
                    : const AssetImage('assets/plant_placeholder.jpg'),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  print('Error loading network image for plant ${plant.commonName}: $exception');
                },
              ),
            ),
          ),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.commonName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PlantDetailPage(plant: plant)));
                  },
                  child: const Text('Plant Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _observationCard(Observation observation) {
    final plantState = ref.watch(plantProvider);
    final relatedPlant = plantState.plants.firstWhere(
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: (observation.observationImage is String && observation.observationImage!.isNotEmpty)
                    ? NetworkImage(observation.observationImage!) as ImageProvider
                    : const AssetImage('assets/plant_placeholder.jpg'),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  print('Error loading network image for observation: $exception');
                },
              ),
            ),
          ),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  relatedPlant.commonName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${observation.date.day}/${observation.date.month}/${observation.date.year}, ${observation.time.hour}:${observation.time.minute.toString().padLeft(2, '0')} ${observation.time.hour >= 12 ? 'PM' : 'AM'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ObservationDetailPage(observation: observation)));
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 