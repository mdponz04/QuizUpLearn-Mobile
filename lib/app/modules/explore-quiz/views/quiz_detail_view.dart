import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/quiz_detail_controller.dart';

class QuizDetailView extends GetView<QuizDetailController> {
  const QuizDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Chi tiết Quiz",
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
        
        if (controller.quizSet.value == null) {
          return _buildEmptyState(context);
        }
        
        return _buildDetailList(context);
      }),
      bottomNavigationBar: Obx(() {
        if (controller.quizSet.value == null) {
          return const SizedBox.shrink();
        }
        return _buildBottomNavigationBar(context);
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
            text: "Loading quiz details...",
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
              text: "Error",
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
              onPressed: () {
                final quizSetId = Get.arguments as String?;
                if (quizSetId != null) {
                  controller.loadQuizSetDetail(quizSetId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(24, context),
                  vertical: UtilsReponsive.height(12, context),
                ),
              ),
              child: TextConstant.subTile1(
                context,
                text: "Retry",
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
              Icons.quiz,
              size: UtilsReponsive.height(64, context),
              color: Colors.grey[400],
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.titleH3(
              context,
              text: "No Quiz Found",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: "No quiz set found.",
              color: Colors.grey[600]!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailList(BuildContext context) {
    final quizSet = controller.quizSet.value!;
    final quizzes = quizSet.quizzes.where((q) => q.isActive).toList();
    
    return ListView.builder(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      itemCount: quizzes.length + 1, // +1 for summary card
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSummaryCard(context, quizSet);
        }
        final quiz = quizzes[index - 1];
        return _buildQuestionCard(context, quiz, index);
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, quizSet) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      decoration: BoxDecoration(
        color: ColorsManager.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorsManager.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
                decoration: BoxDecoration(
                  color: ColorsManager.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  quizSet.quizTypeIcon,
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(24, context),
                  ),
                ),
              ),
              SizedBox(width: UtilsReponsive.width(12, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConstant.titleH2(
                      context,
                      text: quizSet.title,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: UtilsReponsive.height(4, context)),
                    TextConstant.subTile2(
                      context,
                      text: quizSet.description,
                      color: Colors.grey[600]!,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          Row(
            children: [
              _buildStatItem(
                context,
                Icons.quiz,
                "${quizSet.totalQuestions} câu hỏi",
                Colors.blue,
              ),
              SizedBox(width: UtilsReponsive.width(12, context)),
              _buildStatItem(
                context,
                Icons.timer,
                quizSet.formattedTimeLimit,
                Colors.orange,
              ),
              SizedBox(width: UtilsReponsive.width(12, context)),
              _buildStatItem(
                context,
                Icons.trending_up,
                quizSet.difficultyColor,
                quizSet.difficultyColorValue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: UtilsReponsive.width(8, context),
          vertical: UtilsReponsive.height(8, context),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: UtilsReponsive.height(16, context)),
            SizedBox(width: UtilsReponsive.width(4, context)),
            Flexible(
              child: TextConstant.subTile3(
                context,
                text: text,
                color: color,
                fontWeight: FontWeight.w600,
                size: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    quiz,
    int questionNumber,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
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
            // Question Header
            Row(
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
                  child: TextConstant.subTile3(
                    context,
                    text: "Câu hỏi $questionNumber",
                    color: ColorsManager.primary,
                    fontWeight: FontWeight.bold,
                    size: 12,
                  ),
                ),
                if (quiz.toeicPart.isNotEmpty) ...[
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(8, context),
                      vertical: UtilsReponsive.height(4, context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextConstant.subTile4(
                      context,
                      text: quiz.toeicPart,
                      color: Colors.grey[700]!,
                      size: 10,
                    ),
                  ),
                ],
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(12, context)),
            
            // Question Text
            TextConstant.titleH3(
              context,
              text: quiz.questionText,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            
            // Image if available
            if (quiz.hasImage && quiz.imageURL.isNotEmpty) ...[
              SizedBox(height: UtilsReponsive.height(12, context)),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  quiz.imageURL,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: UtilsReponsive.height(150, context),
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
            ],
            
            SizedBox(height: UtilsReponsive.height(16, context)),
            
            // Answer Options
            TextConstant.subTile2(
              context,
              text: "Answer Options:",
              color: Colors.grey[700]!,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            
            ...quiz.answerOptions.map((option) {
              return Container(
                margin: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
                padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: UtilsReponsive.width(28, context),
                      height: UtilsReponsive.height(28, context),
                      decoration: BoxDecoration(
                        color: ColorsManager.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorsManager.primary,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: TextConstant.subTile3(
                          context,
                          text: option.optionLabel,
                          color: ColorsManager.primary,
                          fontWeight: FontWeight.bold,
                          size: 13,
                        ),
                      ),
                    ),
                    SizedBox(width: UtilsReponsive.width(12, context)),
                    Expanded(
                      child: TextConstant.subTile2(
                        context,
                        text: option.optionText.isEmpty ? "No answer" : option.optionText,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(16, context),
        vertical: UtilsReponsive.height(12, context),
      ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trò chơi Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoadingGame.value
                    ? null
                    : () => controller.showGameModeDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(
                    vertical: UtilsReponsive.height(14, context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoadingGame.value
                    ? SizedBox(
                        height: UtilsReponsive.height(20, context),
                        width: UtilsReponsive.height(20, context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.meeting_room,
                            color: Colors.white,
                            size: UtilsReponsive.height(20, context),
                          ),
                          SizedBox(width: UtilsReponsive.width(8, context)),
                          TextConstant.subTile1(
                            context,
                            text: "Trò chơi",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
              ),
            )),
            SizedBox(height: UtilsReponsive.height(12, context)),
            // Làm bài Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: UtilsReponsive.height(14, context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextConstant.subTile1(
                      context,
                      text: "Làm bài",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: UtilsReponsive.height(20, context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

