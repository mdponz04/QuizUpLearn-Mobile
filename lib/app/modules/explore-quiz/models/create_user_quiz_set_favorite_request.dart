class CreateUserQuizSetFavoriteRequest {
  final String userId;
  final String quizSetId;

  CreateUserQuizSetFavoriteRequest({
    required this.userId,
    required this.quizSetId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'quizSetId': quizSetId,
    };
  }
}

