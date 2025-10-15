// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final int typeId = 2;

  @override
  AppConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfig(
      apiUrl: fields[0] as String,
      voiceMode: fields[1] as bool,
      cameraMode: fields[2] as bool,
      language: fields[3] as String,
      ttsRate: fields[4] as double,
      ttsVolume: fields[5] as double,
      ttsVoice: fields[6] as String,
      continuousListening: fields[7] as bool,
      darkMode: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.apiUrl)
      ..writeByte(1)
      ..write(obj.voiceMode)
      ..writeByte(2)
      ..write(obj.cameraMode)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.ttsRate)
      ..writeByte(5)
      ..write(obj.ttsVolume)
      ..writeByte(6)
      ..write(obj.ttsVoice)
      ..writeByte(7)
      ..write(obj.continuousListening)
      ..writeByte(8)
      ..write(obj.darkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
