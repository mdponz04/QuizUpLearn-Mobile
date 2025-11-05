class CreateGameRequest {
  final String hostUserId;
  final String hostUserName;
  final String quizSetId;

  CreateGameRequest({
    required this.hostUserId,
    required this.hostUserName,
    required this.quizSetId,
  });

  Map<String, dynamic> toJson() {
    return {
      'hostUserId': hostUserId,
      'hostUserName': hostUserName,
      'quizSetId': quizSetId,
    };
  }
}

