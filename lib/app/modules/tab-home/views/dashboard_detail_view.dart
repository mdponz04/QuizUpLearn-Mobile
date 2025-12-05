import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/dashboard_detail_controller.dart';
import '../../home/models/dashboard_models.dart';
import '../../home/models/user_weak_point_model.dart';

class DashboardDetailView extends GetView<DashboardDetailController> {
  const DashboardDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Chi tiết thống kê",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorsManager.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }
        
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(context);
        }
        
        if (controller.dashboardData.value == null) {
          return _buildEmptyState(context);
        }
        
        return _buildContent(context);
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
          TextConstant.subTile1(
            context,
            text: "Đang tải dữ liệu...",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: UtilsReponsive.height(64, context),
              color: Colors.red,
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.titleH3(
              context,
              text: "Lỗi",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: controller.errorMessage.value,
              color: Colors.grey[600]!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: UtilsReponsive.height(24, context)),
            ElevatedButton(
              onPressed: controller.loadDashboardData,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(24, context),
                  vertical: UtilsReponsive.height(12, context),
                ),
              ),
              child: TextConstant.subTile1(
                context,
                text: "Thử lại",
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: UtilsReponsive.height(64, context),
              color: Colors.grey[400],
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.titleH3(
              context,
              text: "Không có dữ liệu",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: "Không tìm thấy dữ liệu thống kê.",
              color: Colors.grey[600]!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final data = controller.dashboardData.value!;
    final stats = data.stats;
    final progress = data.progress;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Section
          _buildStatsSection(context, stats),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Progress Section
          _buildProgressSection(context, progress),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Weak Points Section
          _buildWeakPointsSection(context),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, DashboardStats stats) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primary,
            ColorsManager.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: UtilsReponsive.height(24, context),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                TextConstant.titleH2(
                  context,
                  text: "Thống kê tổng quan",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(20, context)),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.quiz,
                    "Tổng Quiz",
                    "${stats.totalQuizzes}",
                    Colors.white,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.trending_up,
                    "Độ chính xác",
                    "${stats.accuracyRate.toStringAsFixed(1)}%",
                    Colors.white,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(12, context)),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.local_fire_department,
                    "Chuỗi ngày",
                    "${stats.currentStreak}",
                    Colors.white,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.emoji_events,
                    "Hạng",
                    "#${stats.currentRank}",
                    Colors.white,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(16, context)),
            
            // Answer Stats
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAnswerStat(
                    context,
                    Icons.check_circle,
                    "Đúng",
                    "${stats.totalCorrectAnswers}",
                    Colors.green[300]!,
                  ),
                  Container(
                    width: 1,
                    height: UtilsReponsive.height(30, context),
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildAnswerStat(
                    context,
                    Icons.cancel,
                    "Sai",
                    "${stats.totalWrongAnswers}",
                    Colors.red[300]!,
                  ),
                  Container(
                    width: 1,
                    height: UtilsReponsive.height(30, context),
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildAnswerStat(
                    context,
                    Icons.help_outline,
                    "Tổng câu",
                    "${stats.totalQuestions}",
                    Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: UtilsReponsive.height(24, context)),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextConstant.titleH3(
            context,
            text: value,
            color: color,
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          SizedBox(height: UtilsReponsive.height(4, context)),
          TextConstant.subTile3(
            context,
            text: label,
            color: color.withOpacity(0.9),
            size: 11,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerStat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: UtilsReponsive.height(20, context)),
        SizedBox(height: UtilsReponsive.height(4, context)),
        TextConstant.subTile2(
          context,
          text: value,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          size: 14,
        ),
        SizedBox(height: UtilsReponsive.height(2, context)),
        TextConstant.subTile4(
          context,
          text: label,
          color: Colors.white.withOpacity(0.9),
          size: 10,
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, DashboardProgress progress) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: ColorsManager.primary,
                size: UtilsReponsive.height(24, context),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              TextConstant.titleH2(
                context,
                text: "Tiến độ tuần",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(20, context)),
          
          // Weekly Progress Chart
          SizedBox(
            height: UtilsReponsive.height(200, context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: progress.weeklyProgress.map((day) {
                final percentage = day.scorePercentage;
                final maxHeight = UtilsReponsive.height(180, context);
                final barHeight = (percentage / 100) * maxHeight;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(4, context),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight > 0 ? barHeight : UtilsReponsive.height(4, context),
                          decoration: BoxDecoration(
                            color: ColorsManager.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: UtilsReponsive.height(8, context)),
                        TextConstant.subTile4(
                          context,
                          text: day.day,
                          color: Colors.grey[600]!,
                          size: 10,
                        ),
                        SizedBox(height: UtilsReponsive.height(4, context)),
                        TextConstant.subTile4(
                          context,
                          text: "${percentage.toStringAsFixed(0)}%",
                          color: ColorsManager.primary,
                          fontWeight: FontWeight.bold,
                          size: 9,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(20, context)),
          
          // Overall Stats
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: ColorsManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressStat(
                  context,
                  "Độ chính xác",
                  "${progress.overallAccuracy.toStringAsFixed(1)}%",
                  ColorsManager.primary,
                ),
                Container(
                  width: 1,
                  height: UtilsReponsive.height(30, context),
                  color: Colors.grey[300]!,
                ),
                _buildProgressStat(
                  context,
                  "Đúng",
                  "${progress.totalCorrectAnswers}",
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: UtilsReponsive.height(30, context),
                  color: Colors.grey[300]!,
                ),
                _buildProgressStat(
                  context,
                  "Sai",
                  "${progress.totalWrongAnswers}",
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        TextConstant.subTile2(
          context,
          text: value,
          color: color,
          fontWeight: FontWeight.bold,
          size: 16,
        ),
        SizedBox(height: UtilsReponsive.height(4, context)),
        TextConstant.subTile4(
          context,
          text: label,
          color: Colors.grey[600]!,
          size: 10,
        ),
      ],
    );
  }

  Widget _buildWeakPointsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: UtilsReponsive.height(24, context),
            ),
            SizedBox(width: UtilsReponsive.width(8, context)),
            TextConstant.titleH2(
              context,
              text: "Điểm yếu",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        
        SizedBox(height: UtilsReponsive.height(16, context)),
        
        Obx(() {
          if (controller.isLoadingWeakPoints.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
                child: CircularProgressIndicator(
                  color: ColorsManager.primary,
                ),
              ),
            );
          }
          
          if (controller.weakPoints.isEmpty) {
            return Container(
              padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: UtilsReponsive.height(48, context),
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: UtilsReponsive.height(12, context)),
                    TextConstant.subTile2(
                      context,
                      text: "Bạn chưa có điểm yếu nào",
                      color: Colors.grey[600]!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.weakPoints.length,
            itemBuilder: (context, index) {
              final weakPoint = controller.weakPoints[index];
              return _buildWeakPointCard(context, weakPoint, index + 1);
            },
          );
        }),
      ],
    );
  }

  Widget _buildWeakPointCard(
    BuildContext context,
    UserWeakPointModel weakPoint,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextConstant.subTile3(
                  context,
                  text: "#$index",
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  size: 12,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(8, context),
                        vertical: UtilsReponsive.height(4, context),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextConstant.subTile4(
                        context,
                        text: weakPoint.toeicPart,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        size: 10,
                      ),
                    ),
                    SizedBox(height: UtilsReponsive.height(4, context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(8, context),
                        vertical: UtilsReponsive.height(4, context),
                      ),
                      decoration: BoxDecoration(
                        color: weakPoint.difficultyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextConstant.subTile4(
                        context,
                        text: weakPoint.difficultyLevel,
                        color: weakPoint.difficultyColor,
                        fontWeight: FontWeight.bold,
                        size: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          // Weak Point
          TextConstant.titleH3(
            context,
            text: weakPoint.weakPoint,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 15,
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          // Advice
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.green,
                  size: UtilsReponsive.height(20, context),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                Expanded(
                  child: TextConstant.subTile2(
                    context,
                    text: weakPoint.advice,
                    color: Colors.grey[700]!,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

