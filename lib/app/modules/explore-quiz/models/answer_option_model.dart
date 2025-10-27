class AnswerOptionModel {
  final String id;
  final String quizId;
  final String optionLabel;
  final String optionText;
  final int orderIndex;
  final bool isCorrect;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime deletedAt;

  AnswerOptionModel({
    required this.id,
    required this.quizId,
    required this.optionLabel,
    required this.optionText,
    required this.orderIndex,
    required this.isCorrect,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory AnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return AnswerOptionModel(
      id: json['id'],
      quizId: json['quizId'],
      optionLabel: json['optionLabel'],
      optionText: json['optionText'],
      orderIndex: json['orderIndex'],
      isCorrect: json['isCorrect'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: DateTime.parse(json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'optionLabel': optionLabel,
      'optionText': optionText,
      'orderIndex': orderIndex,
      'isCorrect': isCorrect,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt.toIso8601String(),
    };
  }
}
