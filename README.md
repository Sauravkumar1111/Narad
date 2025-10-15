# Jarvis Assistant Mobile App

A cross-platform Flutter mobile application that connects to the Jarvis AI backend, providing voice, text, and camera-based interactions with your personal AI assistant.

## Features

- 🎙️ **Voice Mode**: Speech-to-text input with text-to-speech responses
- 💬 **Text Mode**: Traditional chat interface with keyboard input
- 📸 **Camera Mode**: Image capture and analysis using computer vision
- 🧠 **AI Integration**: Connects to Jarvis backend for intelligent responses
- 💾 **Local Storage**: Chat history and user preferences stored locally
- ⚙️ **Configurable**: Customizable API endpoints, voice settings, and themes
- 🌙 **Dark Theme**: Sleek dark UI with neon accents

## Prerequisites

- Flutter SDK (3.16.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode for platform-specific development
- Jarvis backend running on your network

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd jarvis_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Backend Connection

The app connects to your Jarvis backend by default at `http://192.168.1.50:8000/api/v1`. You can change this in the settings screen.

### Permissions

The app requires the following permissions:
- **Camera**: For image capture and analysis
- **Microphone**: For voice input
- **Storage**: For saving chat history and images
- **Network**: For API communication

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # UI screens
│   ├── home_screen.dart     # Main chat interface
│   ├── camera_screen.dart   # Camera interface
│   ├── settings_screen.dart # Configuration
│   └── history_screen.dart  # Chat history
├── services/                 # Business logic
│   ├── api_service.dart      # Backend communication
│   ├── speech_service.dart  # Voice processing
│   ├── vision_service.dart  # Camera/image processing
│   ├── config_service.dart  # Settings management
│   └── memory_service.dart  # Local storage
├── widgets/                  # Reusable UI components
│   ├── chat_bubble.dart     # Message display
│   ├── mic_button.dart      # Voice input button
│   ├── camera_button.dart   # Camera button
│   └── loader.dart          # Loading indicators
├── models/                   # Data models
│   ├── chat_message.dart    # Message structure
│   ├── api_response.dart    # API response models
│   └── app_config.dart      # App configuration
└── utils/                    # Utilities
    ├── constants.dart        # App constants
    ├── theme.dart           # UI theme
    └── helpers.dart         # Helper functions
```

## API Integration

The app integrates with the following Jarvis backend endpoints:

- `POST /api/v1/chat` - Send text messages
- `POST /api/v1/command` - Execute commands
- `POST /api/v1/vision/analyze` - Analyze images
- `GET /api/v1/status` - Check backend status
- `GET /api/v1/chat/history` - Get chat history

## Usage

### Voice Mode
1. Tap the microphone button
2. Speak your message
3. The app will convert speech to text and send to Jarvis
4. Jarvis response will be played as audio

### Text Mode
1. Type your message in the text field
2. Tap send or press Enter
3. View Jarvis response in the chat

### Camera Mode
1. Tap the camera button
2. Capture an image
3. The image will be analyzed by Jarvis
4. View the analysis results

## Development

### Adding New Features

1. **New Screen**: Add to `lib/screens/`
2. **New Service**: Add to `lib/services/`
3. **New Widget**: Add to `lib/widgets/`
4. **New Model**: Add to `lib/models/`

### State Management

The app uses Provider for state management:
- `ConfigService`: Manages app settings
- `MemoryService`: Manages chat history
- `ApiService`: Handles backend communication

### Local Storage

Chat messages and app configuration are stored locally using Hive:
- `chat_messages`: Chat history
- `app_config`: User preferences

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Backend Connection Failed**
   - Check if Jarvis backend is running
   - Verify the API URL in settings
   - Ensure network connectivity

2. **Permissions Denied**
   - Grant camera and microphone permissions
   - Check device settings

3. **Build Errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Regenerate Hive adapters

### Debug Mode

Enable debug logging by setting `debugPrint` statements in the code.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the API documentation

## Roadmap

- [ ] WebSocket support for real-time communication
- [ ] AR overlay for object detection
- [ ] IoT device control dashboard
- [ ] Smartwatch integration
- [ ] Multi-language support
- [ ] Voice command shortcuts
- [ ] Offline mode capabilities
