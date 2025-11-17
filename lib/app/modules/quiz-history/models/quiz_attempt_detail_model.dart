class QuizAttemptDetailModel {
  final String id;
  final String attemptId;
  final String questionId;
  final String userAnswer;
  final bool isCorrect;
  final int timeSpent;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  QuizAttemptDetailModel({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.timeSpent,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory QuizAttemptDetailModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptDetailModel(
      id: json['id'] ?? '',
      attemptId: json['attemptId'] ?? '',
      questionId: json['questionId'] ?? '',
      userAnswer: json['userAnswer'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      timeSpent: json['timeSpent'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attemptId': attemptId,
      'questionId': questionId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

class QuizAttemptDetailResponse {
  final bool success;
  final List<QuizAttemptDetailModel>? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  QuizAttemptDetailResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory QuizAttemptDetailResponse.fromJson(Map<String, dynamic> json) {
    return QuizAttemptDetailResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => QuizAttemptDetailModel.fromJson(item))
              .toList()
          : null,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
    );
  }
}

