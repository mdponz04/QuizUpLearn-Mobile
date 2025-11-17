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
      id: json['id']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      optionLabel: json['optionLabel']?.toString() ?? '',
      optionText: json['optionText']?.toString() ?? '',
      orderIndex: json['orderIndex'] ?? 0,
      isCorrect: json['isCorrect'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'].toString())
          : DateTime.now(),
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
