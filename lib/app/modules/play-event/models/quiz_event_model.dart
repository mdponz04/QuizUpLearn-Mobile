class QuizEventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final QuizEventType type;
  final QuizEventStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final int maxParticipants;
  final int currentParticipants;
  final int duration; // in minutes
  final int totalQuestions;
  final String difficulty;
  final List<String> topics;
  final int entryFee; // points required to join
  final int rewardPoints;
  final String hostName;
  final String hostAvatar;
  final bool isJoined;
  final DateTime? joinedAt;

  QuizEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.duration,
    required this.totalQuestions,
    required this.difficulty,
    required this.topics,
    required this.entryFee,
    required this.rewardPoints,
    required this.hostName,
    required this.hostAvatar,
    this.isJoined = false,
    this.joinedAt,
  });

  factory QuizEventModel.fromJson(Map<String, dynamic> json) {
    return QuizEventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      type: QuizEventType.values.firstWhere((e) => e.name == json['type']),
      status: QuizEventStatus.values.firstWhere((e) => e.name == json['status']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      maxParticipants: json['maxParticipants'],
      currentParticipants: json['currentParticipants'],
      duration: json['duration'],
      totalQuestions: json['totalQuestions'],
      difficulty: json['difficulty'],
      topics: List<String>.from(json['topics']),
      entryFee: json['entryFee'],
      rewardPoints: json['rewardPoints'],
      hostName: json['hostName'],
      hostAvatar: json['hostAvatar'],
      isJoined: json['isJoined'] ?? false,
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'duration': duration,
      'totalQuestions': totalQuestions,
      'difficulty': difficulty,
      'topics': topics,
      'entryFee': entryFee,
      'rewardPoints': rewardPoints,
      'hostName': hostName,
      'hostAvatar': hostAvatar,
      'isJoined': isJoined,
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }

  // Helper methods
  bool get isUpcoming => status == QuizEventStatus.upcoming;
  bool get isOngoing => status == QuizEventStatus.ongoing;
  bool get isCompleted => status == QuizEventStatus.completed;
  
  String get timeRemaining {
    final now = DateTime.now();
    if (isUpcoming) {
      final diff = startTime.difference(now);
      if (diff.inDays > 0) {
        return '${diff.inDays}d ${diff.inHours % 24}h';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ${diff.inMinutes % 60}m';
      } else {
        return '${diff.inMinutes}m';
      }
    } else if (isOngoing) {
      final diff = endTime.difference(now);
      if (diff.inDays > 0) {
        return '${diff.inDays}d ${diff.inHours % 24}h left';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ${diff.inMinutes % 60}m left';
      } else {
        return '${diff.inMinutes}m left';
      }
    }
    return 'Completed';
  }

  String get participantsText {
    return '$currentParticipants/$maxParticipants';
  }

  double get participantsProgress {
    return currentParticipants / maxParticipants;
  }
}

enum QuizEventType {
  solo,
  oneOnOne,
  group,
  multiplayerSolo,
}

enum QuizEventStatus {
  upcoming,
  ongoing,
  completed,
}

extension QuizEventTypeExtension on QuizEventType {
  String get displayName {
    switch (this) {
      case QuizEventType.solo:
        return 'Solo Quiz';
      case QuizEventType.oneOnOne:
        return '1v1 Battle';
      case QuizEventType.group:
        return 'Group Challenge';
      case QuizEventType.multiplayerSolo:
        return 'Multiplayer Solo';
    }
  }

  String get description {
    switch (this) {
      case QuizEventType.solo:
        return 'Practice alone and improve your skills';
      case QuizEventType.oneOnOne:
        return 'Challenge another player in a head-to-head battle';
      case QuizEventType.group:
        return 'Join a team and compete together';
      case QuizEventType.multiplayerSolo:
        return 'Play solo but compete with others in the same session';
    }
  }

  String get icon {
    switch (this) {
      case QuizEventType.solo:
        return 'assets/images/practice.png';
      case QuizEventType.oneOnOne:
        return 'assets/images/do_quiz.png';
      case QuizEventType.group:
        return 'assets/images/vocabulary.png';
      case QuizEventType.multiplayerSolo:
        return 'assets/images/progress.png';
    }
  }

  String get color {
    switch (this) {
      case QuizEventType.solo:
        return '#22C55E'; // Green
      case QuizEventType.oneOnOne:
        return '#EF4444'; // Red
      case QuizEventType.group:
        return '#3B82F6'; // Blue
      case QuizEventType.multiplayerSolo:
        return '#8B5CF6'; // Purple
    }
  }
}

extension QuizEventStatusExtension on QuizEventStatus {
  String get displayName {
    switch (this) {
      case QuizEventStatus.upcoming:
        return 'Upcoming';
      case QuizEventStatus.ongoing:
        return 'Ongoing';
      case QuizEventStatus.completed:
        return 'Completed';
    }
  }

  String get color {
    switch (this) {
      case QuizEventStatus.upcoming:
        return '#F59E0B'; // Amber
      case QuizEventStatus.ongoing:
        return '#22C55E'; // Green
      case QuizEventStatus.completed:
        return '#6B7280'; // Gray
    }
  }
}
