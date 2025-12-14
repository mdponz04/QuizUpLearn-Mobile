import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/event_detail_controller.dart';
import '../models/event_leaderboard_model.dart';

class EventDetailView extends GetView<EventDetailController> {
  const EventDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Chi tiết Sự kiện",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshLeaderboard,
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
        
        if (controller.leaderboardData.value == null) {
          return _buildEmptyState(context);
        }
        
        return _buildLeaderboardContent(context, controller.leaderboardData.value!);
      }),
      bottomNavigationBar: Obx(() {
        if (controller.leaderboardData.value == null) {
          return const SizedBox.shrink();
        }
        final data = controller.leaderboardData.value!;
        final isEventActive = data.eventStatus.toLowerCase() == 'ongoing' || 
                             data.eventStatus.toLowerCase() == 'upcoming' ||
                             data.eventStatus.toLowerCase() == 'active';
        
        // Nếu chưa join và event đang active -> hiển thị nút đăng ký
        if (isEventActive && !controller.isJoined.value) {
          return _buildJoinButtonBottomBar(context, data);
        } 
        // Nếu đã join và event đang ongoing/active -> hiển thị nút tham gia
        else if (controller.isJoined.value && 
                 (data.eventStatus.toLowerCase() == 'ongoing' ||
                  data.eventStatus.toLowerCase() == 'active')) {
          return _buildJoinGameButtonBottomBar(context, data);
        } 
        // Nếu đã join nhưng event chưa bắt đầu hoặc đã kết thúc -> hiển thị trạng thái
        else if (controller.isJoined.value) {
          return _buildJoinedStatusBottomBar(context);
        }
        return const SizedBox.shrink();
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
            text: "Đang tải bảng xếp hạng...",
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
              onPressed: controller.refreshLeaderboard,
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
            Icons.leaderboard_outlined,
            size: UtilsReponsive.height(80, context),
            color: Colors.grey[400],
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.titleH3(
            context,
            text: "Không có dữ liệu",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardContent(BuildContext context, EventLeaderboardData data) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshLeaderboard();
      },
      color: ColorsManager.primary,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Info Card
            _buildEventInfoCard(context, data, dateFormat),
            
            SizedBox(height: UtilsReponsive.height(24, context)),
            
            // Top Player Section
            if (data.topPlayer != null) ...[
              TextConstant.titleH3(
                context,
                text: "Người chiến thắng",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: UtilsReponsive.height(12, context)),
              _buildTopPlayerCard(context, data.topPlayer!),
              SizedBox(height: UtilsReponsive.height(24, context)),
            ],
            
            // Leaderboard Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextConstant.titleH3(
                  context,
                  text: "Bảng xếp hạng",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(12, context),
                    vertical: UtilsReponsive.height(6, context),
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextConstant.subTile3(
                    context,
                    text: "${data.totalParticipants} người tham gia",
                    color: ColorsManager.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(16, context)),
            
            // Leaderboard List
            if (data.rankings.isEmpty)
              _buildEmptyLeaderboard(context)
            else
              _buildLeaderboardList(context, data.rankings),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfoCard(BuildContext context, EventLeaderboardData data, DateFormat dateFormat) {
    final statusText = _getStatusText(data.eventStatus);
    
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primary,
            ColorsManager.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.eventName,
                  style: GoogleFonts.montserratAlternates(
                    fontSize: UtilsReponsive.height(20, context),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.montserratAlternates(
                    fontSize: UtilsReponsive.height(12, context),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: UtilsReponsive.height(16, context),
                color: Colors.white70,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Expanded(
                child: Text(
                  "Bắt đầu: ${dateFormat.format(data.eventStartDate)}",
                  style: GoogleFonts.montserratAlternates(
                    fontSize: UtilsReponsive.height(13, context),
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(8, context)),
          
          Row(
            children: [
              Icon(
                Icons.event_available,
                size: UtilsReponsive.height(16, context),
                color: Colors.white70,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Expanded(
                child: Text(
                  "Kết thúc: ${dateFormat.format(data.eventEndDate)}",
                  style: GoogleFonts.montserratAlternates(
                    fontSize: UtilsReponsive.height(13, context),
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlayerCard(BuildContext context, EventLeaderboardRanking topPlayer) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Badge
          Container(
            width: UtilsReponsive.width(60, context),
            height: UtilsReponsive.width(60, context),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                topPlayer.badge,
                style: TextStyle(
                  fontSize: UtilsReponsive.height(32, context),
                ),
              ),
            ),
          ),
          
          SizedBox(width: UtilsReponsive.width(16, context)),
          
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topPlayer.participantName.isEmpty 
                      ? "Người chơi ${topPlayer.rank}" 
                      : topPlayer.participantName,
                  style: GoogleFonts.montserratAlternates(
                    fontSize: UtilsReponsive.height(18, context),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(4, context)),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: UtilsReponsive.height(16, context),
                      color: Colors.white70,
                    ),
                    SizedBox(width: UtilsReponsive.width(4, context)),
                    Text(
                      "Điểm: ${topPlayer.score}",
                      style: GoogleFonts.montserratAlternates(
                        fontSize: UtilsReponsive.height(14, context),
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: UtilsReponsive.width(12, context)),
                    Icon(
                      Icons.check_circle,
                      size: UtilsReponsive.height(16, context),
                      color: Colors.white70,
                    ),
                    SizedBox(width: UtilsReponsive.width(4, context)),
                    Text(
                      "${topPlayer.accuracy.toStringAsFixed(1)}%",
                      style: GoogleFonts.montserratAlternates(
                        fontSize: UtilsReponsive.height(14, context),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(BuildContext context, List<EventLeaderboardRanking> rankings) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        return _buildRankingItem(context, rankings[index], index);
      },
    );
  }

  Widget _buildRankingItem(BuildContext context, EventLeaderboardRanking ranking, int index) {
    final isTopThree = ranking.isTopThree;
    
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: isTopThree ? Colors.amber.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isTopThree
            ? Border.all(color: Colors.amber.shade300, width: 2)
            : Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: UtilsReponsive.width(40, context),
            height: UtilsReponsive.width(40, context),
            decoration: BoxDecoration(
              color: isTopThree ? Colors.amber.shade400 : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTopThree
                  ? Text(
                      ranking.badge,
                      style: TextStyle(
                        fontSize: UtilsReponsive.height(20, context),
                      ),
                    )
                  : Text(
                      "${ranking.rank}",
                      style: GoogleFonts.montserratAlternates(
                        fontSize: UtilsReponsive.height(16, context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          
          SizedBox(width: UtilsReponsive.width(12, context)),
          
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.participantName.isEmpty 
                      ? "Người chơi ${ranking.rank}" 
                      : ranking.participantName,
                  style: GoogleFonts.montserratAlternates(
                    fontSize: UtilsReponsive.height(16, context),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(4, context)),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: UtilsReponsive.height(14, context),
                      color: Colors.orange,
                    ),
                    SizedBox(width: UtilsReponsive.width(4, context)),
                    Text(
                      "${ranking.score} điểm",
                      style: GoogleFonts.montserratAlternates(
                        fontSize: UtilsReponsive.height(13, context),
                        color: Colors.grey[700]!,
                      ),
                    ),
                    SizedBox(width: UtilsReponsive.width(12, context)),
                    Icon(
                      Icons.check_circle,
                      size: UtilsReponsive.height(14, context),
                      color: Colors.green,
                    ),
                    SizedBox(width: UtilsReponsive.width(4, context)),
                    Text(
                      "${ranking.accuracy.toStringAsFixed(1)}%",
                      style: GoogleFonts.montserratAlternates(
                        fontSize: UtilsReponsive.height(13, context),
                        color: Colors.grey[700]!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLeaderboard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(32, context)),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: UtilsReponsive.height(64, context),
              color: Colors.grey[400],
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.subTile2(
              context,
              text: "Chưa có người tham gia",
              color: Colors.grey[600]!,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ongoing':
      case 'active':
        return 'Đang diễn ra';
      case 'ended':
      case 'completed':
        return 'Đã kết thúc';
      default:
        return status;
    }
  }


  Future<void> _handleJoinEvent(BuildContext context) async {
    final success = await controller.joinEvent();
    
    if (context.mounted) {
      if (success) {
        Get.snackbar(
          'Thành công',
          'Đăng ký tham gia sự kiện thành công!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: EdgeInsets.all(UtilsReponsive.width(16, context)),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Lỗi',
          controller.errorMessage.value.isNotEmpty 
              ? controller.errorMessage.value 
              : 'Không thể đăng ký tham gia. Vui lòng thử lại.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(UtilsReponsive.width(16, context)),
          borderRadius: 12,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    }
  }

  Widget _buildJoinButtonBottomBar(BuildContext context, EventLeaderboardData data) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.isJoining.value ? null : () => _handleJoinEvent(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: UtilsReponsive.height(14, context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: controller.isJoining.value
                ? SizedBox(
                    width: UtilsReponsive.height(20, context),
                    height: UtilsReponsive.height(20, context),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.how_to_reg,
                    size: UtilsReponsive.height(20, context),
                  ),
            label: TextConstant.subTile2(
              context,
              text: controller.isJoining.value 
                  ? "Đang đăng ký..." 
                  : "Đăng ký tham gia",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildJoinedStatusBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: UtilsReponsive.height(14, context),
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: UtilsReponsive.height(20, context),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              TextConstant.subTile2(
                context,
                text: "Đã tham gia sự kiện",
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinGameButtonBottomBar(BuildContext context, EventLeaderboardData data) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleJoinGame(context, data),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: UtilsReponsive.height(14, context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: Icon(
              Icons.play_arrow,
              size: UtilsReponsive.height(20, context),
            ),
            label: TextConstant.subTile2(
              context,
              text: "Tham gia",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _handleJoinGame(BuildContext context, EventLeaderboardData data) {
    // Hiển thị dialog nhập PIN giống như luồng multiplayer (quản trò) ở home
    _showEnterPinDialog(context);
  }

  void _showEnterPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    final playerNameController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
          constraints: BoxConstraints(
            maxWidth: UtilsReponsive.width(400, context),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.videogame_asset,
                      color: ColorsManager.primary,
                      size: UtilsReponsive.height(28, context),
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    Expanded(
                      child: TextConstant.titleH2(
                        context,
                        text: "Tham gia Game",
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: UtilsReponsive.height(20, context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Game PIN Field
                TextConstant.subTile1(
                  context,
                  text: "Mã PIN",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextField(
                  controller: pinController,
                  decoration: InputDecoration(
                    hintText: "Nhập mã PIN",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.key, color: ColorsManager.primary),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Player Name Field
                TextConstant.subTile1(
                  context,
                  text: "Tên người chơi",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextField(
                  controller: playerNameController,
                  decoration: InputDecoration(
                    hintText: "Nhập tên người chơi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person, color: ColorsManager.primary),
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: UtilsReponsive.height(12, context),
                          ),
                        ),
                        child: TextConstant.subTile2(
                          context,
                          text: "Hủy",
                          color: Colors.grey[600]!,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: UtilsReponsive.width(12, context)),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          final pin = pinController.text.trim();
                          final playerName = playerNameController.text.trim();
                          if (pin.isNotEmpty && playerName.isNotEmpty) {
                            Get.back();
                            _joinGameWithPin(pin, playerName);
                          } else {
                            Get.snackbar(
                              'Lỗi',
                              'Vui lòng nhập đầy đủ thông tin',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: UtilsReponsive.height(12, context),
                          ),
                        ),
                        child: TextConstant.subTile2(
                          context,
                          text: "Tham gia",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _joinGameWithPin(String pin, String playerName) {
    // Navigate đến player-game-room với gamePin và playerName
    // Giống như luồng multiplayer (quản trò) ở home
    Get.toNamed('/player-game-room', arguments: {
      'gamePin': pin,
      'playerName': playerName,
      'mode': 'pin',
      'baseUrl': 'https://qul-api.onrender.com',
    });
  }
}

