class QuizReportRequest {
  final String userId;
  final String quizId;
  final String description;

  QuizReportRequest({
    required this.userId,
    required this.quizId,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'quizId': quizId,
      'description': description,
    };
  }
}

