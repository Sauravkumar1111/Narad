import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';

class MemoryService extends ChangeNotifier {
  late Box<ChatMessage> _chatBox;
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  MemoryService() {
    _initializeMemory();
  }

  Future<void> _initializeMemory() async {
    try {
      _chatBox = Hive.box<ChatMessage>(AppConstants.chatBoxName);
      
      // Load existing messages
      _messages.clear();
      _messages.addAll(_chatBox.values.toList());
      
      // Sort by timestamp
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing memory: $e');
    }
  }

  Future<void> addMessage(ChatMessage message) async {
    try {
      _messages.add(message);
      await _chatBox.add(message);
      
      // Limit messages to max count
      if (_messages.length > AppConstants.maxChatHistory) {
        final oldestMessage = _messages.removeAt(0);
        await oldestMessage.delete();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding message: $e');
    }
  }

  Future<void> addUserMessage(String content) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    
    await addMessage(message);
  }

  Future<void> addJarvisMessage(String content, {String? thought, String? action}) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      thought: thought,
      action: action,
      type: MessageType.text,
    );
    
    await addMessage(message);
  }

  Future<void> addVoiceMessage(String content, bool isUser) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
      type: MessageType.voice,
    );
    
    await addMessage(message);
  }

  Future<void> addImageMessage(String content, String imagePath, bool isUser) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
      imagePath: imagePath,
      type: MessageType.image,
    );
    
    await addMessage(message);
  }

  Future<void> addCommandMessage(String content, String action) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      action: action,
      type: MessageType.command,
    );
    
    await addMessage(message);
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        final message = _messages.removeAt(messageIndex);
        await message.delete();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  Future<void> clearAllMessages() async {
    try {
      await _chatBox.clear();
      _messages.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing messages: $e');
    }
  }

  Future<void> clearOldMessages({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final messagesToDelete = _messages.where((m) => m.timestamp.isBefore(cutoffDate)).toList();
      
      for (final message in messagesToDelete) {
        _messages.remove(message);
        await message.delete();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing old messages: $e');
    }
  }

  List<ChatMessage> getMessagesByType(MessageType type) {
    return _messages.where((m) => m.type == type).toList();
  }

  List<ChatMessage> getUserMessages() {
    return _messages.where((m) => m.isUser).toList();
  }

  List<ChatMessage> getJarvisMessages() {
    return _messages.where((m) => !m.isUser).toList();
  }

  List<ChatMessage> getMessagesWithImages() {
    return _messages.where((m) => m.imagePath != null).toList();
  }

  List<ChatMessage> getMessagesWithActions() {
    return _messages.where((m) => m.action != null && m.action!.isNotEmpty).toList();
  }

  ChatMessage? getMessageById(String id) {
    try {
      return _messages.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ChatMessage> searchMessages(String query) {
    if (query.isEmpty) return _messages;
    
    final lowercaseQuery = query.toLowerCase();
    return _messages.where((m) => 
      m.content.toLowerCase().contains(lowercaseQuery) ||
      (m.thought?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (m.action?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  int get messageCount => _messages.length;
  int get userMessageCount => getUserMessages().length;
  int get jarvisMessageCount => getJarvisMessages().length;
  int get imageMessageCount => getMessagesWithImages().length;
  int get commandMessageCount => getMessagesWithActions().length;

  DateTime? get lastMessageTime {
    if (_messages.isEmpty) return null;
    return _messages.last.timestamp;
  }

  DateTime? get firstMessageTime {
    if (_messages.isEmpty) return null;
    return _messages.first.timestamp;
  }

  Duration? get conversationDuration {
    final first = firstMessageTime;
    final last = lastMessageTime;
    if (first == null || last == null) return null;
    return last.difference(first);
  }
}
