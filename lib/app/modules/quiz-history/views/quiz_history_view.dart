import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/quiz_history_controller.dart';

class QuizHistoryView extends GetView<QuizHistoryController> {
  const QuizHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Lịch sử",
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
        actions: [
          IconButton(
            onPressed: controller.loadHistory,
            icon: Icon(
              Icons.refresh,
              color: ColorsManager.primary,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }
        
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(context);
        }
        
        if (controller.historyList.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildHistoryList(context);
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
            text: "Đang tải lịch sử...",
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
              onPressed: controller.loadHistory,
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
              Icons.history,
              size: UtilsReponsive.height(64, context),
              color: Colors.grey[400],
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.titleH3(
              context,
              text: "Chưa có lịch sử",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: "Bạn chưa hoàn thành bài quiz nào.",
              color: Colors.grey[600]!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadHistory,
      color: ColorsManager.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        itemCount: controller.historyList.length,
        itemBuilder: (context, index) {
          final history = controller.historyList[index];
          return _buildHistoryItem(context, history);
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, history) {
    final accuracyColor = history.accuracy >= 0.7
        ? Colors.green
        : history.accuracy >= 0.5
            ? Colors.orange
            : Colors.red;

    return InkWell(
      onTap: () {
        Get.toNamed(
          '/quiz-history-detail',
          parameters: {
            'attemptId': history.id,
            'quizSetId': history.quizSetId,
            'attemptType': history.attemptType,
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
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
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConstant.subTile2(
                        context,
                        text: controller.getAttemptTypeText(history.attemptType),
                        color: ColorsManager.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: UtilsReponsive.height(4, context)),
                      TextConstant.subTile3(
                        context,
                        text: controller.formatDate(history.createdAt),
                        color: Colors.grey[600]!,
                        size: 11,
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
                    color: accuracyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accuracyColor.withOpacity(0.3),
                    ),
                  ),
                  child: TextConstant.subTile3(
                    context,
                    text: controller.getAccuracyText(history.accuracy),
                    color: accuracyColor,
                    fontWeight: FontWeight.bold,
                    size: 12,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(12, context)),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    "Điểm",
                    history.score.toString(),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                Expanded(
                  child: _buildStatItem(
                    context,
                    "Đúng",
                    "${history.correctAnswers}/${history.totalQuestions}",
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                Expanded(
                  child: _buildStatItem(
                    context,
                    "Sai",
                    history.wrongAnswers.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            if (history.timeSpent != null) ...[
              SizedBox(height: UtilsReponsive.height(8, context)),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: UtilsReponsive.height(14, context),
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: UtilsReponsive.width(4, context)),
                  TextConstant.subTile3(
                    context,
                    text: "Thời gian: ${_formatTime(history.timeSpent!)}",
                    color: Colors.grey[600]!,
                    size: 11,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: UtilsReponsive.height(16, context),
            color: color,
          ),
          SizedBox(height: UtilsReponsive.height(4, context)),
          TextConstant.subTile3(
            context,
            text: value,
            color: color,
            fontWeight: FontWeight.bold,
            size: 12,
          ),
          SizedBox(height: UtilsReponsive.height(2, context)),
          TextConstant.subTile4(
            context,
            text: label,
            color: Colors.grey[600]!,
            size: 9,
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }
}

