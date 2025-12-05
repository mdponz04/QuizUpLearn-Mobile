class DashboardResponse {
  final bool success;
  final DashboardData? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  DashboardResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
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

class DashboardData {
  final DashboardStats stats;
  final DashboardProgress progress;
  final List<dynamic> recentActivities;
  final List<dynamic> eventParticipations;
  final List<dynamic> recentQuizHistory;
  final List<dynamic> weakPoints;
  final DateTime lastUpdated;

  DashboardData({
    required this.stats,
    required this.progress,
    required this.recentActivities,
    required this.eventParticipations,
    required this.recentQuizHistory,
    required this.weakPoints,
    required this.lastUpdated,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      stats: DashboardStats.fromJson(json['stats'] ?? {}),
      progress: DashboardProgress.fromJson(json['progress'] ?? {}),
      recentActivities: json['recentActivities'] as List<dynamic>? ?? [],
      eventParticipations: json['eventParticipations'] as List<dynamic>? ?? [],
      recentQuizHistory: json['recentQuizHistory'] as List<dynamic>? ?? [],
      weakPoints: json['weakPoints'] as List<dynamic>? ?? [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'progress': progress.toJson(),
      'recentActivities': recentActivities,
      'eventParticipations': eventParticipations,
      'recentQuizHistory': recentQuizHistory,
      'weakPoints': weakPoints,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class DashboardStats {
  final int totalQuizzes;
  final double accuracyRate;
  final int currentStreak;
  final int currentRank;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;
  final int totalQuestions;

  DashboardStats({
    required this.totalQuizzes,
    required this.accuracyRate,
    required this.currentStreak,
    required this.currentRank,
    required this.totalCorrectAnswers,
    required this.totalWrongAnswers,
    required this.totalQuestions,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalQuizzes: json['totalQuizzes'] ?? 0,
      accuracyRate: (json['accuracyRate'] ?? 0).toDouble(),
      currentStreak: json['currentStreak'] ?? 0,
      currentRank: json['currentRank'] ?? 1,
      totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
      totalWrongAnswers: json['totalWrongAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuizzes': totalQuizzes,
      'accuracyRate': accuracyRate,
      'currentStreak': currentStreak,
      'currentRank': currentRank,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalWrongAnswers': totalWrongAnswers,
      'totalQuestions': totalQuestions,
    };
  }
}

class DashboardProgress {
  final List<WeeklyProgress> weeklyProgress;
  final double overallAccuracy;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;
  final int totalQuestions;

  DashboardProgress({
    required this.weeklyProgress,
    required this.overallAccuracy,
    required this.totalCorrectAnswers,
    required this.totalWrongAnswers,
    required this.totalQuestions,
  });

  factory DashboardProgress.fromJson(Map<String, dynamic> json) {
    return DashboardProgress(
      weeklyProgress: (json['weeklyProgress'] as List<dynamic>?)
              ?.map((item) => WeeklyProgress.fromJson(item))
              .toList() ??
          [],
      overallAccuracy: (json['overallAccuracy'] ?? 0).toDouble(),
      totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
      totalWrongAnswers: json['totalWrongAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyProgress': weeklyProgress.map((item) => item.toJson()).toList(),
      'overallAccuracy': overallAccuracy,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalWrongAnswers': totalWrongAnswers,
      'totalQuestions': totalQuestions,
    };
  }
}

class WeeklyProgress {
  final String day;
  final double scorePercentage;
  final DateTime date;

  WeeklyProgress({
    required this.day,
    required this.scorePercentage,
    required this.date,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      day: json['day']?.toString() ?? '',
      scorePercentage: (json['scorePercentage'] ?? 0).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'scorePercentage': scorePercentage,
      'date': date.toIso8601String(),
    };
  }
}

