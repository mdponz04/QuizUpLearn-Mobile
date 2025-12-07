class EventJoinedStatusResponse {
  final bool success;
  final EventJoinedStatusData? data;
  final String? message;
  final String? error;
  final int? errorType;

  EventJoinedStatusResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory EventJoinedStatusResponse.fromJson(Map<String, dynamic> json) {
    return EventJoinedStatusResponse(
      success: json['success'] ?? false,
      data: json['data'] != null 
          ? EventJoinedStatusData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
      error: json['error']?.toString(),
      errorType: json['errorType'] is int 
          ? json['errorType'] as int
          : (json['errorType'] != null ? int.tryParse(json['errorType'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'error': error,
      'errorType': errorType,
    };
  }
}

class EventJoinedStatusData {
  final bool isJoined;

  EventJoinedStatusData({
    required this.isJoined,
  });

  factory EventJoinedStatusData.fromJson(Map<String, dynamic> json) {
    return EventJoinedStatusData(
      isJoined: json['isJoined'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isJoined': isJoined,
    };
  }
}

