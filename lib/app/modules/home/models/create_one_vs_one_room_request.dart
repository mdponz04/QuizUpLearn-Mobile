class CreateOneVsOneRoomRequest {
  final String player1Name;
  final String quizSetId;
  final String player1UserId;

  CreateOneVsOneRoomRequest({
    required this.player1Name,
    required this.quizSetId,
    required this.player1UserId,
  });

  Map<String, dynamic> toJson() {
    return {
      'player1Name': player1Name,
      'quizSetId': quizSetId,
      'player1UserId': player1UserId,
    };
  }
}

