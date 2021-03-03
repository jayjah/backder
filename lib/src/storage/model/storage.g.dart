// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoreAdapter extends TypeAdapter<Store> {
  @override
  final int typeId = 0;

  @override
  Store read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Store()
      ..postgresName = fields[0] as String
      ..serverName = fields[1] as String
      ..mailJetPublic = fields[2] as String
      ..mailJetPrivate = fields[3] as String
      ..emailFrom = fields[4] as String
      ..emailTo = fields[5] as String
      ..postgresDbUser = fields[6] as String
      ..postgresDbPw = fields[7] as String
      ..postgresDbName = fields[8] as String
      ..resticPassword = fields[9] as String;
  }

  @override
  void write(BinaryWriter writer, Store obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.postgresName)
      ..writeByte(1)
      ..write(obj.serverName)
      ..writeByte(2)
      ..write(obj.mailJetPublic)
      ..writeByte(3)
      ..write(obj.mailJetPrivate)
      ..writeByte(4)
      ..write(obj.emailFrom)
      ..writeByte(5)
      ..write(obj.emailTo)
      ..writeByte(6)
      ..write(obj.postgresDbUser)
      ..writeByte(7)
      ..write(obj.postgresDbPw)
      ..writeByte(8)
      ..write(obj.postgresDbName)
      ..writeByte(9)
      ..write(obj.resticPassword);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}