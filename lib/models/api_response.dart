class ChatResponse {
  final String input;
  final String thought;
  final String action;
  final String response;

  ChatResponse({
    required this.input,
    required this.thought,
    required this.action,
    required this.response,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      input: json['input'] ?? '',
      thought: json['thought'] ?? '',
      action: json['action'] ?? '',
      response: json['response'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'thought': thought,
      'action': action,
      'response': response,
    };
  }
}

class CommandResponse {
  final String status;
  final String message;
  final dynamic result;
  final String? device;
  final String? state;

  CommandResponse({
    required this.status,
    required this.message,
    this.result,
    this.device,
    this.state,
  });

  factory CommandResponse.fromJson(Map<String, dynamic> json) {
    return CommandResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      result: json['result'],
      device: json['device'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'result': result,
      'device': device,
      'state': state,
    };
  }
}

class VisionResponse {
  final bool success;
  final Map<String, dynamic> results;
  final String message;

  VisionResponse({
    required this.success,
    required this.results,
    required this.message,
  });

  factory VisionResponse.fromJson(Map<String, dynamic> json) {
    return VisionResponse(
      success: json['success'] ?? false,
      results: json['results'] ?? {},
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'results': results,
      'message': message,
    };
  }
}

class ApiError {
  final String error;
  final String detail;
  final String timestamp;

  ApiError({
    required this.error,
    required this.detail,
    required this.timestamp,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      error: json['error'] ?? 'Unknown error',
      detail: json['detail'] ?? 'No details available',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}
