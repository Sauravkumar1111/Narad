class AppConstants {
  // API Configuration
  static const String defaultApiUrl = 'http://192.168.1.4:8000/api/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTestTimeout = Duration(seconds: 5);

  // UI Constants
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double margin = 8.0;
  static const double iconSize = 24.0;
  static const double buttonHeight = 48.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Chat Constants
  static const int maxChatHistory = 100;
  static const int chatHistoryLimit = 10;
  static const double chatBubbleMaxWidth = 0.75;

  // Voice Constants
  static const double minVoiceLevel = 0.0;
  static const double maxVoiceLevel = 1.0;
  static const Duration voiceTimeout = Duration(seconds: 10);
  static const Duration silenceTimeout = Duration(seconds: 3);

  // Camera Constants
  static const double cameraAspectRatio = 16 / 9;
  static const int imageQuality = 85;
  static const int maxImageSize = 2048;

  // Storage Constants
  static const String chatBoxName = 'chat_messages';
  static const String configBoxName = 'app_config';
  static const String imageCacheDir = 'images';
  static const String audioCacheDir = 'audio';

  // Permission Constants
  static const List<String> requiredPermissions = [
    'camera',
    'microphone',
    'storage',
  ];

  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String apiError = 'API request failed';
  static const String permissionError = 'Permission denied';
  static const String unknownError = 'An unknown error occurred';

  // Success Messages
  static const String messageSent = 'Message sent successfully';
  static const String commandExecuted = 'Command executed successfully';
  static const String imageAnalyzed = 'Image analyzed successfully';

  // Voice Commands
  static const List<String> wakeWords = [
    'jarvis',
    'hey jarvis',
    'ok jarvis',
  ];

  // Supported Languages
  static const List<String> supportedLanguages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko',
  ];

  // TTS Voices
  static const List<String> ttsVoices = [
    'default',
    'male',
    'female',
    'child',
    'elderly',
  ];

  // Analysis Types
  static const List<String> analysisTypes = [
    'faces',
    'objects',
    'both',
  ];
}
