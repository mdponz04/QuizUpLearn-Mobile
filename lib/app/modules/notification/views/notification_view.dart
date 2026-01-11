import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/notification_controller.dart';
import '../models/user_notification_model.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Thông báo",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ColorsManager.primary,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return IconButton(
                onPressed: controller.markAllAsRead,
                icon: Icon(
                  Icons.done_all,
                  color: ColorsManager.primary,
                ),
                tooltip: 'Đánh dấu tất cả là đã đọc',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorsManager.primary,
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          color: ColorsManager.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _buildNotificationCard(context, notification);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: UtilsReponsive.height(80, context),
            color: Colors.grey[400],
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.titleH3(
            context,
            text: "Chưa có thông báo",
            color: Colors.grey[600]!,
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextConstant.subTile2(
            context,
            text: "Bạn sẽ nhận được thông báo về các sự kiện và hoạt động",
            color: Colors.grey[500]!,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    UserNotificationModel notification,
  ) {
    final isUnread = !notification.isRead;
    
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      decoration: BoxDecoration(
        color: isUnread ? ColorsManager.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread 
              ? ColorsManager.primary.withOpacity(0.2)
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.onNotificationTap(notification),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(UtilsReponsive.width(10, context)),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.notification.type),
                    color: _getNotificationColor(notification.notification.type),
                    size: UtilsReponsive.height(24, context),
                  ),
                ),
                
                SizedBox(width: UtilsReponsive.width(12, context)),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextConstant.titleH3(
                              context,
                              text: notification.notification.title,
                              color: Colors.black,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              size: 16,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: UtilsReponsive.width(8, context),
                              height: UtilsReponsive.width(8, context),
                              decoration: BoxDecoration(
                                color: ColorsManager.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: UtilsReponsive.height(6, context)),
                      
                      TextConstant.subTile2(
                        context,
                        text: notification.notification.message,
                        color: Colors.grey[700]!,
                        size: 13,
                      ),
                      
                      SizedBox(height: UtilsReponsive.height(8, context)),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: UtilsReponsive.height(14, context),
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: UtilsReponsive.width(4, context)),
                          TextConstant.subTile3(
                            context,
                            text: controller.formatTimeAgo(notification.createdAt),
                            color: Colors.grey[500]!,
                            size: 11,
                          ),
                          
                          SizedBox(width: UtilsReponsive.width(12, context)),
                          
                          // Type badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification.notification.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextConstant.subTile4(
                              context,
                              text: notification.notification.type,
                              color: _getNotificationColor(notification.notification.type),
                              fontWeight: FontWeight.w600,
                              size: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return Icons.event;
      case 'quiz':
        return Icons.quiz;
      case 'achievement':
        return Icons.emoji_events;
      case 'reminder':
        return Icons.notifications;
      case 'update':
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return Colors.purple;
      case 'quiz':
        return Colors.blue;
      case 'achievement':
        return Colors.amber;
      case 'reminder':
        return Colors.orange;
      case 'update':
        return Colors.green;
      default:
        return ColorsManager.primary;
    }
  }
}
