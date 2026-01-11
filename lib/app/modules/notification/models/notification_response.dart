import 'package:json_annotation/json_annotation.dart';
import 'user_notification_model.dart';

part 'notification_response.g.dart';

@JsonSerializable()
class NotificationResponse {
  final bool success;
  final List<UserNotificationModel>? data;
  final String? message;
  final String? error;
  final String? errorType;

  NotificationResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}

@JsonSerializable()
class MarkAsReadResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final String? error;
  final String? errorType;

  MarkAsReadResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory MarkAsReadResponse.fromJson(Map<String, dynamic> json) =>
      _$MarkAsReadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MarkAsReadResponseToJson(this);
}
