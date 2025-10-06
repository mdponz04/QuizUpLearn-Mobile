class MatchingModel {
  final String id;
  final String name;
  final String avatar;
  final int level;
  final int rating;
  final String country;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<String> languages;
  final int totalMatches;
  final int wins;
  final int losses;
  final double winRate;
  final String preferredDifficulty;
  final List<String> interests;

  MatchingModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.level,
    required this.rating,
    required this.country,
    this.isOnline = false,
    this.lastSeen,
    required this.languages,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.preferredDifficulty,
    required this.interests,
  });

  factory MatchingModel.fromJson(Map<String, dynamic> json) {
    return MatchingModel(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      level: json['level'],
      rating: json['rating'],
      country: json['country'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      languages: List<String>.from(json['languages']),
      totalMatches: json['totalMatches'],
      wins: json['wins'],
      losses: json['losses'],
      winRate: json['winRate'].toDouble(),
      preferredDifficulty: json['preferredDifficulty'],
      interests: List<String>.from(json['interests']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'level': level,
      'rating': rating,
      'country': country,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'languages': languages,
      'totalMatches': totalMatches,
      'losses': losses,
      'winRate': winRate,
      'preferredDifficulty': preferredDifficulty,
      'interests': interests,
    };
  }

  String get statusText {
    if (isOnline) {
      return 'Online';
    } else if (lastSeen != null) {
      final now = DateTime.now();
      final diff = now.difference(lastSeen!);
      if (diff.inMinutes < 1) {
        return 'Just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${diff.inDays}d ago';
      }
    }
    return 'Offline';
  }

  String get winRateText {
    return '${(winRate * 100).toStringAsFixed(1)}%';
  }

  String get levelText {
    return 'Level $level';
  }
}

class MatchingSessionModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final MatchingType type;
  final MatchingStatus status;
  final List<MatchingModel> participants;
  final DateTime createdAt;
  final DateTime? matchedAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int maxParticipants;
  final String difficulty;
  final int totalQuestions;
  final int duration; // in minutes

  MatchingSessionModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.type,
    required this.status,
    required this.participants,
    required this.createdAt,
    this.matchedAt,
    this.startedAt,
    this.endedAt,
    required this.maxParticipants,
    required this.difficulty,
    required this.totalQuestions,
    required this.duration,
  });

  bool get isWaiting => status == MatchingStatus.waiting;
  bool get isMatched => status == MatchingStatus.matched;
  bool get isStarting => status == MatchingStatus.starting;
  bool get isInProgress => status == MatchingStatus.inProgress;
  bool get isCompleted => status == MatchingStatus.completed;

  String get statusText {
    switch (status) {
      case MatchingStatus.waiting:
        return 'Finding opponents...';
      case MatchingStatus.matched:
        return 'Matched! Starting soon...';
      case MatchingStatus.starting:
        return 'Starting quiz...';
      case MatchingStatus.inProgress:
        return 'Quiz in progress';
      case MatchingStatus.completed:
        return 'Quiz completed';
    }
  }

  int get currentParticipants => participants.length;
  int get remainingSlots => maxParticipants - currentParticipants;
  bool get isFull => currentParticipants >= maxParticipants;
}

enum MatchingType {
  oneOnOne,
  group,
  multiplayerSolo,
}

enum MatchingStatus {
  waiting,
  matched,
  starting,
  inProgress,
  completed,
}

extension MatchingTypeExtension on MatchingType {
  String get displayName {
    switch (this) {
      case MatchingType.oneOnOne:
        return '1v1 Battle';
      case MatchingType.group:
        return 'Group Challenge';
      case MatchingType.multiplayerSolo:
        return 'Multiplayer Solo';
    }
  }

  String get description {
    switch (this) {
      case MatchingType.oneOnOne:
        return 'Find an opponent for a head-to-head battle';
      case MatchingType.group:
        return 'Join a team and compete together';
      case MatchingType.multiplayerSolo:
        return 'Join a large session with 25 players';
    }
  }

  String get icon {
    switch (this) {
      case MatchingType.oneOnOne:
        return 'assets/images/do_quiz.png';
      case MatchingType.group:
        return 'assets/images/vocabulary.png';
      case MatchingType.multiplayerSolo:
        return 'assets/images/progress.png';
    }
  }

  String get color {
    switch (this) {
      case MatchingType.oneOnOne:
        return '#EF4444'; // Red
      case MatchingType.group:
        return '#3B82F6'; // Blue
      case MatchingType.multiplayerSolo:
        return '#8B5CF6'; // Purple
    }
  }
}

extension MatchingStatusExtension on MatchingStatus {
  String get displayName {
    switch (this) {
      case MatchingStatus.waiting:
        return 'Waiting';
      case MatchingStatus.matched:
        return 'Matched';
      case MatchingStatus.starting:
        return 'Starting';
      case MatchingStatus.inProgress:
        return 'In Progress';
      case MatchingStatus.completed:
        return 'Completed';
    }
  }

  String get color {
    switch (this) {
      case MatchingStatus.waiting:
        return '#F59E0B'; // Amber
      case MatchingStatus.matched:
        return '#22C55E'; // Green
      case MatchingStatus.starting:
        return '#3B82F6'; // Blue
      case MatchingStatus.inProgress:
        return '#8B5CF6'; // Purple
      case MatchingStatus.completed:
        return '#6B7280'; // Gray
    }
  }
}
