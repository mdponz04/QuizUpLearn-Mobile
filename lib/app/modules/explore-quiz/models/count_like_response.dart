class CountLikeResponse {
  final bool success;
  final int? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  CountLikeResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory CountLikeResponse.fromJson(Map<String, dynamic> json) {
    return CountLikeResponse(
      success: json['success'] ?? false,
      data: json['data'] is int ? json['data'] as int : (json['data'] != null ? int.tryParse(json['data'].toString()) : null),
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

