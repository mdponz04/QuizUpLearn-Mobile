class CreateQuizSetCommentRequest {
  final String userId;
  final String quizSetId;
  final String content;

  CreateQuizSetCommentRequest({
    required this.userId,
    required this.quizSetId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'quizSetId': quizSetId,
      'content': content,
    };
  }
}

