class EventJoinResponse {
  final bool success;
  final String? data;
  final String? message;
  final String? error;
  final String? errorType;

  EventJoinResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory EventJoinResponse.fromJson(Map<String, dynamic> json) {
    return EventJoinResponse(
      success: json['success'] ?? false,
      data: json['data']?.toString(),
      message: json['message']?.toString(),
      error: json['error']?.toString(),
      errorType: json['errorType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'error': error,
      'errorType': errorType,
    };
  }
}

