// To parse this JSON data, do
//
//     final startQuizResponse = startQuizResponseFromJson(jsonString);

import 'dart:convert';

StartQuizResponse startQuizResponseFromJson(String str) => StartQuizResponse.fromJson(json.decode(str));

String startQuizResponseToJson(StartQuizResponse data) => json.encode(data.toJson());

class StartQuizResponse {
    bool? success;
    Data? data;
    String? message;
    String? error;
    dynamic errorType;

    StartQuizResponse({
        this.success,
        this.data,
        this.message,
        this.error,
        this.errorType,
    });

    factory StartQuizResponse.fromJson(Map<String, dynamic> json) => StartQuizResponse(
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
    List<Question>? questions;

    Data({
        this.attemptId,
        this.totalQuestions,
        this.questions,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        attemptId: json["attemptId"],
        totalQuestions: json["totalQuestions"],
        questions: json["questions"] == null ? [] : List<Question>.from(json["questions"]!.map((x) => Question.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "attemptId": attemptId,
        "totalQuestions": totalQuestions,
        "questions": questions == null ? [] : List<dynamic>.from(questions!.map((x) => x.toJson())),
    };
}

class Question {
    String? id;
    String? quizSetId;
    String? questionText;
    String? correctAnswer;
    String? audioUrl;
    String? imageUrl;
    String? toeicPart;
    int? timesAnswered;
    int? timesCorrect;
    int? orderIndex;
    bool? isActive;
    DateTime? createdAt;
    dynamic updatedAt;
    dynamic deletedAt;
    List<AnswerOption>? answerOptions;

    Question({
        this.id,
        this.quizSetId,
        this.questionText,
        this.correctAnswer,
        this.audioUrl,
        this.imageUrl,
        this.toeicPart,
        this.timesAnswered,
        this.timesCorrect,
        this.orderIndex,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.answerOptions,
    });

    factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"],
        quizSetId: json["quizSetId"],
        questionText: json["questionText"],
        correctAnswer: json["correctAnswer"],
        audioUrl: json["audioURL"],
        imageUrl: json["imageURL"],
        toeicPart: json["toeicPart"],
        timesAnswered: json["timesAnswered"],
        timesCorrect: json["timesCorrect"],
        orderIndex: json["orderIndex"],
        isActive: json["isActive"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"],
        deletedAt: json["deletedAt"],
        answerOptions: json["answerOptions"] == null ? [] : List<AnswerOption>.from(json["answerOptions"]!.map((x) => AnswerOption.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "quizSetId": quizSetId,
        "questionText": questionText,
        "correctAnswer": correctAnswer,
        "audioURL": audioUrl,
        "imageURL": imageUrl,
        "toeicPart": toeicPart,
        "timesAnswered": timesAnswered,
        "timesCorrect": timesCorrect,
        "orderIndex": orderIndex,
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt,
        "deletedAt": deletedAt,
        "answerOptions": answerOptions == null ? [] : List<dynamic>.from(answerOptions!.map((x) => x.toJson())),
    };
}

class AnswerOption {
    String? id;
    String? quizId;
    OptionLabel? optionLabel;
    String? optionText;
    int? orderIndex;
    bool? isCorrect;
    DateTime? createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    AnswerOption({
        this.id,
        this.quizId,
        this.optionLabel,
        this.optionText,
        this.orderIndex,
        this.isCorrect,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory AnswerOption.fromJson(Map<String, dynamic> json) => AnswerOption(
        id: json["id"],
        quizId: json["quizId"],
        optionLabel: optionLabelValues.map[json["optionLabel"]]!,
        optionText: json["optionText"],
        orderIndex: json["orderIndex"],
        isCorrect: json["isCorrect"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"],
        deletedAt: json["deletedAt"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "quizId": quizId,
        "optionLabel": optionLabelValues.reverse[optionLabel],
        "optionText": optionText,
        "orderIndex": orderIndex,
        "isCorrect": isCorrect,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt,
        "deletedAt": deletedAt,
    };
}

enum OptionLabel {
    A,
    B,
    C,
    D
}

final optionLabelValues = EnumValues({
    "A": OptionLabel.A,
    "B": OptionLabel.B,
    "C": OptionLabel.C,
    "D": OptionLabel.D
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
