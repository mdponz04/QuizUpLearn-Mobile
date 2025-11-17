import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';

class QuizSetDetailResponse {
  final bool success;
  final QuizSetModel? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  QuizSetDetailResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory QuizSetDetailResponse.fromJson(Map<String, dynamic> json) {
    return QuizSetDetailResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? QuizSetModel.fromJson(json['data'])
          : null,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
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

