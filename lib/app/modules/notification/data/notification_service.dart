import 'dart:developer';
import '../models/user_notification_model.dart';
import 'notification_api.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? data;

  ApiResponse({
    required this.isSuccess,
    required this.message,
    this.data,
  });
}

class NotificationService {
  final NotificationApi notificationApi;

  NotificationService({required this.notificationApi});

  Future<ApiResponse<List<UserNotificationModel>>> getUserNotifications() async {
    try {
      final response = await notificationApi.getUserNotifications();
      
      if (response.success && response.data != null) {
        return ApiResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data,
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: response.message ?? 'Failed to get notifications',
        );
      }
    } catch (e) {
      log('Error in getUserNotifications: $e');
      return ApiResponse(
        isSuccess: false,
        message: 'An error occurred: $e',
      );
    }
  }

  Future<ApiResponse<bool>> markAsRead(String notificationId) async {
    try {
      final response = await notificationApi.markAsRead(notificationId);
      
      return ApiResponse(
        isSuccess: response.success,
        message: response.success ? 'Marked as read' : (response.message ?? 'Failed'),
        data: response.success,
      );
    } catch (e) {
      log('Error in markAsRead: $e');
      return ApiResponse(
        isSuccess: false,
        message: 'An error occurred: $e',
        data: false,
      );
    }
  }

  Future<ApiResponse<bool>> markAllAsRead() async {
    try {
      final response = await notificationApi.markAllAsRead();
      
      return ApiResponse(
        isSuccess: response.success,
        message: response.success ? 'All marked as read' : (response.message ?? 'Failed'),
        data: response.success,
      );
    } catch (e) {
      log('Error in markAllAsRead: $e');
      return ApiResponse(
        isSuccess: false,
        message: 'An error occurred: $e',
        data: false,
      );
    }
  }
}
