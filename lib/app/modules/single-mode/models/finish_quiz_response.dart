// To parse this JSON data, do
//
//     final finishQuizResponse = finishQuizResponseFromJson(jsonString);

import 'dart:convert';

FinishQuizResponse finishQuizResponseFromJson(String str) => FinishQuizResponse.fromJson(json.decode(str));

String finishQuizResponseToJson(FinishQuizResponse data) => json.encode(data.toJson());

class FinishQuizResponse {
    bool? success;
    Data? data;
    dynamic message;
    dynamic error;
    dynamic errorType;

    FinishQuizResponse({
        this.success,
        this.data,
        this.message,
        this.error,
        this.errorType,
    });

    factory FinishQuizResponse.fromJson(Map<String, dynamic> json) => FinishQuizResponse(
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
    int? totalTimeSpent;
    DateTime? completedAt;
    String? status;
    String? rank;
    Improvement? improvement;

    Data({
        this.attemptId,
        this.totalQuestions,
        this.correctAnswers,
        this.wrongAnswers,
        this.score,
        this.accuracy,
        this.totalTimeSpent,
        this.completedAt,
        this.status,
        this.rank,
        this.improvement,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        attemptId: json["attemptId"],
        totalQuestions: json["totalQuestions"],
        correctAnswers: json["correctAnswers"],
        wrongAnswers: json["wrongAnswers"],
        score: json["score"],
        accuracy: json["accuracy"]?.toDouble(),
        totalTimeSpent: json["totalTimeSpent"],
        completedAt: json["completedAt"] == null ? null : DateTime.parse(json["completedAt"]),
        status: json["status"],
        rank: json["rank"],
        improvement: json["improvement"] == null ? null : Improvement.fromJson(json["improvement"]),
    );

    Map<String, dynamic> toJson() => {
        "attemptId": attemptId,
        "totalQuestions": totalQuestions,
        "correctAnswers": correctAnswers,
        "wrongAnswers": wrongAnswers,
        "score": score,
        "accuracy": accuracy,
        "totalTimeSpent": totalTimeSpent,
        "completedAt": completedAt?.toIso8601String(),
        "status": status,
        "rank": rank,
        "improvement": improvement?.toJson(),
    };

    // Helper methods
    String get formattedAccuracy => '${(accuracy ?? 0.0).toStringAsFixed(1)}%';
    String get formattedTimeSpent {
        final time = totalTimeSpent ?? 0;
        final minutes = time ~/ 60;
        final seconds = time % 60;
        return '${minutes}m ${seconds}s';
    }
}

class Improvement {
    int? previousScore;
    int? scoreDifference;
    bool? isImprovement;

    Improvement({
        this.previousScore,
        this.scoreDifference,
        this.isImprovement,
    });

    factory Improvement.fromJson(Map<String, dynamic> json) => Improvement(
        previousScore: json["previousScore"],
        scoreDifference: json["scoreDifference"],
        isImprovement: json["isImprovement"],
    );

    Map<String, dynamic> toJson() => {
        "previousScore": previousScore,
        "scoreDifference": scoreDifference,
        "isImprovement": isImprovement,
    };
}
