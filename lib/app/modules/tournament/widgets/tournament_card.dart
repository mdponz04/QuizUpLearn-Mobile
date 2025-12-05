import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/tournament_controller.dart';
import '../models/tournament_model.dart';

class TournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  final int index;
  final TournamentController controller;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = tournament.statusColor;
    final status = tournament.status.toLowerCase();
    final shouldCheckJoined = status == 'started';

    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to tournament detail
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Header with Gradient
                Container(
                  padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor,
                        statusColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Trophy Icon
                      Container(
                        padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: UtilsReponsive.height(28, context),
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(16, context)),
                      // Title and Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextConstant.titleH2(
                              context,
                              text: tournament.name,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 20,
                            ),
                            SizedBox(height: UtilsReponsive.height(4, context)),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: UtilsReponsive.height(12, context),
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                SizedBox(width: UtilsReponsive.width(4, context)),
                                TextConstant.subTile3(
                                  context,
                                  text: tournament.formattedDateRange,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 12,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(12, context),
                          vertical: UtilsReponsive.height(6, context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: TextConstant.subTile3(
                          context,
                          text: tournament.status.toUpperCase(),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          size: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      TextConstant.subTile2(
                        context,
                        text: tournament.description,
                        color: Colors.grey[700]!,
                        size: 14,
                      ),
                      
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatChip(
                              context,
                              Icons.people,
                              tournament.maxParticipants.toString(),
                              "Participants",
                              Colors.blue,
                            ),
                          ),
                          SizedBox(width: UtilsReponsive.width(12, context)),
                          Expanded(
                            child: _buildStatChip(
                              context,
                              Icons.quiz,
                              tournament.totalQuizSets.toString(),
                              "Quiz Sets",
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      
                      // Join Status/Button for created and started tournaments
                      if (shouldCheckJoined) ...[
                        SizedBox(height: UtilsReponsive.height(16, context)),
                        Obx(() {
                          final joined = controller.isJoined(tournament.id);
                          final loading = controller.isLoadingJoined(tournament.id);
                          
                          if (loading) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: UtilsReponsive.height(8, context),
                                ),
                                child: SizedBox(
                                  width: UtilsReponsive.width(20, context),
                                  height: UtilsReponsive.width(20, context),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          if (joined) {
                            final isStartingQuiz = controller.isLoadingTodayQuiz(tournament.id);
                            final isCheckingCompleted = controller.isLoadingCompletedToday(tournament.id);
                            final isCompletedToday = controller.isCompletedToday(tournament.id);
                            
                            // Show loading when checking completed status
                            if (isCheckingCompleted) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: UtilsReponsive.height(8, context),
                                  ),
                                  child: SizedBox(
                                    width: UtilsReponsive.width(20, context),
                                    height: UtilsReponsive.width(20, context),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            // Show completed badge if already completed today
                            if (isCompletedToday) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: UtilsReponsive.width(16, context),
                                  vertical: UtilsReponsive.height(12, context),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.orange,
                                      size: UtilsReponsive.height(18, context),
                                    ),
                                    SizedBox(width: UtilsReponsive.width(8, context)),
                                    TextConstant.subTile2(
                                      context,
                                      text: "Đã hoàn thành hôm nay",
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            // Show start quiz button
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isStartingQuiz
                                    ? null
                                    : () => controller.startTournamentQuiz(tournament.id),
                                icon: isStartingQuiz
                                    ? SizedBox(
                                        width: UtilsReponsive.width(18, context),
                                        height: UtilsReponsive.width(18, context),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(
                                        Icons.quiz,
                                        color: Colors.white,
                                        size: UtilsReponsive.height(18, context),
                                      ),
                                label: TextConstant.subTile2(
                                  context,
                                  text: isStartingQuiz ? "Đang tải..." : "Tham gia làm bài",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  size: 14,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isStartingQuiz
                                      ? statusColor.withOpacity(0.6)
                                      : statusColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: UtilsReponsive.height(14, context),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final isJoining = controller.isLoadingJoin(tournament.id);
                            
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isJoining
                                    ? null
                                    : () => _showJoinConfirmDialog(context, tournament),
                                icon: isJoining
                                    ? SizedBox(
                                        width: UtilsReponsive.width(18, context),
                                        height: UtilsReponsive.width(18, context),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(
                                        Icons.person_add,
                                        color: Colors.white,
                                        size: UtilsReponsive.height(18, context),
                                      ),
                                label: TextConstant.subTile2(
                                  context,
                                  text: isJoining ? "Joining..." : "Join Tournament",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  size: 14,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isJoining
                                      ? statusColor.withOpacity(0.6)
                                      : statusColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: UtilsReponsive.height(14, context),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      ],
                      
                      // Detail Button
                      SizedBox(height: UtilsReponsive.height(12, context)),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed('/tournament-detail', arguments: tournament.id);
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(12, context),
        vertical: UtilsReponsive.height(12, context),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: UtilsReponsive.height(18, context),
            color: color,
          ),
          SizedBox(width: UtilsReponsive.width(8, context)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextConstant.subTile2(
                context,
                text: value,
                color: color,
                fontWeight: FontWeight.bold,
                size: 16,
              ),
              TextConstant.subTile4(
                context,
                text: label,
                color: Colors.grey[600]!,
                size: 11,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showJoinConfirmDialog(BuildContext context, TournamentModel tournament) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
          constraints: BoxConstraints(
            maxWidth: UtilsReponsive.width(400, context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                decoration: BoxDecoration(
                  color: tournament.statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: tournament.statusColor,
                  size: UtilsReponsive.height(40, context),
                ),
              ),
              
              SizedBox(height: UtilsReponsive.height(20, context)),
              
              // Title
              TextConstant.titleH2(
                context,
                text: "Join Tournament?",
                color: Colors.black,
                fontWeight: FontWeight.bold,
                size: 20,
              ),
              
              SizedBox(height: UtilsReponsive.height(12, context)),
              
              // Tournament Name
              TextConstant.subTile1(
                context,
                text: tournament.name,
                color: tournament.statusColor,
                fontWeight: FontWeight.w600,
                size: 16,
              ),
              
              SizedBox(height: UtilsReponsive.height(8, context)),
              
              // Description
              TextConstant.subTile2(
                context,
                text: "Are you sure you want to join this tournament?",
                color: Colors.grey[600]!,
                textAlign: TextAlign.center,
                size: 14,
              ),
              
              SizedBox(height: UtilsReponsive.height(24, context)),
              
              // Buttons
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
                          vertical: UtilsReponsive.height(14, context),
                        ),
                      ),
                      child: TextConstant.subTile2(
                        context,
                        text: "Cancel",
                        color: Colors.grey[700]!,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: UtilsReponsive.width(12, context)),
                  Expanded(
                    child: Obx(() {
                      final isJoining = controller.isLoadingJoin(tournament.id);
                      return ElevatedButton(
                        onPressed: isJoining
                            ? null
                            : () async {
                                Get.back();
                                await controller.joinTournament(tournament.id);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tournament.statusColor,
                          disabledBackgroundColor: tournament.statusColor.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: UtilsReponsive.height(14, context),
                          ),
                        ),
                        child: isJoining
                            ? SizedBox(
                                width: UtilsReponsive.width(20, context),
                                height: UtilsReponsive.width(20, context),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : TextConstant.subTile2(
                                context,
                                text: "Join",
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

