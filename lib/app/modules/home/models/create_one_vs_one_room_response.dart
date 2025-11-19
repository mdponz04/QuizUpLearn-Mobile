class CreateOneVsOneRoomResponse {
  final bool success;
  final OneVsOneRoomData? data;
  final String? message;
  final dynamic error;
  final dynamic errorType;

  CreateOneVsOneRoomResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory CreateOneVsOneRoomResponse.fromJson(Map<String, dynamic> json) {
    return CreateOneVsOneRoomResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? OneVsOneRoomData.fromJson(json['data'])
          : null,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
    );
  }
}

class OneVsOneRoomData {
  final String roomPin;
  final String roomId;
  final DateTime createdAt;

  OneVsOneRoomData({
    required this.roomPin,
    required this.roomId,
    required this.createdAt,
  });

  factory OneVsOneRoomData.fromJson(Map<String, dynamic> json) {
    return OneVsOneRoomData(
      roomPin: json['roomPin'] ?? '',
      roomId: json['roomId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomPin': roomPin,
      'roomId': roomId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

