class CreateGameResponse {
  final bool success;
  final GameData? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  CreateGameResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory CreateGameResponse.fromJson(Map<String, dynamic> json) {
    return CreateGameResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && json['data'] != null
          ? GameData.fromJson(json['data'])
          : null,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
    );
  }
}

class GameData {
  final String gamePin;
  final String gameSessionId;
  final DateTime createdAt;

  GameData({
    required this.gamePin,
    required this.gameSessionId,
    required this.createdAt,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      gamePin: json['gamePin'] ?? '',
      gameSessionId: json['gameSessionId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

