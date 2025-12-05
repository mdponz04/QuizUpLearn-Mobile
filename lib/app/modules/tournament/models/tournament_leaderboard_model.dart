class TournamentLeaderboardRanking {
  final int rank;
  final String userId;
  final String username;
  final String fullName;
  final String avatarUrl;
  final int score;
  final DateTime date;

  TournamentLeaderboardRanking({
    required this.rank,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.score,
    required this.date,
  });

  factory TournamentLeaderboardRanking.fromJson(Map<String, dynamic> json) {
    return TournamentLeaderboardRanking(
      rank: json['rank'] ?? 0,
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      score: json['score'] ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'score': score,
      'date': date.toIso8601String(),
    };
  }

  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (username.isNotEmpty) return username;
    return 'Người chơi $rank';
  }
}

class TournamentLeaderboardResponse {
  final bool success;
  final List<TournamentLeaderboardRanking>? data;
  final String? message;
  final String? error;
  final String? errorType;

  TournamentLeaderboardResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory TournamentLeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return TournamentLeaderboardResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => TournamentLeaderboardRanking.fromJson(item))
              .toList()
          : null,
      message: json['message']?.toString(),
      error: json['error']?.toString(),
      errorType: json['errorType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((item) => item.toJson()).toList(),
      'message': message,
      'error': error,
      'errorType': errorType,
    };
  }
}

