class CreateUserQuizSetFavoriteResponse {
  final bool success;
  final dynamic data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  CreateUserQuizSetFavoriteResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory CreateUserQuizSetFavoriteResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserQuizSetFavoriteResponse(
      success: json['success'] ?? false,
      data: json['data'],
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

