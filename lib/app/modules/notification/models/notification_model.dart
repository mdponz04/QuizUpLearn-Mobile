class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? actionUrl;
  final String? imageUrl;
  final dynamic metadata;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.actionUrl,
    this.imageUrl,
    this.metadata,
    this.scheduledAt,
    this.expiresAt,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      actionUrl: json['actionUrl'],
      imageUrl: json['imageUrl'],
      metadata: json['metadata'],
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
      'metadata': metadata,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
