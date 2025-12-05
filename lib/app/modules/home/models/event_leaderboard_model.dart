class EventLeaderboardRanking {
  final int rank;
  final String participantId;
  final String participantName;
  final String avatarUrl;
  final int score;
  final double accuracy;
  final DateTime joinAt;
  final DateTime? finishAt;
  final bool isTopThree;
  final String badge;

  EventLeaderboardRanking({
    required this.rank,
    required this.participantId,
    required this.participantName,
    required this.avatarUrl,
    required this.score,
    required this.accuracy,
    required this.joinAt,
    this.finishAt,
    required this.isTopThree,
    required this.badge,
  });

  factory EventLeaderboardRanking.fromJson(Map<String, dynamic> json) {
    return EventLeaderboardRanking(
      rank: json['rank'] ?? 0,
      participantId: json['participantId']?.toString() ?? '',
      participantName: json['participantName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      score: json['score'] ?? 0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      joinAt: json['joinAt'] != null
          ? DateTime.parse(json['joinAt'].toString())
          : DateTime.now(),
      finishAt: json['finishAt'] != null
          ? DateTime.parse(json['finishAt'].toString())
          : null,
      isTopThree: json['isTopThree'] ?? false,
      badge: json['badge']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'participantId': participantId,
      'participantName': participantName,
      'avatarUrl': avatarUrl,
      'score': score,
      'accuracy': accuracy,
      'joinAt': joinAt.toIso8601String(),
      'finishAt': finishAt?.toIso8601String(),
      'isTopThree': isTopThree,
      'badge': badge,
    };
  }
}

class EventLeaderboardData {
  final String eventId;
  final String eventName;
  final String eventStatus;
  final int totalParticipants;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final List<EventLeaderboardRanking> rankings;
  final EventLeaderboardRanking? topPlayer;
  final DateTime generatedAt;

  EventLeaderboardData({
    required this.eventId,
    required this.eventName,
    required this.eventStatus,
    required this.totalParticipants,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.rankings,
    this.topPlayer,
    required this.generatedAt,
  });

  factory EventLeaderboardData.fromJson(Map<String, dynamic> json) {
    return EventLeaderboardData(
      eventId: json['eventId']?.toString() ?? '',
      eventName: json['eventName']?.toString() ?? '',
      eventStatus: json['eventStatus']?.toString() ?? '',
      totalParticipants: json['totalParticipants'] ?? 0,
      eventStartDate: json['eventStartDate'] != null
          ? DateTime.parse(json['eventStartDate'].toString())
          : DateTime.now(),
      eventEndDate: json['eventEndDate'] != null
          ? DateTime.parse(json['eventEndDate'].toString())
          : DateTime.now(),
      rankings: (json['rankings'] as List?)
              ?.map((item) => EventLeaderboardRanking.fromJson(item))
              .toList() ??
          [],
      topPlayer: json['topPlayer'] != null
          ? EventLeaderboardRanking.fromJson(json['topPlayer'])
          : null,
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'eventStatus': eventStatus,
      'totalParticipants': totalParticipants,
      'eventStartDate': eventStartDate.toIso8601String(),
      'eventEndDate': eventEndDate.toIso8601String(),
      'rankings': rankings.map((item) => item.toJson()).toList(),
      'topPlayer': topPlayer?.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

class EventLeaderboardResponse {
  final bool success;
  final EventLeaderboardData? data;
  final String? message;
  final String? error;
  final String? errorType;

  EventLeaderboardResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory EventLeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return EventLeaderboardResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? EventLeaderboardData.fromJson(json['data'])
          : null,
      message: json['message']?.toString(),
      error: json['error']?.toString(),
      errorType: json['errorType']?.toString(),
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

