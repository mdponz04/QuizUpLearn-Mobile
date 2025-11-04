class GenerateQuizResponse {
  final bool? success;
  final String? message;
  final dynamic data;

  GenerateQuizResponse({
    this.success,
    this.message,
    this.data,
  });

  factory GenerateQuizResponse.fromJson(Map<String, dynamic> json) {
    return GenerateQuizResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }
}

