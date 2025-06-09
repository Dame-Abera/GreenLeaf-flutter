import 'package:hive/hive.dart';

part 'plant.g.dart';

@HiveType(typeId: 0)
class Plant {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String? plantImage;
  @HiveField(2)
  final String commonName;
  @HiveField(3)
  final String scientificName;
  @HiveField(4)
  final String habitat;
  @HiveField(5)
  final String origin;
  @HiveField(6)
  final String description;
  @HiveField(7)
  final String? createdBy;
  @HiveField(8)
  final SyncStatus syncStatus;

  Plant({
    required this.id,
    this.plantImage,
    required this.commonName,
    required this.scientificName,
    required this.habitat,
    required this.origin,
    required this.description,
    this.createdBy,
    this.syncStatus = SyncStatus.synced,
  });

  Plant copyWith({
    int? id,
    String? plantImage,
    String? commonName,
    String? scientificName,
    String? habitat,
    String? origin,
    String? description,
    String? createdBy,
    SyncStatus? syncStatus,
  }) {
    return Plant(
      id: id ?? this.id,
      plantImage: plantImage ?? this.plantImage,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      habitat: habitat ?? this.habitat,
      origin: origin ?? this.origin,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

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
      syncStatus: SyncStatus.synced,
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

@HiveType(typeId: 200)
enum SyncStatus {
  @HiveField(0)
  synced,
  @HiveField(1)
  pending_create,
  @HiveField(2)
  pending_update,
  @HiveField(3)
  pending_delete,
} 