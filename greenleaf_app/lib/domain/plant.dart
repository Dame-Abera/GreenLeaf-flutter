class Plant {
  final int id;
  final String? plantImage;
  final String commonName;
  final String scientificName;
  final String habitat;
  final String origin;
  final String description;
  final String? createdBy;

  Plant({
    required this.id,
    this.plantImage,
    required this.commonName,
    required this.scientificName,
    required this.habitat,
    required this.origin,
    required this.description,
    this.createdBy,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    // Debugging: Print the raw value and type of 'plant_image'
    print('DEBUG: Raw plant_image value: ${json['plant_image']}, Type: ${json['plant_image'].runtimeType}');

    String? plantImageValue;
    final dynamic rawPlantImage = json['plant_image'];

    if (rawPlantImage is String && rawPlantImage.isNotEmpty) {
      plantImageValue = rawPlantImage;
    }
    // If rawPlantImage is int or null or empty string, plantImageValue remains null.

    return Plant(
      id: json['id'] as int,
      plantImage: plantImageValue,
      commonName: (json['common_name'] is String) ? json['common_name'] as String : '',
      scientificName: (json['scientific_name'] is String) ? json['scientific_name'] as String : '',
      habitat: (json['habitat'] is String) ? json['habitat'] as String : '',
      origin: (json['origin'] is String) ? json['origin'] as String : '',
      description: (json['description'] is String) ? json['description'] as String : '',
      createdBy: (json['created_by'] is String) ? json['created_by'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plant_image': plantImage,
        'common_name': commonName,
        'scientific_name': scientificName,
        'habitat': habitat,
        'origin': origin,
        'description': description,
        'created_by': createdBy,
      };
} 