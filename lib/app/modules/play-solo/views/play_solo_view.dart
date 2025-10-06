import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/play_solo_controller.dart';
import '../models/quiz_question_model.dart';

class PlaySoloView extends GetView<PlaySoloController> {
  const PlaySoloView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "1v1 Battle",
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
        if (controller.quizStatus.value == QuizStatus.completed) {
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
        // Header with scores and progress
        _buildHeader(context),
        
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Players info
          Row(
            children: [
              // Current player
              Expanded(
                child: _buildPlayerInfo(
                  context,
                  controller.currentPlayer.name,
                  controller.currentPlayer.avatar,
                  controller.currentPlayerScore.value,
                  true,
                ),
              ),
              
              // VS
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(12, context),
                  vertical: UtilsReponsive.height(8, context),
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextConstant.subTile3(
                  context,
                  text: "VS",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Opponent
              Expanded(
                child: _buildPlayerInfo(
                  context,
                  controller.opponent.name,
                  controller.opponent.avatar,
                  controller.opponentScore.value,
                  false,
                ),
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(16, context)),
          
          // Progress bar
          Row(
            children: [
              TextConstant.subTile4(
                context,
                text: controller.progressText,
                color: Colors.grey[600]!,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Expanded(
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

  Widget _buildPlayerInfo(BuildContext context, String name, String avatar, int score, bool isCurrentPlayer) {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: UtilsReponsive.height(25, context),
          backgroundImage: AssetImage(avatar),
          backgroundColor: isCurrentPlayer ? ColorsManager.primary.withOpacity(0.1) : Colors.grey[200],
        ),
        
        SizedBox(height: UtilsReponsive.height(8, context)),
        
        // Name
        TextConstant.subTile4(
          context,
          text: name,
          color: isCurrentPlayer ? ColorsManager.primary : Colors.black,
          fontWeight: FontWeight.bold,
          size: 12,
        ),
        
        SizedBox(height: UtilsReponsive.height(4, context)),
        
        // Score
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.width(8, context),
            vertical: UtilsReponsive.height(4, context),
          ),
          decoration: BoxDecoration(
            color: isCurrentPlayer ? ColorsManager.primary : Colors.grey[600],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextConstant.subTile4(
            context,
            text: "$score",
            color: Colors.white,
            fontWeight: FontWeight.bold,
            size: 14,
          ),
        ),
      ],
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
          // Timer
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
          final isOpponentAnswer = controller.opponentSelectedAnswer.value == index;
          
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
                        )
                      else if (isOpponentAnswer && controller.showOpponentAnswer.value)
                        Icon(
                          Icons.person,
                          color: Colors.blue,
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
          // Winner announcement
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorsManager.primary,
                  ColorsManager.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: UtilsReponsive.height(60, context),
                  color: Colors.white,
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                TextConstant.titleH1(
                  context,
                  text: controller.winnerText,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextConstant.subTile2(
                  context,
                  text: "Final Score: ${controller.currentPlayerScore.value} - ${controller.opponentScore.value}",
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Detailed results
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.subTile1(
                  context,
                  text: "Quiz Results",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  size: 18,
                ),
                
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Player results
                _buildPlayerResult(context, controller.currentPlayer, controller.currentPlayerScore.value, true),
                SizedBox(height: UtilsReponsive.height(16, context)),
                _buildPlayerResult(context, controller.opponent, controller.opponentScore.value, false),
              ],
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.offNamed('/home'),
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
                    // TODO: Implement rematch
                    Get.snackbar(
                      "Rematch",
                      "Rematch feature coming soon!",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: UtilsReponsive.height(16, context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TextConstant.subTile3(
                    context,
                    text: "Rematch",
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

  Widget _buildPlayerResult(BuildContext context, dynamic player, int score, bool isCurrentPlayer) {
    final correctAnswers = isCurrentPlayer 
        ? controller.currentPlayerAnswers.where((a) => a).length
        : controller.opponentAnswers.where((a) => a).length;
    final totalQuestions = controller.questions.length;
    final accuracy = (correctAnswers / totalQuestions * 100).round();
    
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: isCurrentPlayer 
            ? ColorsManager.primary.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: isCurrentPlayer 
            ? Border.all(color: ColorsManager.primary)
            : null,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: UtilsReponsive.height(25, context),
            backgroundImage: AssetImage(player.avatar),
          ),
          
          SizedBox(width: UtilsReponsive.width(16, context)),
          
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.subTile3(
                  context,
                  text: player.name,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  size: 16,
                ),
                SizedBox(height: UtilsReponsive.height(4, context)),
                TextConstant.subTile4(
                  context,
                  text: "$correctAnswers/$totalQuestions correct ($accuracy%)",
                  color: Colors.grey[600]!,
                  size: 14,
                ),
              ],
            ),
          ),
          
          // Score
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: UtilsReponsive.width(16, context),
              vertical: UtilsReponsive.height(8, context),
            ),
            decoration: BoxDecoration(
              color: isCurrentPlayer ? ColorsManager.primary : Colors.grey[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextConstant.subTile3(
              context,
              text: "$score",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
