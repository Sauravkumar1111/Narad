import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_config.dart';
import '../utils/constants.dart';

class ConfigService extends ChangeNotifier {
  late Box<AppConfig> _configBox;
  AppConfig _config = AppConfig();

  AppConfig get config => _config;

  ConfigService() {
    _initializeConfig();
  }

  Future<void> _initializeConfig() async {
    try {
      _configBox = Hive.box<AppConfig>(AppConstants.configBoxName);
      
      // Load existing config or create default
      if (_configBox.isNotEmpty) {
        _config = _configBox.getAt(0) ?? AppConfig();
      } else {
        _config = AppConfig();
        await _configBox.add(_config);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing config: $e');
      _config = AppConfig();
    }
  }

  Future<void> updateConfig(AppConfig newConfig) async {
    try {
      _config = newConfig;
      await _configBox.putAt(0, _config);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating config: $e');
    }
  }

  Future<void> updateApiUrl(String apiUrl) async {
    final newConfig = _config.copyWith(apiUrl: apiUrl);
    await updateConfig(newConfig);
  }

  Future<void> updateVoiceMode(bool voiceMode) async {
    final newConfig = _config.copyWith(voiceMode: voiceMode);
    await updateConfig(newConfig);
  }

  Future<void> updateCameraMode(bool cameraMode) async {
    final newConfig = _config.copyWith(cameraMode: cameraMode);
    await updateConfig(newConfig);
  }

  Future<void> updateLanguage(String language) async {
    final newConfig = _config.copyWith(language: language);
    await updateConfig(newConfig);
  }

  Future<void> updateTtsRate(double ttsRate) async {
    final newConfig = _config.copyWith(ttsRate: ttsRate);
    await updateConfig(newConfig);
  }

  Future<void> updateTtsVolume(double ttsVolume) async {
    final newConfig = _config.copyWith(ttsVolume: ttsVolume);
    await updateConfig(newConfig);
  }

  Future<void> updateTtsVoice(String ttsVoice) async {
    final newConfig = _config.copyWith(ttsVoice: ttsVoice);
    await updateConfig(newConfig);
  }

  Future<void> updateContinuousListening(bool continuousListening) async {
    final newConfig = _config.copyWith(continuousListening: continuousListening);
    await updateConfig(newConfig);
  }

  Future<void> updateDarkMode(bool darkMode) async {
    final newConfig = _config.copyWith(darkMode: darkMode);
    await updateConfig(newConfig);
  }

  Future<void> resetToDefaults() async {
    final defaultConfig = AppConfig();
    await updateConfig(defaultConfig);
  }

  // Getters for individual config values
  String get apiUrl => _config.apiUrl;
  bool get voiceMode => _config.voiceMode;
  bool get cameraMode => _config.cameraMode;
  String get language => _config.language;
  double get ttsRate => _config.ttsRate;
  double get ttsVolume => _config.ttsVolume;
  String get ttsVoice => _config.ttsVoice;
  bool get continuousListening => _config.continuousListening;
  bool get darkMode => _config.darkMode;

  // Validation methods
  bool isValidApiUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isValidLanguage(String language) {
    return AppConstants.supportedLanguages.contains(language);
  }

  bool isValidTtsVoice(String voice) {
    return AppConstants.ttsVoices.contains(voice);
  }

  bool isValidTtsRate(double rate) {
    return rate >= 0.1 && rate <= 2.0;
  }

  bool isValidTtsVolume(double volume) {
    return volume >= 0.0 && volume <= 1.0;
  }
}
