import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String content;
  
  @HiveField(2)
  final bool isUser;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final String? thought;
  
  @HiveField(5)
  final String? action;
  
  @HiveField(6)
  final String? imagePath;
  
  @HiveField(7)
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.thought,
    this.action,
    this.imagePath,
    this.type = MessageType.text,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      thought: json['thought'],
      action: json['action'],
      imagePath: json['imagePath'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'thought': thought,
      'action': action,
      'imagePath': imagePath,
      'type': type.toString().split('.').last,
    };
  }
}

@HiveType(typeId: 1)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  voice,
  @HiveField(2)
  image,
  @HiveField(3)
  command,
}
