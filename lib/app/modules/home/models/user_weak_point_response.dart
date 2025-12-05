import 'user_weak_point_model.dart';

class UserWeakPointResponse {
  final bool success;
  final List<UserWeakPointModel>? data;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  UserWeakPointResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory UserWeakPointResponse.fromJson(Map<String, dynamic> json) {
    return UserWeakPointResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => UserWeakPointModel.fromJson(item))
          .toList(),
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
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

