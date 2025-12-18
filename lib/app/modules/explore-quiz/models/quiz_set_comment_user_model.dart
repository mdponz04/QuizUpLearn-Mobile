class QuizSetCommentUserModel {
  final String id;
  final String accountId;
  final String username;
  final String fullName;
  final String avatarUrl;
  final String? bio;
  final int loginStreak;
  final DateTime? lastLoginDate;
  final int totalPoints;
  final String? preferredLanguage;
  final String? timezone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  QuizSetCommentUserModel({
    required this.id,
    required this.accountId,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    this.bio,
    required this.loginStreak,
    this.lastLoginDate,
    required this.totalPoints,
    this.preferredLanguage,
    this.timezone,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory QuizSetCommentUserModel.fromJson(Map<String, dynamic> json) {
    return QuizSetCommentUserModel(
      id: json['id']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      bio: json['bio']?.toString(),
      loginStreak: json['loginStreak'] ?? 0,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'].toString())
          : null,
      totalPoints: json['totalPoints'] ?? 0,
      preferredLanguage: json['preferredLanguage']?.toString(),
      timezone: json['timezone']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'username': username,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'loginStreak': loginStreak,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'totalPoints': totalPoints,
      'preferredLanguage': preferredLanguage,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

