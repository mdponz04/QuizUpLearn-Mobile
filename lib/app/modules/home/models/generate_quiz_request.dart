class GenerateQuizRequest {
  final int questionQuantity;
  final String difficulty;
  final String topic;
  final String creatorId;

  GenerateQuizRequest({
    required this.questionQuantity,
    required this.difficulty,
    required this.topic,
    required this.creatorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionQuantity': questionQuantity,
      'difficulty': '80-100',
      'topic': topic,
      'creatorId': creatorId,
    };
  }
}

