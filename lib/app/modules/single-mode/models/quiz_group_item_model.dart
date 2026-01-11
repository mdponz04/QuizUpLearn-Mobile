import 'package:json_annotation/json_annotation.dart';

part 'quiz_group_item_model.g.dart';

@JsonSerializable()
class QuizGroupItemResponse {
  final bool success;
  final QuizGroupItemData? data;
  final String? message;
  final String? error;
  final String? errorType;

  QuizGroupItemResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory QuizGroupItemResponse.fromJson(Map<String, dynamic> json) =>
      _$QuizGroupItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuizGroupItemResponseToJson(this);
}

@JsonSerializable()
class QuizGroupItemData {
  final String id;
  final String name;
  final String audioUrl;
  final String imageUrl;
  final String? audioScript;
  final String imageDescription;
  final String passageText;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<dynamic> quizzes;

  QuizGroupItemData({
    required this.id,
    required this.name,
    required this.audioUrl,
    required this.imageUrl,
    this.audioScript,
    required this.imageDescription,
    required this.passageText,
    required this.createdAt,
    this.updatedAt,
    required this.quizzes,
  });

  factory QuizGroupItemData.fromJson(Map<String, dynamic> json) =>
      _$QuizGroupItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$QuizGroupItemDataToJson(this);
}
