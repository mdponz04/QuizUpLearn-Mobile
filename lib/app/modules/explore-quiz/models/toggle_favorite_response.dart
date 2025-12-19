class ToggleFavoriteResponse {
  final bool success;
  final bool? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  ToggleFavoriteResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory ToggleFavoriteResponse.fromJson(Map<String, dynamic> json) {
    return ToggleFavoriteResponse(
      success: json['success'] ?? false,
      data: json['data'] is bool ? json['data'] as bool : null,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
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

