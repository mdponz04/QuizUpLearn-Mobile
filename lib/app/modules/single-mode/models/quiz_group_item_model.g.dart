// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_group_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizGroupItemResponse _$QuizGroupItemResponseFromJson(
  Map<String, dynamic> json,
) => QuizGroupItemResponse(
  success: json['success'] as bool,
  data:
      json['data'] == null
          ? null
          : QuizGroupItemData.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
  error: json['error'] as String?,
  errorType: json['errorType'] as String?,
);

Map<String, dynamic> _$QuizGroupItemResponseToJson(
  QuizGroupItemResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
  'error': instance.error,
  'errorType': instance.errorType,
};

QuizGroupItemData _$QuizGroupItemDataFromJson(Map<String, dynamic> json) =>
    QuizGroupItemData(
      id: json['id'] as String,
      name: json['name'] as String,
      audioUrl: json['audioUrl'] as String,
      imageUrl: json['imageUrl'] as String,
      audioScript: json['audioScript'] as String?,
      imageDescription: json['imageDescription'] as String,
      passageText: json['passageText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      quizzes: json['quizzes'] as List<dynamic>,
    );

Map<String, dynamic> _$QuizGroupItemDataToJson(QuizGroupItemData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'audioUrl': instance.audioUrl,
      'imageUrl': instance.imageUrl,
      'audioScript': instance.audioScript,
      'imageDescription': instance.imageDescription,
      'passageText': instance.passageText,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'quizzes': instance.quizzes,
    };
