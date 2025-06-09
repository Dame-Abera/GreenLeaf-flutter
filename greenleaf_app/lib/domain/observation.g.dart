// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObservationAdapter extends TypeAdapter<Observation> {
  @override
  final int typeId = 1;

  @override
  Observation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Observation(
      id: fields[0] as int,
      observationImage: fields[1] as String?,
      relatedField: fields[2] as int?,
      time: fields[3] as TimeOfDay,
      date: fields[4] as DateTime,
      location: fields[5] as String,
      note: fields[6] as String,
      createdBy: fields[7] as String?,
      syncStatus: fields[8] as SyncStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Observation obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.observationImage)
      ..writeByte(2)
      ..write(obj.relatedField)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.createdBy)
      ..writeByte(8)
      ..write(obj.syncStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimeOfDayAdapterAdapter extends TypeAdapter<TimeOfDayAdapter> {
  @override
  final int typeId = 2;

  @override
  TimeOfDayAdapter read(BinaryReader reader) {
    return TimeOfDayAdapter();
  }

  @override
  void write(BinaryWriter writer, TimeOfDayAdapter obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDayAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
