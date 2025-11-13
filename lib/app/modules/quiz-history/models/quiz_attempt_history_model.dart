class QuizAttemptHistoryModel {
  final String id;
  final String userId;
  final String quizSetId;
  final String attemptType;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int score;
  final double accuracy;
  final int? timeSpent;
  final String? opponentId;
  final bool? isWinner;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  QuizAttemptHistoryModel({
    required this.id,
    required this.userId,
    required this.quizSetId,
    required this.attemptType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.score,
    required this.accuracy,
    this.timeSpent,
    this.opponentId,
    this.isWinner,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory QuizAttemptHistoryModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptHistoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      quizSetId: json['quizSetId'] ?? '',
      attemptType: json['attemptType'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      wrongAnswers: json['wrongAnswers'] ?? 0,
      score: json['score'] ?? 0,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      timeSpent: json['timeSpent'],
      opponentId: json['opponentId'],
      isWinner: json['isWinner'],
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'quizSetId': quizSetId,
      'attemptType': attemptType,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'score': score,
      'accuracy': accuracy,
      'timeSpent': timeSpent,
      'opponentId': opponentId,
      'isWinner': isWinner,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

class QuizAttemptHistoryResponse {
  final bool success;
  final List<QuizAttemptHistoryModel>? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  QuizAttemptHistoryResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory QuizAttemptHistoryResponse.fromJson(Map<String, dynamic> json) {
    return QuizAttemptHistoryResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => QuizAttemptHistoryModel.fromJson(item))
              .toList()
          : null,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
    );
  }
}

