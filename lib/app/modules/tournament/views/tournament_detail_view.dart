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
    
    return _ExpandableRankingItem(
      ranking: ranking,
      isTopThree: isTopThree,
      dateFormat: dateFormat,
      context: context,
    );
  }
}

class _ExpandableRankingItem extends StatefulWidget {
  final TournamentLeaderboardRanking ranking;
  final bool isTopThree;
  final DateFormat dateFormat;
  final BuildContext context;

  const _ExpandableRankingItem({
    required this.ranking,
    required this.isTopThree,
    required this.dateFormat,
    required this.context,
  });

  @override
  State<_ExpandableRankingItem> createState() => _ExpandableRankingItemState();
}

class _ExpandableRankingItemState extends State<_ExpandableRankingItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      decoration: BoxDecoration(
        color: widget.isTopThree ? Colors.amber.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: widget.isTopThree
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
      child: Column(
        children: [
          // Main Content
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              child: Row(
                children: [
                  // Rank Badge
                  Container(
                    width: UtilsReponsive.width(50, context),
                    height: UtilsReponsive.width(50, context),
                    decoration: BoxDecoration(
                      color: widget.isTopThree ? Colors.amber.shade400 : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${widget.ranking.rank}",
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
                          widget.ranking.displayName,
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
                              "${widget.ranking.totalScore} điểm",
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
                                widget.dateFormat.format(widget.ranking.joinDate),
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
                  
                  // Expand Icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Content - Daily Scores
          if (_isExpanded && widget.ranking.dailyScores.isNotEmpty)
            _buildDailyScoresSection(context),
        ],
      ),
    );
  }

  Widget _buildDailyScoresSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                size: UtilsReponsive.height(18, context),
                color: ColorsManager.primary,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              TextConstant.subTile1(
                context,
                text: "Điểm theo ngày",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Daily Scores Chart
          _buildDailyScoresChart(context),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Daily Scores List
          _buildDailyScoresList(context),
        ],
      ),
    );
  }

  Widget _buildDailyScoresChart(BuildContext context) {
    if (widget.ranking.dailyScores.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final maxScore = widget.ranking.dailyScores
        .map((e) => e.cumulativeScore)
        .reduce((a, b) => a > b ? a : b);
    final maxHeight = UtilsReponsive.height(120, context);
    
    return Container(
      height: UtilsReponsive.height(150, context),
      padding: EdgeInsets.symmetric(
        vertical: UtilsReponsive.height(8, context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.ranking.dailyScores.map((dailyScore) {
          final percentage = maxScore > 0 
              ? (dailyScore.cumulativeScore / maxScore) 
              : 0.0;
          final barHeight = percentage * maxHeight;
          final dayFormat = DateFormat('dd/MM');
          
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(2, context),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bar Chart
                  Container(
                    height: barHeight > 0 
                        ? barHeight.clamp(4.0, maxHeight) 
                        : UtilsReponsive.height(4, context),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ColorsManager.primary,
                          ColorsManager.primary.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: UtilsReponsive.height(4, context)),
                  
                  // Day Label
                  TextConstant.subTile4(
                    context,
                    text: dayFormat.format(dailyScore.date),
                    color: Colors.grey[600]!,
                    size: 9,
                  ),
                  
                  SizedBox(height: UtilsReponsive.height(2, context)),
                  
                  // Score Label
                  TextConstant.subTile4(
                    context,
                    text: "${dailyScore.dayScore}",
                    color: ColorsManager.primary,
                    fontWeight: FontWeight.bold,
                    size: 10,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDailyScoresList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextConstant.subTile2(
          context,
          text: "Chi tiết điểm",
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: UtilsReponsive.height(8, context)),
        ...widget.ranking.dailyScores.map((dailyScore) {
          final dayFormat = DateFormat('dd/MM/yyyy');
          return Container(
            margin: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConstant.subTile3(
                        context,
                        text: dayFormat.format(dailyScore.date),
                        color: Colors.grey[700]!,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: UtilsReponsive.height(4, context)),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: UtilsReponsive.height(14, context),
                            color: Colors.green,
                          ),
                          SizedBox(width: UtilsReponsive.width(4, context)),
                          TextConstant.subTile4(
                            context,
                            text: "Điểm ngày: ${dailyScore.dayScore}",
                            color: Colors.grey[600]!,
                            size: 11,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(12, context),
                    vertical: UtilsReponsive.height(6, context),
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: UtilsReponsive.height(14, context),
                        color: ColorsManager.primary,
                      ),
                      SizedBox(width: UtilsReponsive.width(4, context)),
                      TextConstant.subTile3(
                        context,
                        text: "Tích lũy: ${dailyScore.cumulativeScore}",
                        color: ColorsManager.primary,
                        fontWeight: FontWeight.bold,
                        size: 11,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

