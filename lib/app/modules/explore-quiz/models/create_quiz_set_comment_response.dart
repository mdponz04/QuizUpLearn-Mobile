class CreateQuizSetCommentResponse {
  final bool success;
  final dynamic data;
  final dynamic message;
  final dynamic errorType;

  CreateQuizSetCommentResponse({
    required this.success,
    this.data,
    this.message,
    this.errorType,
  });

  factory CreateQuizSetCommentResponse.fromJson(Map<String, dynamic> json) {
    return CreateQuizSetCommentResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'],
      errorType: json['errorType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'errorType': errorType,
    };
  }
}

