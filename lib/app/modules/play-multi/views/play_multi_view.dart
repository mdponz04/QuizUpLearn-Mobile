import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/play_multi_controller.dart';
import '../models/multiplayer_quiz_model.dart';

class PlayMultiView extends GetView<PlayMultiController> {
  const PlayMultiView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Multiplayer Solo",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorsManager.primary,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.quizStatus.value == MultiplayerQuizStatus.completed) {
          return _buildResultsView(context);
        } else if (controller.currentQuestion != null) {
          return _buildQuizView(context);
        } else {
          return _buildLoadingView(context);
        }
      }),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
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
            text: "Loading quiz...",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView(BuildContext context) {
    return Column(
      children: [
        // Top 3 Leaderboard
        _buildTopLeaderboard(context),
        
        // Current Player Rank
        _buildCurrentPlayerRank(context),
        
        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Column(
              children: [
                // Question card
                _buildQuestionCard(context),
                
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Answer options
                _buildAnswerOptions(context),
                
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Result display (if answered)
                if (controller.showResult.value)
                  _buildResultDisplay(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopLeaderboard(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(UtilsReponsive.width(16, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple,
            Colors.purple.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextConstant.subTile1(
            context,
            text: "🏆 Top 3 Players",
            color: Colors.white,
            fontWeight: FontWeight.bold,
            size: 16,
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 2nd place
              if (controller.topPlayers.length >= 2)
                _buildTopPlayerCard(
                  context,
                  controller.topPlayers[1],
                  2,
                  Colors.grey[400]!,
                ),
              
              // 1st place
              if (controller.topPlayers.isNotEmpty)
                _buildTopPlayerCard(
                  context,
                  controller.topPlayers[0],
                  1,
                  Colors.amber,
                ),
              
              // 3rd place
              if (controller.topPlayers.length >= 3)
                _buildTopPlayerCard(
                  context,
                  controller.topPlayers[2],
                  3,
                  Colors.orange[700]!,
                ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildTopPlayerCard(BuildContext context, PlayerScore player, int rank, Color medalColor) {
    return Column(
      children: [
        // Medal
        Container(
          width: UtilsReponsive.height(40, context),
          height: UtilsReponsive.height(40, context),
          decoration: BoxDecoration(
            color: medalColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: medalColor.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: TextConstant.subTile3(
              context,
              text: "$rank",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              size: 18,
            ),
          ),
        ),
        
        SizedBox(height: UtilsReponsive.height(8, context)),
        
        // Avatar
        CircleAvatar(
          radius: UtilsReponsive.height(20, context),
          backgroundImage: AssetImage(player.playerAvatar),
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
        
        SizedBox(height: UtilsReponsive.height(4, context)),
        
        // Name
        TextConstant.subTile4(
          context,
          text: player.playerName,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          size: 10,
        ),
        
        SizedBox(height: UtilsReponsive.height(2, context)),
        
        // Score
        TextConstant.subTile4(
          context,
          text: "${player.score}",
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.bold,
          size: 12,
        ),
      ],
    );
  }

  Widget _buildCurrentPlayerRank(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: UtilsReponsive.width(16, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Your rank
          Expanded(
            child: Row(
              children: [
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(12, context),
                    vertical: UtilsReponsive.height(6, context),
                  ),
                  decoration: BoxDecoration(
                    color: controller.rankColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: controller.rankColor),
                  ),
                  child: TextConstant.subTile4(
                    context,
                    text: controller.rankText,
                    color: controller.rankColor,
                    fontWeight: FontWeight.bold,
                    size: 12,
                  ),
                )),
                
                SizedBox(width: UtilsReponsive.width(12, context)),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConstant.subTile4(
                      context,
                      text: "Your Rank",
                      color: Colors.grey[600]!,
                      size: 10,
                    ),
                    Obx(() => TextConstant.subTile3(
                      context,
                      text: controller.currentPlayerScore.value?.score.toString() ?? "0",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      size: 16,
                    )),
                  ],
                ),
              ],
            ),
          ),
          
          // Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextConstant.subTile4(
                context,
                text: controller.progressText,
                color: Colors.grey[600]!,
                size: 10,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              SizedBox(
                width: UtilsReponsive.width(60, context),
                child: LinearProgressIndicator(
                  value: controller.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    final question = controller.currentQuestion!;
    
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
          // Timer and difficulty
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(12, context),
                  vertical: UtilsReponsive.height(6, context),
                ),
                decoration: BoxDecoration(
                  color: ColorsManager.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextConstant.subTile4(
                  context,
                  text: question.difficulty,
                  color: ColorsManager.primary,
                  fontWeight: FontWeight.bold,
                  size: 12,
                ),
              ),
              
              // Timer
              Obx(() => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(12, context),
                  vertical: UtilsReponsive.height(6, context),
                ),
                decoration: BoxDecoration(
                  color: controller.timeRemaining.value <= 10 
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextConstant.subTile4(
                  context,
                  text: "${controller.timeRemaining.value}s",
                  color: controller.timeRemaining.value <= 10 
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                  size: 12,
                ),
              )),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Question
          TextConstant.subTile1(
            context,
            text: question.question,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(BuildContext context) {
    final question = controller.currentQuestion!;
    
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        
        return Obx(() {
          final isSelected = controller.selectedAnswerIndex.value == index;
          final isCorrect = index == question.correctAnswerIndex;
          final showCorrect = controller.showResult.value;
          
          Color backgroundColor = Colors.white;
          Color borderColor = Colors.grey[300]!;
          Color textColor = Colors.black;
          
          if (showCorrect) {
            if (isCorrect) {
              backgroundColor = Colors.green.withOpacity(0.1);
              borderColor = Colors.green;
              textColor = Colors.green;
            } else if (isSelected) {
              backgroundColor = Colors.red.withOpacity(0.1);
              borderColor = Colors.red;
              textColor = Colors.red;
            }
          } else if (isSelected) {
            backgroundColor = ColorsManager.primary.withOpacity(0.1);
            borderColor = ColorsManager.primary;
            textColor = ColorsManager.primary;
          }
          
          return Container(
            margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.isAnswered.value ? null : () => controller.selectAnswer(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      // Option letter
                      Container(
                        width: UtilsReponsive.height(30, context),
                        height: UtilsReponsive.height(30, context),
                        decoration: BoxDecoration(
                          color: borderColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: TextConstant.subTile4(
                            context,
                            text: String.fromCharCode(65 + index), // A, B, C, D
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 14,
                          ),
                        ),
                      ),
                      
                      SizedBox(width: UtilsReponsive.width(16, context)),
                      
                      // Option text
                      Expanded(
                        child: TextConstant.subTile3(
                          context,
                          text: option,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          size: 16,
                        ),
                      ),
                      
                      // Icons
                      if (showCorrect && isCorrect)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: UtilsReponsive.height(24, context),
                        )
                      else if (showCorrect && isSelected && !isCorrect)
                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: UtilsReponsive.height(24, context),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildResultDisplay(BuildContext context) {
    final question = controller.currentQuestion!;
    final isCorrect = controller.selectedAnswerIndex.value == question.correctAnswerIndex;
    
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: UtilsReponsive.height(24, context),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              TextConstant.subTile3(
                context,
                text: isCorrect ? "Correct!" : "Incorrect!",
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                size: 16,
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(8, context)),
          
          TextConstant.subTile4(
            context,
            text: question.explanation,
            color: Colors.grey[700]!,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Column(
        children: [
          // Final leaderboard
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.purple.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextConstant.titleH1(
                  context,
                  text: "🏆 Final Results",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                Obx(() => Column(
                  children: controller.topPlayers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final rank = index + 1;
                    
                    Color medalColor = Colors.grey[400]!;
                    if (rank == 1) medalColor = Colors.amber;
                    if (rank == 2) medalColor = Colors.grey[400]!;
                    if (rank == 3) medalColor = Colors.orange[700]!;
                    
                    return _buildFinalRankCard(context, player, rank, medalColor);
                  }).toList(),
                )),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Your final result
          Container(
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
                TextConstant.subTile1(
                  context,
                  text: "Your Performance",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  size: 18,
                ),
                
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                Obx(() {
                  final score = controller.currentPlayerScore.value;
                  if (score == null) return SizedBox.shrink();
                  
                  return Row(
                    children: [
                      // Rank
                      Expanded(
                        child: _buildStatItem(
                          context,
                          controller.rankText,
                          "Final Rank",
                          controller.rankColor,
                        ),
                      ),
                      
                      SizedBox(width: UtilsReponsive.width(16, context)),
                      
                      // Score
                      Expanded(
                        child: _buildStatItem(
                          context,
                          "${score.score}",
                          "Total Score",
                          ColorsManager.primary,
                        ),
                      ),
                    ],
                  );
                }),
                
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                Obx(() {
                  final score = controller.currentPlayerScore.value;
                  if (score == null) return SizedBox.shrink();
                  
                  return Row(
                    children: [
                      // Accuracy
                      Expanded(
                        child: _buildStatItem(
                          context,
                          "${(score.accuracy * 100).round()}%",
                          "Accuracy",
                          Colors.green,
                        ),
                      ),
                      
                      SizedBox(width: UtilsReponsive.width(16, context)),
                      
                      // Correct answers
                      Expanded(
                        child: _buildStatItem(
                          context,
                          "${score.correctAnswers}/${score.totalQuestions}",
                          "Correct",
                          Colors.blue,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.offNamed('/play-event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: UtilsReponsive.height(16, context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TextConstant.subTile3(
                    context,
                    text: "Back to Events",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(width: UtilsReponsive.width(16, context)),
              
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement play again
                    Get.snackbar(
                      "Play Again",
                      "Play again feature coming soon!",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: UtilsReponsive.height(16, context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TextConstant.subTile3(
                    context,
                    text: "Play Again",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalRankCard(BuildContext context, PlayerScore player, int rank, Color medalColor) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: UtilsReponsive.height(30, context),
            height: UtilsReponsive.height(30, context),
            decoration: BoxDecoration(
              color: medalColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: TextConstant.subTile4(
                context,
                text: "$rank",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                size: 14,
              ),
            ),
          ),
          
          SizedBox(width: UtilsReponsive.width(12, context)),
          
          // Avatar
          CircleAvatar(
            radius: UtilsReponsive.height(20, context),
            backgroundImage: AssetImage(player.playerAvatar),
          ),
          
          SizedBox(width: UtilsReponsive.width(12, context)),
          
          // Name
          Expanded(
            child: TextConstant.subTile3(
              context,
              text: player.playerName,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              size: 14,
            ),
          ),
          
          // Score
          TextConstant.subTile3(
            context,
            text: "${player.score}",
            color: Colors.white,
            fontWeight: FontWeight.bold,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.width(12, context),
            vertical: UtilsReponsive.height(8, context),
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: TextConstant.subTile3(
            context,
            text: value,
            color: color,
            fontWeight: FontWeight.bold,
            size: 16,
          ),
        ),
        
        SizedBox(height: UtilsReponsive.height(4, context)),
        
        TextConstant.subTile4(
          context,
          text: label,
          color: Colors.grey[600]!,
          size: 12,
        ),
      ],
    );
  }
}
