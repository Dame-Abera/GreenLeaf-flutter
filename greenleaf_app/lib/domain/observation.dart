import 'package:flutter/material.dart';

class Observation {
  final int id;
  final String? observationImage;
  final int? relatedField;
  final TimeOfDay time;
  final DateTime date;
  final String location;
  final String note;
  final String? createdBy;

  Observation({
    required this.id,
    this.observationImage,
    this.relatedField,
    required this.time,
    required this.date,
    required this.location,
    required this.note,
    this.createdBy,
  });

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