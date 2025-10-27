import 'package:quizkahoot/app/modules/single-mode/models/answer_option_model.dart';

class QuizQuestionModel {
  final String id;
  final String questionText;
  final String audioUrl;
  final String imageUrl;
  final String toeicPart;
  final int orderIndex;
  final List<AnswerOptionModel> answerOptions;

  QuizQuestionModel({
    required this.id,
    required this.questionText,
    required this.audioUrl,
    required this.imageUrl,
    required this.toeicPart,
    required this.orderIndex,
    required this.answerOptions,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'],
      questionText: json['questionText'],
      audioUrl: json['audioUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      toeicPart: json['toeicPart'] ?? '',
      orderIndex: json['orderIndex'],
      answerOptions: (json['answerOptions'] as List)
          .map((item) => AnswerOptionModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'toeicPart': toeicPart,
      'orderIndex': orderIndex,
      'answerOptions': answerOptions.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods
  bool get hasAudio => audioUrl.isNotEmpty;
  bool get hasImage => imageUrl.isNotEmpty;
}
