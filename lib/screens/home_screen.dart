import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service_manager.dart';
import '../services/memory_service.dart';
import '../services/config_service.dart';
import '../services/vision_service.dart';
import '../services/speech_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/mic_button.dart';
import '../widgets/camera_button.dart';
import '../widgets/loader.dart';
import '../screens/camera_screen.dart';
import '../screens/surveillance_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final apiServiceManager = Provider.of<ApiServiceManager>(context, listen: false);
    final isConnected = await apiServiceManager.apiService.testConnection();
    
    if (!isConnected) {
      AppHelpers.showErrorSnackBar(context, 'Cannot connect to Jarvis backend');
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final memoryService = Provider.of<MemoryService>(context, listen: false);
      final apiServiceManager = Provider.of<ApiServiceManager>(context, listen: false);
      final speechService = Provider.of<SpeechService>(context, listen: false);

      // Add user message
      await memoryService.addUserMessage(message);

      // Send to API
      final response = await apiServiceManager.apiService.sendChatMessage(message);

      // Add Jarvis response
      await memoryService.addJarvisMessage(
        response.response,
        thought: response.thought,
        action: response.action,
      );

      // Speak the response if voice mode is enabled
      final configService = Provider.of<ConfigService>(context, listen: false);
      if (configService.voiceMode) {
        await speechService.speak(response.response);
      }

      // Scroll to bottom
      _scrollToBottom();

    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Failed to send message: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startVoiceInput() async {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    
    try {
      final success = await speechService.startListening();
      if (success) {
        setState(() {
          _isListening = true;
        });
      } else {
        AppHelpers.showErrorSnackBar(context, 'Failed to start voice input');
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Error: ${e.toString()}');
    }
  }

  Future<void> _stopVoiceInput() async {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    
    try {
      await speechService.stopListening();
      setState(() {
        _isListening = false;
      });

      // Send recognized text if available
      final recognizedText = speechService.recognizedText;
      if (recognizedText.isNotEmpty) {
        await _sendMessage(recognizedText);
        speechService.clearRecognizedText();
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'Error: ${e.toString()}');
    }
  }

  Future<void> _openCamera() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppConstants.shortAnimation,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jarvis Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewFeaturesScreen()),
              );
            },
            tooltip: 'New Features',
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SurveillanceScreen()),
              );
            },
            tooltip: 'Surveillance',
          ),
          IconButton(
            icon: const Icon(Icons.video_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraConfigScreen()),
              );
            },
            tooltip: 'Camera Config',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navigate to history screen
            },
            tooltip: 'History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Consumer<MemoryService>(
              builder: (context, memoryService, child) {
                final messages = memoryService.messages;
                
                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Start a conversation with Jarvis',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Use voice, text, or camera to interact',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppConstants.padding),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatBubble(
                      message: message,
                      onImageTap: () {
                        // TODO: Show image viewer
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppConstants.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Jarvis is thinking...'),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(AppConstants.padding),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Camera Button
                Consumer<ConfigService>(
                  builder: (context, configService, child) {
                    if (!configService.cameraMode) return const SizedBox.shrink();
                    
                    return CameraButton(
                      onPressed: _openCamera,
                    );
                  },
                ),

                const SizedBox(width: AppConstants.margin),

                // Text Input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _sendMessage(value.trim());
                        _textController.clear();
                      }
                    },
                  ),
                ),

                const SizedBox(width: AppConstants.margin),

                // Send Button
                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          final message = _textController.text.trim();
                          if (message.isNotEmpty) {
                            _sendMessage(message);
                            _textController.clear();
                          }
                        },
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(width: AppConstants.margin),

                // Mic Button
                Consumer<ConfigService>(
                  builder: (context, configService, child) {
                    if (!configService.voiceMode) return const SizedBox.shrink();
                    
                    return MicButton(
                      isRecording: _isListening,
                      voiceLevel: Provider.of<SpeechService>(context).speechLevel,
                      onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
