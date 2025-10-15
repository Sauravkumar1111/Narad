import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/chat_message.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);
  
  final String baseUrl;
  
  ApiService({required this.baseUrl});

  // Chat endpoint
  Future<ChatResponse> sendChatMessage(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'text=${Uri.encodeComponent(message)}',
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        throw ApiException(
          'Failed to send chat message',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  // Command endpoint
  Future<CommandResponse> executeCommand(String action, Map<String, dynamic> parameters) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/command'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'action': action,
              'parameters': parameters,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CommandResponse.fromJson(data);
      } else {
        throw ApiException(
          'Failed to execute command',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  // Vision endpoint
  Future<VisionResponse> analyzeImage(File imageFile, {String analysisType = 'both'}) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/vision/analyze'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      request.fields['analysis_type'] = analysisType;

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VisionResponse.fromJson(data);
      } else {
        throw ApiException(
          'Failed to analyze image',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  // Status endpoint
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/status'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to get status',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  // Chat history endpoint
  Future<List<ChatMessage>> getChatHistory({int limit = 10}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/chat/history?limit=$limit'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final history = data['history'] as List;
        
        return history.map((item) {
          return ChatMessage(
            id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            content: item['content'] ?? '',
            isUser: false, // History items are from Jarvis
            timestamp: DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
            thought: item['metadata']?['thought'],
            action: item['metadata']?['action'],
          );
        }).toList();
      } else {
        throw ApiException(
          'Failed to get chat history',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  // Surveillance endpoints
  Future<List<String>> getAvailableCameras() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/surveillance/cameras'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['cameras'] ?? []);
      } else {
        throw ApiException(
          'Failed to get cameras',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  Future<Map<String, dynamic>> monitorCamera(String location, {int duration = 10}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/surveillance/monitor'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'location': location,
              'duration': duration,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to monitor camera',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  Future<Map<String, dynamic>> analyzeCameraFeed(String location) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/surveillance/analyze'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'location': location,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to analyze camera feed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  Future<Map<String, dynamic>> getCameraFeed(String location) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/surveillance/feed/$location'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to get camera feed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  Future<Map<String, dynamic>> updateCameraConfig(String location, String url) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/surveillance/config'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'location': location,
              'url': url,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to update camera config',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  Future<Map<String, dynamic>> getCameraConfig() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/surveillance/config'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to get camera config',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  Future<Map<String, dynamic>> checkCameraSurveillance(String query) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/surveillance/check'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'query': query,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to check camera surveillance',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0, '');
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/test'))
          .timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  ApiException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}
