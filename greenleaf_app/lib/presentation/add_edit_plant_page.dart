import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../application/plant_provider.dart';
import '../domain/plant.dart';

class AddEditPlantPage extends ConsumerStatefulWidget {
  final Plant? plant;

  const AddEditPlantPage({super.key, this.plant});

  @override
  ConsumerState<AddEditPlantPage> createState() => _AddEditPlantPageState();
}

class _AddEditPlantPageState extends ConsumerState<AddEditPlantPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController commonNameController;
  late TextEditingController scientificNameController;
  late TextEditingController habitatController;
  late TextEditingController originController;
  late TextEditingController descriptionController;
  File? _selectedImage;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    commonNameController = TextEditingController(text: widget.plant?.commonName ?? '');
    scientificNameController = TextEditingController(text: widget.plant?.scientificName ?? '');
    habitatController = TextEditingController(text: widget.plant?.habitat ?? '');
    originController = TextEditingController(text: widget.plant?.origin ?? '');
    descriptionController = TextEditingController(text: widget.plant?.description ?? '');
    if (widget.plant?.plantImage != null && widget.plant!.plantImage!.isNotEmpty) {
      // For existing plant, if there's an image URL, we might want to display it
      // but we can't convert a network image to File directly here for editing.
      // For simplicity, if editing, user will re-pick image if needed.
    }
  }

  @override
  void dispose() {
    commonNameController.dispose();
    scientificNameController.dispose();
    habitatController.dispose();
    originController.dispose();
    descriptionController.dispose();
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
        final fileName = 'plant_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'common_name': commonNameController.text,
        'scientific_name': scientificNameController.text,
        'habitat': habitatController.text,
        'origin': originController.text,
        'description': descriptionController.text,
      };

      if (widget.plant == null) {
        // Add new plant
        await ref.read(plantProvider.notifier).addPlant(data, _selectedImage?.path);
      } else {
        // Update existing plant
        await ref.read(plantProvider.notifier).updatePlant(widget.plant!.id, data, _selectedImage?.path);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant == null ? 'Add Plant' : 'Edit Plant'),
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
                            : (widget.plant?.plantImage != null && widget.plant!.plantImage!.isNotEmpty
                                ? DecorationImage(image: NetworkImage(widget.plant!.plantImage!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: _selectedImage == null && (widget.plant?.plantImage == null || widget.plant!.plantImage!.isEmpty)
                          ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  if (plantState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        'Error: ${plantState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: commonNameController,
                    decoration: const InputDecoration(labelText: 'Common Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter common name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: scientificNameController,
                    decoration: const InputDecoration(labelText: 'Scientific Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter scientific name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: habitatController,
                    decoration: const InputDecoration(labelText: 'Habitat'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter habitat';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: originController,
                    decoration: const InputDecoration(labelText: 'Origin'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter origin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: plantState.isLoading ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: plantState.isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (plantState.isLoading)
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