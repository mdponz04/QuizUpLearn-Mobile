import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import '../models/user_notification_model.dart';
import '../data/notification_api.dart';
import '../data/notification_service.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class NotificationController extends GetxController {
  late NotificationService notificationService;
  
  var notifications = <UserNotificationModel>[].obs;
  var isLoading = false.obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    loadNotifications();
  }

  void _initializeService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    notificationService = NotificationService(
      notificationApi: NotificationApi(dio, baseUrl: baseUrl),
    );
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final response = await notificationService.getUserNotifications();
      
      if (response.isSuccess && response.data != null) {
        notifications.value = response.data!;
        _updateUnreadCount();
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('Error loading notifications: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải thông báo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await notificationService.markAsRead(notificationId);
      
      if (response.isSuccess) {
        // Update local notification list
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          notifications.refresh();
          _updateUnreadCount();
        }
      }
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await notificationService.markAllAsRead();
      
      if (response.isSuccess) {
        // Update all notifications to read
        notifications.value = notifications.map((n) {
          return n.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }).toList();
        notifications.refresh();
        _updateUnreadCount();
        
        Get.snackbar(
          'Thành công',
          'Đã đánh dấu tất cả là đã đọc',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('Error marking all as read: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể đánh dấu tất cả',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  void onNotificationTap(UserNotificationModel notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      markAsRead(notification.id);
    }
    
    // Handle action based on notification type or actionUrl
    if (notification.notification.actionUrl != null) {
      // Navigate to specific URL/route if needed
      // Get.toNamed(notification.notification.actionUrl!);
    }
  }

  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
