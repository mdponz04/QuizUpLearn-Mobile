class AnswerOptionModel {
  final String id;
  final String optionLabel;
  final String optionText;
  final int orderIndex;

  AnswerOptionModel({
    required this.id,
    required this.optionLabel,
    required this.optionText,
    required this.orderIndex,
  });

  factory AnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return AnswerOptionModel(
      id: json['id'],
      optionLabel: json['optionLabel'],
      optionText: json['optionText'],
      orderIndex: json['orderIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'optionLabel': optionLabel,
      'optionText': optionText,
      'orderIndex': orderIndex,
    };
  }
}
