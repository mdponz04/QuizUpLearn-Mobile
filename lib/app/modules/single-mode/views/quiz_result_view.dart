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
          text: "Quiz Result",
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
            _buildScoreOverview(context),
            
            SizedBox(height: UtilsReponsive.height(24, context)),
            
            // Detailed stats
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
          
          TextConstant.titleH2(
            context,
            text: "Congratulations!",
            color: Colors.white,
            fontWeight: FontWeight.bold,
            size: 24,
          ),
          
          SizedBox(height: UtilsReponsive.height(8, context)),
          
          TextConstant.subTile1(
            context,
            text: "You completed the quiz",
            color: Colors.white.withOpacity(0.9),
            size: 16,
          ),
          
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
            text: result.status ?? 'Completed',
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
            text: "Your Score",
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
                  "Score",
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
                  "Accuracy",
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
            text: "Quiz Statistics",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          _buildStatRow(
            context,
            "Total Questions",
            "${result.totalQuestions ?? 0}",
            Icons.quiz,
            Colors.blue,
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          _buildStatRow(
            context,
            "Correct Answers",
            "${result.correctAnswers ?? 0}",
            Icons.check_circle,
            Colors.green,
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          _buildStatRow(
            context,
            "Wrong Answers",
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
                text: "Answer Results",
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
                  "Correct",
                  "${result.correctAnswers ?? 0}",
                  Colors.green,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(12, context)),
              Expanded(
                child: _buildAnswerResultSummary(
                  context,
                  "Wrong",
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
    return Column(
      children: [
        // Play again button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Navigate to quiz selection
              Get.snackbar(
                'Info',
                'Play again feature coming soon!',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
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
              text: "Play Again",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              size: 16,
            ),
          ),
        ),
        
        SizedBox(height: UtilsReponsive.height(12, context)),
        
        // Back to home button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.offAllNamed('/home'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: ColorsManager.primary),
              padding: EdgeInsets.symmetric(
                vertical: UtilsReponsive.height(16, context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: TextConstant.subTile1(
              context,
              text: "Back to Home",
              color: ColorsManager.primary,
              fontWeight: FontWeight.bold,
              size: 16,
            ),
          ),
        ),
      ],
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
