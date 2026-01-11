// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponse _$NotificationResponseFromJson(
  Map<String, dynamic> json,
) => NotificationResponse(
  success: json['success'] as bool,
  data:
      (json['data'] as List<dynamic>?)
          ?.map(
            (e) => UserNotificationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  message: json['message'] as String?,
  error: json['error'] as String?,
  errorType: json['errorType'] as String?,
);

Map<String, dynamic> _$NotificationResponseToJson(
  NotificationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
  'error': instance.error,
  'errorType': instance.errorType,
};

MarkAsReadResponse _$MarkAsReadResponseFromJson(Map<String, dynamic> json) =>
    MarkAsReadResponse(
      success: json['success'] as bool,
      data: json['data'],
      message: json['message'] as String?,
      error: json['error'] as String?,
      errorType: json['errorType'] as String?,
    );

Map<String, dynamic> _$MarkAsReadResponseToJson(MarkAsReadResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'message': instance.message,
      'error': instance.error,
      'errorType': instance.errorType,
    };
