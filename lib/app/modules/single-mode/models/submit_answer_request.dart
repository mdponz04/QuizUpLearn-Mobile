class SubmitAnswerRequest {
  final String attemptId;
  final String questionId;
  final String userAnswer;
  final int timeSpent;

  SubmitAnswerRequest({
    required this.attemptId,
    required this.questionId,
    required this.userAnswer,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'attemptId': attemptId,
      'questionId': questionId,
      'userAnswer': userAnswer,
      'timeSpent': timeSpent,
    };
  }
}
