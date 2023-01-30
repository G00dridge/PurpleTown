// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_map.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DecisionMapAdapter extends TypeAdapter<DecisionMap> {
  @override
  final int typeId = 0;

  @override
  DecisionMap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DecisionMap()
      ..id = fields[0] as int
      ..option1Id = fields[1] as int
      ..option2Id = fields[2] as int
      ..description = fields[3] as String
      ..question = fields[4] as String
      ..option1 = fields[5] as String
      ..option2 = fields[6] as String
      ..summary = fields[7] as String
      ..hint1 = fields[8] as String
      ..hint2 = fields[9] as String;
  }

  @override
  void write(BinaryWriter writer, DecisionMap obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.option1Id)
      ..writeByte(2)
      ..write(obj.option2Id)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.question)
      ..writeByte(5)
      ..write(obj.option1)
      ..writeByte(6)
      ..write(obj.option2)
      ..writeByte(7)
      ..write(obj.summary)
      ..writeByte(8)
      ..write(obj.hint1)
      ..writeByte(9)
      ..write(obj.hint2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionMapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
