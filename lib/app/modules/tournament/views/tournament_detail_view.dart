import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/tournament_detail_controller.dart';
import '../models/tournament_leaderboard_model.dart';

class TournamentDetailView extends GetView<TournamentDetailController> {
  const TournamentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Chi tiết Giải đấu",
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
        
        if (controller.leaderboard.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildLeaderboardContent(context);
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
            text: "Chưa có dữ liệu",
            color: Colors.grey[600]!,
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextConstant.subTile2(
            context,
            text: "Chưa có người tham gia trong bảng xếp hạng",
            color: Colors.grey[500]!,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshLeaderboard();
      },
      color: ColorsManager.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        itemCount: controller.leaderboard.length,
        itemBuilder: (context, index) {
          return _buildRankingItem(context, controller.leaderboard[index], index);
        },
      ),
    );
  }

  Widget _buildRankingItem(BuildContext context, TournamentLeaderboardRanking ranking, int index) {
    final isTopThree = ranking.rank <= 3;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
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
            width: UtilsReponsive.width(50, context),
            height: UtilsReponsive.width(50, context),
            decoration: BoxDecoration(
              color: isTopThree ? Colors.amber.shade400 : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${ranking.rank}",
                style: GoogleFonts.montserratAlternates(
                  fontSize: UtilsReponsive.height(18, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                  ranking.displayName,
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
                      Icons.calendar_today,
                      size: UtilsReponsive.height(14, context),
                      color: Colors.grey[600]!,
                    ),
                    SizedBox(width: UtilsReponsive.width(4, context)),
                    Expanded(
                      child: Text(
                        dateFormat.format(ranking.date),
                        style: GoogleFonts.montserratAlternates(
                          fontSize: UtilsReponsive.height(12, context),
                          color: Colors.grey[600]!,
                        ),
                        overflow: TextOverflow.ellipsis,
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
}

