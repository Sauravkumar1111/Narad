import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class SpeechService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  double _speechLevel = 0.0;
  String _lastSpokenText = '';
  
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  // Getters
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
  String get recognizedText => _recognizedText;
  double get speechLevel => _speechLevel;
  String get lastSpokenText => _lastSpokenText;

  SpeechService() {
    _initializeServices();
  }

  // Initialize TTS and STT
  Future<void> _initializeServices() async {
    try {
      await _initializeTTS();
      await _initializeSTT();
      _isInitialized = true;
      notifyListeners();
      debugPrint('Speech services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing speech services: $e');
    }
  }

  // Initialize Text-to-Speech
  Future<void> _initializeTTS() async {
    try {
      // Set TTS language
      await _flutterTts.setLanguage("en-US");
      
      // Set TTS rate (speech speed)
      await _flutterTts.setSpeechRate(0.5);
      
      // Set TTS volume
      await _flutterTts.setVolume(1.0);
      
      // Set TTS pitch
      await _flutterTts.setPitch(1.0);

      // Set completion handler
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
        debugPrint('TTS completed');
      });

      // Set error handler
      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        notifyListeners();
        debugPrint('TTS error: $message');
      });

      // Set start handler
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
        debugPrint('TTS started');
      });

      debugPrint('TTS initialized successfully');
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  // Initialize Speech-to-Text
  Future<void> _initializeSTT() async {
    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        debugPrint('Microphone permission denied');
        return;
      }

      // Initialize STT
      final available = await _speechToText.initialize(
        onError: (error) {
          debugPrint('STT error: ${error.errorMsg}');
          _isListening = false;
          notifyListeners();
        },
        onStatus: (status) {
          debugPrint('STT status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );

      if (available) {
        debugPrint('STT initialized successfully');
      } else {
        debugPrint('STT not available');
      }
    } catch (e) {
      debugPrint('Error initializing STT: $e');
    }
  }

  // Start listening for speech
  Future<bool> startListening() async {
    if (!_isInitialized) {
      debugPrint('Speech services not initialized');
      return false;
    }

    try {
      // Check microphone permission
      final permission = await Permission.microphone.status;
      if (!permission.isGranted) {
        debugPrint('Microphone permission not granted');
        return false;
      }

      // Start listening
      final result = await _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          notifyListeners();
          debugPrint('Recognized: $_recognizedText');
        },
        listenFor: AppConstants.voiceTimeout,
        pauseFor: AppConstants.silenceTimeout,
        partialResults: true,
        localeId: "en_US",
        onSoundLevelChange: (level) {
          _speechLevel = level;
          notifyListeners();
        },
      );

      if (result) {
        _isListening = true;
        notifyListeners();
        debugPrint('Started listening for speech');
        return true;
      }
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
    }
    return false;
  }

  // Stop listening for speech
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
      notifyListeners();
      debugPrint('Stopped listening for speech');
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
    }
  }

  // Cancel speech recognition
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
      _recognizedText = '';
      notifyListeners();
      debugPrint('Cancelled speech recognition');
    } catch (e) {
      debugPrint('Error cancelling speech recognition: $e');
    }
  }

  // Speak text
  Future<bool> speak(String text) async {
    if (!_isInitialized || text.isEmpty) {
      debugPrint('TTS not initialized or empty text');
      return false;
    }

    try {
      _lastSpokenText = text;
      await _flutterTts.speak(text);
      debugPrint('Speaking: $text');
      return true;
    } catch (e) {
      debugPrint('Error speaking text: $e');
      return false;
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
      debugPrint('Stopped speaking');
    } catch (e) {
      debugPrint('Error stopping speech: $e');
    }
  }

  // Pause speaking
  Future<void> pauseSpeaking() async {
    try {
      await _flutterTts.pause();
      debugPrint('Paused speaking');
    } catch (e) {
      debugPrint('Error pausing speech: $e');
    }
  }

  // Set TTS rate
  Future<void> setTTSRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
      debugPrint('TTS rate set to: $rate');
    } catch (e) {
      debugPrint('Error setting TTS rate: $e');
    }
  }

  // Set TTS volume
  Future<void> setTTSVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
      debugPrint('TTS volume set to: $volume');
    } catch (e) {
      debugPrint('Error setting TTS volume: $e');
    }
  }

  // Set TTS pitch
  Future<void> setTTSPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
      debugPrint('TTS pitch set to: $pitch');
    } catch (e) {
      debugPrint('Error setting TTS pitch: $e');
    }
  }

  // Set TTS language
  Future<void> setTTSLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      debugPrint('TTS language set to: $language');
    } catch (e) {
      debugPrint('Error setting TTS language: $e');
    }
  }

  // Get available TTS languages
  Future<List<dynamic>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages ?? [];
    } catch (e) {
      debugPrint('Error getting available languages: $e');
      return [];
    }
  }

  // Get available TTS voices
  Future<List<dynamic>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices ?? [];
    } catch (e) {
      debugPrint('Error getting available voices: $e');
      return [];
    }
  }

  // Check if speech recognition is available
  Future<bool> isSpeechRecognitionAvailable() async {
    try {
      final hasPermission = await _speechToText.hasPermission;
      return hasPermission ?? false;
    } catch (e) {
      debugPrint('Error checking speech recognition availability: $e');
      return false;
    }
  }

  // Check if TTS is available
  Future<bool> isTTSAvailable() async {
    try {
      final result = await _flutterTts.getLanguages;
      return result != null && result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking TTS availability: $e');
      return false;
    }
  }

  // Clear recognized text
  void clearRecognizedText() {
    _recognizedText = '';
    notifyListeners();
  }

  // Get speech recognition status
  String getSpeechRecognitionStatus() {
    return _speechToText.lastStatus ?? 'unknown';
  }

  // Get TTS status
  String getTTSStatus() {
    return _isSpeaking ? 'speaking' : 'idle';
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }
}
