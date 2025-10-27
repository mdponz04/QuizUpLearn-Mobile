// To parse this JSON data, do
//
//     final submitAnswerResponse = submitAnswerResponseFromJson(jsonString);

import 'dart:convert';

SubmitAnswerResponse submitAnswerResponseFromJson(String str) => SubmitAnswerResponse.fromJson(json.decode(str));

String submitAnswerResponseToJson(SubmitAnswerResponse data) => json.encode(data.toJson());

class SubmitAnswerResponse {
    bool? success;
    Data? data;
    dynamic message;
    dynamic error;
    dynamic errorType;

    SubmitAnswerResponse({
        this.success,
        this.data,
        this.message,
        this.error,
        this.errorType,
    });

    factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) => SubmitAnswerResponse(
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
    String? detailId;
    String? attemptId;
    String? questionId;
    String? userAnswer;
    int? timeSpent;
    DateTime? submittedAt;

    Data({
        this.detailId,
        this.attemptId,
        this.questionId,
        this.userAnswer,
        this.timeSpent,
        this.submittedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        detailId: json["detailId"],
        attemptId: json["attemptId"],
        questionId: json["questionId"],
        userAnswer: json["userAnswer"],
        timeSpent: json["timeSpent"],
        submittedAt: json["submittedAt"] == null ? null : DateTime.parse(json["submittedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "detailId": detailId,
        "attemptId": attemptId,
        "questionId": questionId,
        "userAnswer": userAnswer,
        "timeSpent": timeSpent,
        "submittedAt": submittedAt?.toIso8601String(),
    };
}
