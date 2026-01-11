import 'notification_model.dart';

class UserNotificationModel {
  final String id;
  final String userId;
  final String notificationId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final NotificationModel notification;

  UserNotificationModel({
    required this.id,
    required this.userId,
    required this.notificationId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.notification,
  });

  factory UserNotificationModel.fromJson(Map<String, dynamic> json) {
    return UserNotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      notificationId: json['notificationId'] ?? '',
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      notification: NotificationModel.fromJson(json['notification'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'notificationId': notificationId,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'notification': notification.toJson(),
    };
  }

  // Tạo bản sao với các trường được cập nhật
  UserNotificationModel copyWith({
    String? id,
    String? userId,
    String? notificationId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    NotificationModel? notification,
  }) {
    return UserNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationId: notificationId ?? this.notificationId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      notification: notification ?? this.notification,
    );
  }
}
