class CreateOneVsOneRoomRequest {
  final String player1Name;
  final String quizSetId;
  final String player1UserId;
  final int mode; // 0 = 1vs1, 1 = Multiplayer

  CreateOneVsOneRoomRequest({
    required this.player1Name,
    required this.quizSetId,
    required this.player1UserId,
    this.mode = 0, // Default to 1vs1
  });

  Map<String, dynamic> toJson() {
    return {
      'player1Name': player1Name,
      'quizSetId': quizSetId,
      'player1UserId': player1UserId,
      'mode': mode,
    };
  }
}

