class DailyScore {
  final DateTime date;
  final int dayScore;
  final int cumulativeScore;

  DailyScore({
    required this.date,
    required this.dayScore,
    required this.cumulativeScore,
  });

  factory DailyScore.fromJson(Map<String, dynamic> json) {
    return DailyScore(
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      dayScore: json['dayScore'] ?? 0,
      cumulativeScore: json['cumulativeScore'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'dayScore': dayScore,
      'cumulativeScore': cumulativeScore,
    };
  }
}

class TournamentLeaderboardRanking {
  final int rank;
  final String userId;
  final String username;
  final String fullName;
  final String avatarUrl;
  final int totalScore;
  final DateTime joinDate;
  final List<DailyScore> dailyScores;

  TournamentLeaderboardRanking({
    required this.rank,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.totalScore,
    required this.joinDate,
    required this.dailyScores,
  });

  factory TournamentLeaderboardRanking.fromJson(Map<String, dynamic> json) {
    return TournamentLeaderboardRanking(
      rank: json['rank'] ?? 0,
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      totalScore: json['totalScore'] ?? 0,
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'].toString())
          : DateTime.now(),
      dailyScores: json['dailyScores'] != null
          ? (json['dailyScores'] as List)
              .map((item) => DailyScore.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'totalScore': totalScore,
      'joinDate': joinDate.toIso8601String(),
      'dailyScores': dailyScores.map((item) => item.toJson()).toList(),
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

