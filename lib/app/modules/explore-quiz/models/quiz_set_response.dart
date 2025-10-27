import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';

class QuizSetResponse {
  final bool success;
  final List<QuizSetModel> data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  QuizSetResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.error,
    required this.errorType,
  });

  factory QuizSetResponse.fromJson(Map<String, dynamic> json) {
    return QuizSetResponse(
      success: json["success"],
      data: (json["data"] as List)
          .map((item) => QuizSetModel.fromJson(item))
          .toList(),
      message: json["message"],
      error: json["error"],
      errorType: json["errorType"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data.map((item) => item.toJson()).toList(),
      "message": message,
      "error": error,
      "errorType": errorType,
    };
  }
}
