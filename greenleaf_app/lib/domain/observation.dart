import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:greenleaf_app/domain/plant.dart'; // Import Plant model to access SyncStatus

part 'observation.g.dart';

@HiveType(typeId: 1)
class Observation {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String? observationImage;
  @HiveField(2)
  final int? relatedField;
  @HiveField(3)
  final TimeOfDay time;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final String location;
  @HiveField(6)
  final String note;
  @HiveField(7)
  final String? createdBy;
  @HiveField(8)
  final SyncStatus syncStatus;

  Observation({
    required this.id,
    this.observationImage,
    this.relatedField,
    required this.time,
    required this.date,
    required this.location,
    required this.note,
    this.createdBy,
    this.syncStatus = SyncStatus.synced,
  });

  Observation copyWith({
    int? id,
    String? observationImage,
    int? relatedField,
    TimeOfDay? time,
    DateTime? date,
    String? location,
    String? note,
    String? createdBy,
    SyncStatus? syncStatus,
  }) {
    return Observation(
      id: id ?? this.id,
      observationImage: observationImage ?? this.observationImage,
      relatedField: relatedField ?? this.relatedField,
      time: time ?? this.time,
      date: date ?? this.date,
      location: location ?? this.location,
      note: note ?? this.note,
      createdBy: createdBy ?? this.createdBy,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory Observation.fromJson(Map<String, dynamic> json) {
    // Debugging: Print the raw value and type of 'observation_image'
    print('DEBUG: Raw observation_image value: ${json['observation_image']}, Type: ${json['observation_image'].runtimeType}');

    // Ensure time string is correctly formatted for parsing
    String timeString = json['time'] as String;
    List<String> timeParts = timeString.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    String? observationImageValue;
    final dynamic rawObservationImage = json['observation_image'];

    if (rawObservationImage is String && rawObservationImage.isNotEmpty) {
      observationImageValue = rawObservationImage;
    }
    // If rawObservationImage is int or null or empty string, observationImageValue remains null.

    return Observation(
      id: json['id'] as int,
      observationImage: observationImageValue,
      relatedField: json['related_field'] == null
          ? null
          : int.tryParse(json['related_field'].toString()),
      time: TimeOfDay(hour: hour, minute: minute),
      date: () {
        String dateString = json['date'] as String;
        DateTime? parsedDate = DateTime.tryParse(dateString);
        if (parsedDate == null) {
          print('Warning: Invalid date format from backend for observation.date: $dateString');
          return DateTime.now();
        }
        return parsedDate;
      }(),
      location: (json['location'] is String) ? json['location'] as String : '',
      note: (json['note'] is String) ? json['note'] as String : '',
      createdBy: (json['created_by'] is String) ? json['created_by'] as String? : null,
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'observation_image': observationImage,
        'related_field': relatedField,
        'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00', // Format TimeOfDay to HH:MM:SS
        'date': date.toIso8601String().split('T').first,
        'location': location,
        'note': note,
        'created_by': createdBy,
      };
}

// Custom adapter for TimeOfDay
@HiveType(typeId: 2)
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 2; // Unique typeId for TimeOfDay

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readInt();
    final minute = reader.readInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
  }
} 