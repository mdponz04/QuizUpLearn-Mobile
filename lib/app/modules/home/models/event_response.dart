import 'event_model.dart';

class EventResponse {
  final bool success;
  final List<EventModel>? data;
  final String? message;
  final String? error;
  final String? errorType;

  EventResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => EventModel.fromJson(item))
              .toList()
          : null,
      message: json['message']?.toString(),
      error: json['error']?.toString(),
      errorType: json['errorType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((item) => item.toJson()).toList(),
      'message': message,
      'error': error,
      'errorType': errorType,
    };
  }
}

