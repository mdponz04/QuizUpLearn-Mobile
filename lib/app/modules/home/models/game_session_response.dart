class GameSessionResponse {
  final bool success;
  final GameSessionData? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  GameSessionResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory GameSessionResponse.fromJson(Map<String, dynamic> json) {
    return GameSessionResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? GameSessionData.fromJson(json['data'])
          : null,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'error': error,
      'errorType': errorType,
    };
  }
}

class GameSessionData {
  final String gamePin;
  final String gameSessionId;
  final String? hostUserId;
  final String? hostUserName;
  final String? quizSetId;
  final String? quizSetTitle;
  final String status; // Lobby, InProgress, Ended, Cancelled
  final int totalPlayers;
  final List<PlayerInfo>? players;
  final int? totalQuestions;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  GameSessionData({
    required this.gamePin,
    required this.gameSessionId,
    this.hostUserId,
    this.hostUserName,
    this.quizSetId,
    this.quizSetTitle,
    required this.status,
    required this.totalPlayers,
    this.players,
    this.totalQuestions,
    this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  factory GameSessionData.fromJson(Map<String, dynamic> json) {
    return GameSessionData(
      gamePin: json['gamePin'] ?? json['GamePin'] ?? '',
      gameSessionId: json['gameSessionId'] ?? json['GameSessionId'] ?? '',
      hostUserId: json['hostUserId'] ?? json['HostUserId'],
      hostUserName: json['hostUserName'] ?? json['HostUserName'],
      quizSetId: json['quizSetId'] ?? json['QuizSetId'],
      quizSetTitle: json['quizSetTitle'] ?? json['QuizSetTitle'],
      status: json['status'] ?? json['Status'] ?? 'Lobby',
      totalPlayers: json['totalPlayers'] ?? json['TotalPlayers'] ?? 0,
      players: json['players'] != null || json['Players'] != null
          ? (json['players'] ?? json['Players'] as List)
              .map((p) => PlayerInfo.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
      totalQuestions: json['totalQuestions'] ?? json['TotalQuestions'],
      createdAt: json['createdAt'] != null || json['CreatedAt'] != null
          ? DateTime.parse(json['createdAt'] ?? json['CreatedAt'])
          : null,
      startedAt: json['startedAt'] != null || json['StartedAt'] != null
          ? DateTime.parse(json['startedAt'] ?? json['StartedAt'])
          : null,
      endedAt: json['endedAt'] != null || json['EndedAt'] != null
          ? DateTime.parse(json['endedAt'] ?? json['EndedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gamePin': gamePin,
      'gameSessionId': gameSessionId,
      'hostUserId': hostUserId,
      'hostUserName': hostUserName,
      'quizSetId': quizSetId,
      'quizSetTitle': quizSetTitle,
      'status': status,
      'totalPlayers': totalPlayers,
      'players': players?.map((p) => p.toJson()).toList(),
      'totalQuestions': totalQuestions,
      'createdAt': createdAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
  }
}

class PlayerInfo {
  final String playerId;
  final String playerName;
  final DateTime? joinedAt;

  PlayerInfo({
    required this.playerId,
    required this.playerName,
    this.joinedAt,
  });

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    return PlayerInfo(
      playerId: json['playerId'] ?? json['PlayerId'] ?? '',
      playerName: json['playerName'] ?? json['PlayerName'] ?? '',
      joinedAt: json['joinedAt'] != null || json['JoinedAt'] != null
          ? DateTime.parse(json['joinedAt'] ?? json['JoinedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }
}

