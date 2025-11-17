import 'package:flutter/material.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_model.dart';

class QuizSetModel {
  final String id;
  final String title;
  final String description;
  final int quizType;
  final String toeicPart;
  final String skillType;
  final String difficultyLevel;
  final int totalQuestions;
  final int timeLimit;
  final String createdBy;
  final String? creatorUsername;
  final bool isAIGenerated;
  final bool isPublished;
  final bool isPremiumOnly;
  final int totalAttempts;
  final double averageScore;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<QuizModel> quizzes;

  QuizSetModel({
    required this.id,
    required this.title,
    required this.description,
    required this.quizType,
    required this.toeicPart,
    required this.skillType,
    required this.difficultyLevel,
    required this.totalQuestions,
    required this.timeLimit,
    required this.createdBy,
    this.creatorUsername,
    required this.isAIGenerated,
    required this.isPublished,
    required this.isPremiumOnly,
    required this.totalAttempts,
    required this.averageScore,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.quizzes,
  });

  factory QuizSetModel.fromJson(Map<String, dynamic> json) {
    return QuizSetModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      quizType: json['quizType'] ?? 0,
      toeicPart: json['toeicPart']?.toString() ?? '',
      skillType: json['skillType']?.toString() ?? '',
      difficultyLevel: json['difficultyLevel']?.toString() ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      timeLimit: json['timeLimit'] ?? 0,
      createdBy: json['createdBy']?.toString() ?? '',
      creatorUsername: json['creatorUsername']?.toString(),
      isAIGenerated: json['isAIGenerated'] ?? false,
      isPublished: json['isPublished'] ?? false,
      isPremiumOnly: json['isPremiumOnly'] ?? false,
      totalAttempts: json['totalAttempts'] ?? 0,
      averageScore: json['averageScore']?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString()) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'].toString()) : null,
      quizzes: (json['quizzes'] as List?)
          ?.map((item) => QuizModel.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'quizType': quizType,
      'toeicPart': toeicPart,
      'skillType': skillType,
      'difficultyLevel': difficultyLevel,
      'totalQuestions': totalQuestions,
      'timeLimit': timeLimit,
      'createdBy': createdBy,
      'creatorUsername': creatorUsername,
      'isAIGenerated': isAIGenerated,
      'isPublished': isPublished,
      'isPremiumOnly': isPremiumOnly,
      'totalAttempts': totalAttempts,
      'averageScore': averageScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'quizzes': quizzes.map((item) => item.toJson()).toList(),
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

  String get difficultyColor {
    switch (difficultyLevel.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return 'Medium';
    }
  }

  Color get difficultyColorValue {
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

  String get quizTypeIcon {
    switch (quizType) {
      case 1:
        return '🎧';
      case 2:
        return '📚';
      case 3:
        return '🌍';
      case 4:
        return '📝';
      default:
        return '📖';
    }
  }

  // Additional helper methods
  List<QuizModel> get activeQuizzes => quizzes.where((quiz) => quiz.isActive).toList();
  
  
  
  
  double get averageAccuracy {
    if (quizzes.isEmpty) return 0.0;
    final totalAccuracy = quizzes.fold(0.0, (sum, quiz) => sum + quiz.accuracyRate);
    return totalAccuracy / quizzes.length;
  }
  
  List<String> get availableToeicParts {
    return quizzes
        .map((quiz) => quiz.toeicPart)
        .where((part) => part.isNotEmpty)
        .toSet()
        .toList();
  }
}

