import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/event_controller.dart';
import '../models/event_model.dart';

class EventTabWidget extends StatelessWidget {
  const EventTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventController());
    
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Sự kiện",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshEvents,
            color: ColorsManager.primary,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }
        
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(context, controller.errorMessage.value);
        }
        
        if (controller.events.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildEventList(context, controller.events);
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ColorsManager.primary,
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.subTile2(
            context,
            text: "Đang tải sự kiện...",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: UtilsReponsive.height(64, context),
              color: Colors.red[300],
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.titleH3(
              context,
              text: "Có lỗi xảy ra",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: error,
              color: Colors.grey[600]!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: UtilsReponsive.height(24, context)),
            ElevatedButton.icon(
              onPressed: () => Get.find<EventController>().refreshEvents(),
              icon: const Icon(Icons.refresh),
              label: const Text("Thử lại"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: UtilsReponsive.height(80, context),
            color: Colors.grey[400],
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.titleH3(
            context,
            text: "Chưa có sự kiện",
            color: Colors.grey[600]!,
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextConstant.subTile2(
            context,
            text: "Hiện tại không có sự kiện nào",
            color: Colors.grey[500]!,
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(BuildContext context, List<EventModel> events) {
    return RefreshIndicator(
      onRefresh: () async {
        await Get.find<EventController>().loadEvents();
      },
      color: ColorsManager.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return _buildEventCard(context, events[index]);
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = _getStatusColor(event.status);
    final statusText = _getStatusText(event.status);
    
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed('/event-detail', arguments: event.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.name,
                        style: GoogleFonts.montserratAlternates(
                          fontSize: UtilsReponsive.height(16, context),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(12, context),
                        vertical: UtilsReponsive.height(6, context),
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor,
                          width: 1,
                        ),
                      ),
                      child: TextConstant.subTile3(
                        context,
                        text: statusText,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        size: 11,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(8, context)),
                
                // Quiz Set Title
                Row(
                  children: [
                    Icon(
                      Icons.quiz,
                      size: UtilsReponsive.height(16, context),
                      color: ColorsManager.primary,
                    ),
                    SizedBox(width: UtilsReponsive.width(6, context)),
                    Expanded(
                      child: Text(
                        event.quizSetTitle,
                        style: GoogleFonts.montserratAlternates(
                          fontSize: UtilsReponsive.height(14, context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700]!,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                if (event.description.isNotEmpty) ...[
                  SizedBox(height: UtilsReponsive.height(8, context)),
                  Text(
                    event.description,
                    style: GoogleFonts.montserratAlternates(
                      fontSize: UtilsReponsive.height(14, context),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600]!,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                SizedBox(height: UtilsReponsive.height(12, context)),
                
                // Date and time info
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: UtilsReponsive.height(14, context),
                      color: Colors.grey[600]!,
                    ),
                    SizedBox(width: UtilsReponsive.width(6, context)),
                    TextConstant.subTile3(
                      context,
                      text: "Bắt đầu: ${dateFormat.format(event.startDate)}",
                      color: Colors.grey[600]!,
                      size: 12,
                    ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(4, context)),
                
                Row(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: UtilsReponsive.height(14, context),
                      color: Colors.grey[600]!,
                    ),
                    SizedBox(width: UtilsReponsive.width(6, context)),
                    TextConstant.subTile3(
                      context,
                      text: "Kết thúc: ${dateFormat.format(event.endDate)}",
                      color: Colors.grey[600]!,
                      size: 12,
                    ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(12, context)),
                
                // Participants info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: UtilsReponsive.height(14, context),
                          color: Colors.grey[600]!,
                        ),
                        SizedBox(width: UtilsReponsive.width(6, context)),
                        TextConstant.subTile3(
                          context,
                          text: "${event.currentParticipants}/${event.maxParticipants} người tham gia",
                          color: Colors.grey[600]!,
                          size: 12,
                        ),
                      ],
                    ),
                    if (event.isFull)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(8, context),
                          vertical: UtilsReponsive.height(4, context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextConstant.subTile3(
                          context,
                          text: "Đã đầy",
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          size: 11,
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(8, context)),
                
                // Creator info
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: UtilsReponsive.height(14, context),
                      color: Colors.grey[500]!,
                    ),
                    SizedBox(width: UtilsReponsive.width(6, context)),
                    TextConstant.subTile3(
                      context,
                      text: "Người tạo: ${event.creatorName}",
                      color: Colors.grey[500]!,
                      size: 11,
                    ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(12, context)),
                
                // Detail Button
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/event-detail', arguments: event.id);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: UtilsReponsive.height(10, context),
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextConstant.subTile2(
                          context,
                          text: "Chi tiết",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(width: UtilsReponsive.width(6, context)),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: UtilsReponsive.height(16, context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'ended':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'ended':
        return 'Đã kết thúc';
      default:
        return status;
    }
  }
}

