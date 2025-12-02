class UserSubscriptionModel {
  final String id;
  final String userId;
  final String subscriptionPlanId;
  final int aiGenerateQuizSetRemaining;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.subscriptionPlanId,
    required this.aiGenerateQuizSetRemaining,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subscriptionPlanId: json['subscriptionPlanId'] as String,
      aiGenerateQuizSetRemaining: json['aiGenerateQuizSetRemaining'] as int,
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionPlanId': subscriptionPlanId,
      'aiGenerateQuizSetRemaining': aiGenerateQuizSetRemaining,
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  // Check if subscription is still active
  bool get isActive {
    return endDate.isAfter(DateTime.now());
  }

  // Format end date for display
  String get formattedEndDate {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return "$years year${years > 1 ? 's' : ''} remaining";
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return "$months month${months > 1 ? 's' : ''} remaining";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} remaining";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} remaining";
    } else {
      return "Expires soon";
    }
  }

  // Format end date as date string
  String get formattedEndDateString {
    return "${endDate.day}/${endDate.month}/${endDate.year}";
  }
}

class UserSubscriptionResponse {
  final bool success;
  final UserSubscriptionModel? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  UserSubscriptionResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory UserSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionResponse(
      success: json['success'] as bool,
      data: json['data'] != null 
          ? UserSubscriptionModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'error': error,
      'errorType': errorType,
    };
  }
}

