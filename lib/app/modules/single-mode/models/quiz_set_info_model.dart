class QuizSetInfoModel {
  final String id;
  final String title;
  final String description;
  final int totalQuestions;
  final int timeLimit;

  QuizSetInfoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.totalQuestions,
    required this.timeLimit,
  });

  factory QuizSetInfoModel.fromJson(Map<String, dynamic> json) {
    return QuizSetInfoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      totalQuestions: json['totalQuestions'],
      timeLimit: json['timeLimit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'totalQuestions': totalQuestions,
      'timeLimit': timeLimit,
    };
  }

  // Helper methods
  String get formattedTimeLimit {
    final hours = timeLimit ~/ 60;
    final minutes = timeLimit % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
