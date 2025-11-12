// To parse this JSON data, do
//
//     final submitAllAnswersResponse = submitAllAnswersResponseFromJson(jsonString);

import 'dart:convert';

SubmitAllAnswersResponse submitAllAnswersResponseFromJson(String str) =>
    SubmitAllAnswersResponse.fromJson(json.decode(str));

String submitAllAnswersResponseToJson(SubmitAllAnswersResponse data) =>
    json.encode(data.toJson());

class SubmitAllAnswersResponse {
  bool? success;
  Data? data;
  dynamic message;
  dynamic error;
  dynamic errorType;

  SubmitAllAnswersResponse({
    this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory SubmitAllAnswersResponse.fromJson(Map<String, dynamic> json) =>
      SubmitAllAnswersResponse(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
        error: json["error"],
        errorType: json["errorType"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
        "error": error,
        "errorType": errorType,
      };
}

class Data {
  String? attemptId;
  int? totalQuestions;
  int? correctAnswers;
  int? wrongAnswers;
  int? score;
  double? accuracy;
  String? status;
  List<AnswerResult>? answerResults;
  dynamic weakPoints;

  Data({
    this.attemptId,
    this.totalQuestions,
    this.correctAnswers,
    this.wrongAnswers,
    this.score,
    this.accuracy,
    this.status,
    this.answerResults,
    this.weakPoints,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        attemptId: json["attemptId"],
        totalQuestions: json["totalQuestions"],
        correctAnswers: json["correctAnswers"],
        wrongAnswers: json["wrongAnswers"],
        score: json["score"],
        accuracy: json["accuracy"]?.toDouble(),
        status: json["status"],
        answerResults: json["answerResults"] == null
            ? []
            : List<AnswerResult>.from(
                json["answerResults"]!.map((x) => AnswerResult.fromJson(x))),
        weakPoints: json["weakPoints"],
      );

  Map<String, dynamic> toJson() => {
        "attemptId": attemptId,
        "totalQuestions": totalQuestions,
        "correctAnswers": correctAnswers,
        "wrongAnswers": wrongAnswers,
        "score": score,
        "accuracy": accuracy,
        "status": status,
        "answerResults": answerResults == null
            ? []
            : List<dynamic>.from(answerResults!.map((x) => x.toJson())),
        "weakPoints": weakPoints,
      };

  // Helper methods
  String get formattedAccuracy => '${(accuracy ?? 0.0).toStringAsFixed(1)}%';
}

class AnswerResult {
  String? questionId;
  bool? isCorrect;
  String? correctAnswerOptionId;
  String? explanation;

  AnswerResult({
    this.questionId,
    this.isCorrect,
    this.correctAnswerOptionId,
    this.explanation,
  });

  factory AnswerResult.fromJson(Map<String, dynamic> json) => AnswerResult(
        questionId: json["questionId"],
        isCorrect: json["isCorrect"],
        correctAnswerOptionId: json["correctAnswerOptionId"],
        explanation: json["explanation"],
      );

  Map<String, dynamic> toJson() => {
        "questionId": questionId,
        "isCorrect": isCorrect,
        "correctAnswerOptionId": correctAnswerOptionId,
        "explanation": explanation,
      };
}

