import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../application/observation_provider.dart';
import '../domain/observation.dart';
import '../domain/plant.dart'; // Assuming you might need to select a related plant
import '../application/plant_provider.dart'; // To fetch available plants
import 'package:collection/collection.dart';

class AddEditObservationPage extends ConsumerStatefulWidget {
  final Observation? observation;

  const AddEditObservationPage({super.key, this.observation});

  @override
  ConsumerState<AddEditObservationPage> createState() => _AddEditObservationPageState();
}

class _AddEditObservationPageState extends ConsumerState<AddEditObservationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController locationController;
  late TextEditingController noteController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  File? _selectedImage;
  bool _isPickingImage = false;
  Plant? _selectedRelatedPlant;

  @override
  void initState() {
    super.initState();
    locationController = TextEditingController(text: widget.observation?.location ?? '');
    noteController = TextEditingController(text: widget.observation?.note ?? '');
    dateController = TextEditingController(text: widget.observation?.date.toIso8601String().split('T').first ?? '');
    timeController = TextEditingController(text: widget.observation?.time != null ? '${widget.observation!.time.hour.toString().padLeft(2, '0')}:${widget.observation!.time.minute.toString().padLeft(2, '0')}' : '');

    // If editing an observation, try to set the selected related plant
    if (widget.observation != null) {
      // Ensure plants are fetched before trying to find the related plant
      ref.read(plantProvider.notifier).fetchPlants().then((_) {
        final plants = ref.read(plantProvider).plants;
        setState(() {
          _selectedRelatedPlant = plants.firstWhereOrNull(
            (plant) => plant.id == widget.observation!.relatedField,
          );
        });
      });
    } else {
      // For new observations, pre-fetch plants so the dropdown is populated.
      ref.read(plantProvider.notifier).fetchPlants();
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    noteController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevent multiple calls
    _isPickingImage = true;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Get the temporary directory
        final tempDir = await getTemporaryDirectory();
        final tempPath = tempDir.path;
        
        // Create a unique filename
        final fileName = 'observation_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final tempFile = File('$tempPath/$fileName');
        
        // Copy the picked file to our temporary directory
        await File(pickedFile.path).copy(tempFile.path);
        
        setState(() {
          _selectedImage = tempFile;
        });
      }
    } finally {
      _isPickingImage = false; // Reset the flag
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRelatedPlant == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a related plant.')),
        );
        return;
      }

      final data = {
        'related_field': _selectedRelatedPlant!.id,
        'date': dateController.text,
        'time': '${timeController.text}:00',
        'location': locationController.text,
        'note': noteController.text,
      };

      await Future.microtask(() async {
        if (widget.observation == null) {
          await ref.read(observationProvider.notifier).addObservation(data, _selectedImage?.path);
        } else {
          await ref.read(observationProvider.notifier).updateObservation(widget.observation!.id, data, _selectedImage?.path);
        }
      });
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final observationState = ref.watch(observationProvider);
    final plantsState = ref.watch(plantProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.observation == null ? 'Add Observation' : 'Edit Observation'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        image: _selectedImage != null
                            ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                            : (widget.observation?.observationImage != null && widget.observation!.observationImage!.isNotEmpty
                                ? DecorationImage(image: NetworkImage(widget.observation!.observationImage!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: _selectedImage == null && (widget.observation?.observationImage == null || widget.observation!.observationImage!.isEmpty)
                          ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  if (observationState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        'Error: ${observationState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Related Plant Dropdown
                  plantsState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<Plant>(
                          value: _selectedRelatedPlant,
                          decoration: const InputDecoration(labelText: 'Related Plant'),
                          items: plantsState.plants.map((plant) {
                            return DropdownMenuItem<Plant>(
                              value: plant,
                              child: Text(plant.commonName),
                            );
                          }).toList(),
                          onChanged: (Plant? newValue) {
                            setState(() {
                              _selectedRelatedPlant = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a related plant';
                            }
                            return null;
                          },
                        ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: 'Time (HH:MM)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: _selectTime,
                      ),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a time';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Note'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a note';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: observationState.isLoading ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: observationState.isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (observationState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
} 