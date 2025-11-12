class SubmitAllAnswersRequest {
  final String attemptId;
  final List<AnswerDetail> answers;

  SubmitAllAnswersRequest({
    required this.attemptId,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'attemptId': attemptId,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class AnswerDetail {
  final String questionId;
  final String userAnswer;
  final int timeSpent;

  AnswerDetail({
    required this.questionId,
    required this.userAnswer,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'userAnswer': userAnswer,
      'timeSpent': timeSpent,
    };
  }
}

