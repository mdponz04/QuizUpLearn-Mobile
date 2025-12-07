import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../models/submit_all_answers_response.dart';

class QuizResultView extends StatelessWidget {
  final Data result;
  
  const QuizResultView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextConstant.titleH3(
          context,
          text: "Kết quả Quiz",
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: ColorsManager.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.offAllNamed('/home'),
            icon: const Icon(Icons.home, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Column(
          children: [
            // Result header
            _buildResultHeader(context),
            
            SizedBox(height: UtilsReponsive.height(24, context)),
            
            // Score overview
            if (result.isPlacementTest)
              _buildPlacementTestScoreOverview(context)
            else
              _buildScoreOverview(context),
            
            SizedBox(height: UtilsReponsive.height(24, context)),
            
            // Detailed stats
            if (result.isPlacementTest)
              _buildPlacementTestDetailedStats(context)
            else
              _buildDetailedStats(context),
            
            SizedBox(height: UtilsReponsive.height(24, context)),
            
            // Improvement section
            _buildImprovementSection(context),
            
            SizedBox(height: UtilsReponsive.height(32, context)),
            
            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primary,
            ColorsManager.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Rank badge
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              _getRankIcon(),
              color: _getRankColor(),
              size: UtilsReponsive.height(40, context),
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // TextConstant.titleH2(
          //   context,
          //   text: result.isPlacementTest ? "Hoàn thành Bài Kiểm tra Xếp lớp!" : "Chúc mừng!",
          //   color: Colors.white,
          //   fontWeight: FontWeight.bold,
          //   size: 24,
          // ),
          
          // SizedBox(height: UtilsReponsive.height(8, context)),
          
          // TextConstant.subTile1(
          //   context,
          //   text: result.isPlacementTest 
          //       ? "Bạn đã hoàn thành bài kiểm tra xếp lớp"
          //       : "Bạn đã hoàn thành bài quiz",
          //   color: Colors.white.withOpacity(0.9),
          //   size: 16,
          // ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: UtilsReponsive.width(16, context),
              vertical: UtilsReponsive.height(8, context),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextConstant.subTile2(
            context,
            text: result.status == 'completed' ? 'Hoàn thành' : (result.status ?? 'Hoàn thành'),
            color: Colors.white,
            fontWeight: FontWeight.bold,
            size: 14,
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreOverview(BuildContext context) {
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
        children: [
          TextConstant.titleH3(
            context,
            text: "Điểm của bạn",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  context,
                  "Điểm",
                  "${result.score ?? 0}",
                  Icons.star,
                  Colors.amber,
                ),
              ),
              Container(
                width: 1,
                height: UtilsReponsive.height(40, context),
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildScoreItem(
                  context,
                  "Độ chính xác",
                  result.formattedAccuracy,
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: UtilsReponsive.height(24, context),
        ),
        SizedBox(height: UtilsReponsive.height(8, context)),
        TextConstant.titleH3(
          context,
          text: value,
          color: color,
          fontWeight: FontWeight.bold,
          size: 20,
        ),
        SizedBox(height: UtilsReponsive.height(4, context)),
        TextConstant.subTile3(
          context,
          text: label,
          color: Colors.grey[600]!,
          size: 12,
        ),
      ],
    );
  }

  Widget _buildPlacementTestScoreOverview(BuildContext context) {
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
        children: [
          TextConstant.titleH3(
            context,
            text: "Điểm Bài Kiểm tra Xếp lớp",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  context,
                  "Nghe",
                  "${result.lisPoint ?? 0}",
                  Icons.headphones,
                  Colors.blue,
                ),
              ),
              Container(
                width: 1,
                height: UtilsReponsive.height(40, context),
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildScoreItem(
                  context,
                  "Đọc",
                  "${result.reaPoint ?? 0}",
                  Icons.menu_book,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: ColorsManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorsManager.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextConstant.subTile1(
                  context,
                  text: "Tổng điểm: ",
                  color: Colors.grey[700]!,
                  size: 14,
                ),
                TextConstant.titleH3(
                  context,
                  text: "${result.totalPlacementPoints}",
                  color: ColorsManager.primary,
                  fontWeight: FontWeight.bold,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacementTestDetailedStats(BuildContext context) {
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
          TextConstant.titleH3(
            context,
            text: "Thống kê Bài Kiểm tra Xếp lớp",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Listening Section
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.headphones,
                      color: Colors.blue,
                      size: UtilsReponsive.height(20, context),
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    TextConstant.titleH3(
                      context,
                      text: "Nghe",
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      size: 16,
                    ),
                  ],
                ),
                SizedBox(height: UtilsReponsive.height(12, context)),
                _buildStatRow(
                  context,
                  "Số câu đúng",
                  "${result.totalCorrectLisAns ?? 0}",
                  Icons.check_circle,
                  Colors.green,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                _buildStatRow(
                  context,
                  "Điểm",
                  "${result.lisPoint ?? 0}",
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Reading Section
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Colors.purple,
                      size: UtilsReponsive.height(20, context),
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    TextConstant.titleH3(
                      context,
                      text: "Đọc",
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      size: 16,
                    ),
                  ],
                ),
                SizedBox(height: UtilsReponsive.height(12, context)),
                _buildStatRow(
                  context,
                  "Số câu đúng",
                  "${result.totalCorrectReaAns ?? 0}",
                  Icons.check_circle,
                  Colors.green,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                _buildStatRow(
                  context,
                  "Điểm",
                  "${result.reaPoint ?? 0}",
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Total Questions
          _buildStatRow(
            context,
            "Tổng số câu hỏi",
            "${result.totalQuestions ?? 0}",
            Icons.quiz,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
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
          TextConstant.titleH3(
            context,
            text: "Thống kê Quiz",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          _buildStatRow(
            context,
            "Tổng số câu hỏi",
            "${result.totalQuestions ?? 0}",
            Icons.quiz,
            Colors.blue,
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          _buildStatRow(
            context,
            "Số câu đúng",
            "${result.correctAnswers ?? 0}",
            Icons.check_circle,
            Colors.green,
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          _buildStatRow(
            context,
            "Số câu sai",
            "${result.wrongAnswers ?? 0}",
            Icons.cancel,
            Colors.red,
          ),
          
          // Time Spent - not available in new response
          // SizedBox(height: UtilsReponsive.height(12, context)),
          // _buildStatRow(
          //   context,
          //   "Time Spent",
          //   result.formattedTimeSpent,
          //   Icons.timer,
          //   Colors.orange,
          // ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: UtilsReponsive.height(16, context),
          ),
        ),
        SizedBox(width: UtilsReponsive.width(12, context)),
        Expanded(
          child: TextConstant.subTile1(
            context,
            text: label,
            color: Colors.grey[700]!,
            size: 14,
          ),
        ),
        TextConstant.subTile1(
          context,
          text: value,
          color: color,
          fontWeight: FontWeight.bold,
          size: 14,
        ),
      ],
    );
  }

  Widget _buildImprovementSection(BuildContext context) {
    // Show answer results if available
    if (result.answerResults == null || result.answerResults!.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
                Icons.quiz,
                color: ColorsManager.primary,
                size: UtilsReponsive.height(20, context),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              TextConstant.titleH3(
                context,
                text: "Kết quả Câu trả lời",
                color: Colors.black,
                fontWeight: FontWeight.bold,
                size: 18,
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Show summary of correct/wrong
          Row(
            children: [
              Expanded(
                child: _buildAnswerResultSummary(
                  context,
                  "Đúng",
                  "${result.correctAnswers ?? 0}",
                  Colors.green,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(12, context)),
              Expanded(
                child: _buildAnswerResultSummary(
                  context,
                  "Sai",
                  "${result.wrongAnswers ?? 0}",
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerResultSummary(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TextConstant.titleH3(
            context,
            text: value,
            color: color,
            fontWeight: FontWeight.bold,
            size: 24,
          ),
          SizedBox(height: UtilsReponsive.height(4, context)),
          TextConstant.subTile3(
            context,
            text: label,
            color: Colors.grey[700]!,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Get.offAllNamed('/home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.primary,
          padding: EdgeInsets.symmetric(
            vertical: UtilsReponsive.height(16, context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: TextConstant.subTile1(
          context,
          text: "Về Trang chủ",
          color: Colors.white,
          fontWeight: FontWeight.bold,
          size: 16,
        ),
      ),
    );
  }

  IconData _getRankIcon() {
    // Use status or score to determine icon
    final accuracy = result.accuracy ?? 0.0;
    if (accuracy >= 80) {
      return Icons.emoji_events;
    } else if (accuracy >= 60) {
      return Icons.workspace_premium;
    } else {
      return Icons.star;
    }
  }

  Color _getRankColor() {
    // Use status or score to determine color
    final accuracy = result.accuracy ?? 0.0;
    if (accuracy >= 80) {
      return Colors.amber;
    } else if (accuracy >= 60) {
      return Colors.grey[400]!;
    } else {
      return ColorsManager.primary;
    }
  }
}
