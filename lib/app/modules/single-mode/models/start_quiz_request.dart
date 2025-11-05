class StartQuizRequest {
  final String quizSetId;
  final String userId;

  StartQuizRequest({
    required this.quizSetId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'quizSetId': quizSetId,
      'userId': userId,
      'numQuestions': 1,
    };
  }
}
