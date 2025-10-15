import 'package:hive/hive.dart';

part 'app_config.g.dart';

@HiveType(typeId: 2)
class AppConfig extends HiveObject {
  @HiveField(0)
  String apiUrl;
  
  @HiveField(1)
  bool voiceMode;
  
  @HiveField(2)
  bool cameraMode;
  
  @HiveField(3)
  String language;
  
  @HiveField(4)
  double ttsRate;
  
  @HiveField(5)
  double ttsVolume;
  
  @HiveField(6)
  String ttsVoice;
  
  @HiveField(7)
  bool continuousListening;
  
  @HiveField(8)
  bool darkMode;

  AppConfig({
    this.apiUrl = 'http://192.168.1.4:8000/api/v1',
    this.voiceMode = true,
    this.cameraMode = true,
    this.language = 'en',
    this.ttsRate = 0.5,
    this.ttsVolume = 1.0,
    this.ttsVoice = 'default',
    this.continuousListening = false,
    this.darkMode = true,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      apiUrl: json['apiUrl'] ?? 'http://192.168.1.4:8000/api/v1',
      voiceMode: json['voiceMode'] ?? true,
      cameraMode: json['cameraMode'] ?? true,
      language: json['language'] ?? 'en',
      ttsRate: json['ttsRate']?.toDouble() ?? 0.5,
      ttsVolume: json['ttsVolume']?.toDouble() ?? 1.0,
      ttsVoice: json['ttsVoice'] ?? 'default',
      continuousListening: json['continuousListening'] ?? false,
      darkMode: json['darkMode'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiUrl': apiUrl,
      'voiceMode': voiceMode,
      'cameraMode': cameraMode,
      'language': language,
      'ttsRate': ttsRate,
      'ttsVolume': ttsVolume,
      'ttsVoice': ttsVoice,
      'continuousListening': continuousListening,
      'darkMode': darkMode,
    };
  }

  AppConfig copyWith({
    String? apiUrl,
    bool? voiceMode,
    bool? cameraMode,
    String? language,
    double? ttsRate,
    double? ttsVolume,
    String? ttsVoice,
    bool? continuousListening,
    bool? darkMode,
  }) {
    return AppConfig(
      apiUrl: apiUrl ?? this.apiUrl,
      voiceMode: voiceMode ?? this.voiceMode,
      cameraMode: cameraMode ?? this.cameraMode,
      language: language ?? this.language,
      ttsRate: ttsRate ?? this.ttsRate,
      ttsVolume: ttsVolume ?? this.ttsVolume,
      ttsVoice: ttsVoice ?? this.ttsVoice,
      continuousListening: continuousListening ?? this.continuousListening,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
