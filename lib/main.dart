import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service_manager.dart';
import 'services/config_service.dart';
import 'services/memory_service.dart';
import 'services/vision_service.dart';
import 'services/speech_service.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'models/chat_message.dart';
import 'models/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  Hive.registerAdapter(AppConfigAdapter());
  
  // Open boxes
  await Hive.openBox<ChatMessage>(AppConstants.chatBoxName);
  await Hive.openBox<AppConfig>(AppConstants.configBoxName);
  
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigService()),
        ChangeNotifierProvider(create: (_) => MemoryService()),
        ChangeNotifierProvider(create: (context) {
          final configService = context.read<ConfigService>();
          return ApiServiceManager(configService);
        }),
        ChangeNotifierProvider(create: (context) => VisionService(
          apiService: context.read<ApiServiceManager>().apiService,
        )),
        ChangeNotifierProvider(create: (_) => SpeechService()),
      ],
      child: Consumer<ConfigService>(
        builder: (context, configService, child) {
          return MaterialApp(
            title: 'Jarvis Assistant',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: configService.config.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
