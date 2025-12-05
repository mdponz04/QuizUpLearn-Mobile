class EventModel {
  final String id;
  final String quizSetId;
  final String quizSetTitle;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final int currentParticipants;
  final String status; // "Ended", "Upcoming", "Ongoing", etc.
  final String createdBy;
  final String creatorName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.quizSetId,
    required this.quizSetTitle,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.status,
    required this.createdBy,
    required this.creatorName,
    required this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      quizSetId: json['quizSetId']?.toString() ?? '',
      quizSetTitle: json['quizSetTitle']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : DateTime.now(),
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      status: json['status']?.toString() ?? '',
      createdBy: json['createdBy']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? 'Unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizSetId': quizSetId,
      'quizSetTitle': quizSetTitle,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'status': status,
      'createdBy': createdBy,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper getters
  bool get isEnded => status.toLowerCase() == 'ended';
  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  bool get isOngoing => status.toLowerCase() == 'ongoing';
  
  int get remainingParticipants => maxParticipants - currentParticipants;
  bool get isFull => currentParticipants >= maxParticipants;
}

