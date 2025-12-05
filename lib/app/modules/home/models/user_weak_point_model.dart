import 'package:flutter/material.dart';

class UserWeakPointModel {
  final String id;
  final String userId;
  final String userMistakeId;
  final String weakPoint;
  final String toeicPart;
  final String difficultyLevel;
  final String advice;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final dynamic userMistakeDto;

  UserWeakPointModel({
    required this.id,
    required this.userId,
    required this.userMistakeId,
    required this.weakPoint,
    required this.toeicPart,
    required this.difficultyLevel,
    required this.advice,
    required this.createdAt,
    this.updatedAt,
    this.userMistakeDto,
  });

  factory UserWeakPointModel.fromJson(Map<String, dynamic> json) {
    return UserWeakPointModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userMistakeId: json['userMistakeId']?.toString() ?? '',
      weakPoint: json['weakPoint']?.toString() ?? '',
      toeicPart: json['toeicPart']?.toString() ?? '',
      difficultyLevel: json['difficultyLevel']?.toString() ?? '',
      advice: json['advice']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      userMistakeDto: json['userMistakeDto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userMistakeId': userMistakeId,
      'weakPoint': weakPoint,
      'toeicPart': toeicPart,
      'difficultyLevel': difficultyLevel,
      'advice': advice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userMistakeDto': userMistakeDto,
    };
  }

  Color get difficultyColor {
    switch (difficultyLevel.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

