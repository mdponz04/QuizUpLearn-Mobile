import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/quiz_history_detail_controller.dart';

class QuizHistoryDetailView extends GetView<QuizHistoryDetailController> {
  const QuizHistoryDetailView({super.key});

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
        
        if (controller.quizWithAnswers.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildDetailList(context);
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
            text: "Đang tải chi tiết quiz...",
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
              onPressed: () {
                final attemptId = Get.parameters['attemptId'];
                final quizSetId = Get.parameters['quizSetId'];
                if (attemptId != null && quizSetId != null) {
                  controller.loadDetail(attemptId, quizSetId);
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
              Icons.quiz,
              size: UtilsReponsive.height(64, context),
              color: Colors.grey[400],
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.titleH3(
              context,
              text: "Không có câu hỏi",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: "Không tìm thấy câu hỏi cho quiz này.",
              color: Colors.grey[600]!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailList(BuildContext context) {
    // Calculate statistics
    final totalQuestions = controller.quizWithAnswers.length;
    final correctAnswers = controller.quizWithAnswers.where((q) => q.isCorrect).length;
    final wrongAnswers = totalQuestions - correctAnswers;
    
    return ListView.builder(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      itemCount: controller.quizWithAnswers.length + 1, // +1 for summary card
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSummaryCard(context, totalQuestions, correctAnswers, wrongAnswers);
        }
        final quizWithAnswer = controller.quizWithAnswers[index - 1];
        return _buildQuestionCard(context, quizWithAnswer, index);
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    int totalQuestions,
    int correctAnswers,
    int wrongAnswers,
  ) {
    final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) : 0.0;
    final accuracyColor = accuracy >= 0.7
        ? Colors.green
        : accuracy >= 0.5
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsManager.primary.withOpacity(0.3),
          width: 2,
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
        children: [
          TextConstant.titleH2(
            context,
            text: "Tóm tắt",
            color: ColorsManager.primary,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  "Tổng",
                  totalQuestions.toString(),
                  Icons.quiz,
                  ColorsManager.primary,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  "Đúng",
                  correctAnswers.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  "Sai",
                  wrongAnswers.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: accuracyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accuracyColor,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  color: accuracyColor,
                  size: UtilsReponsive.height(20, context),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                TextConstant.titleH3(
                  context,
                  text: "Độ chính xác: ${(accuracy * 100).toStringAsFixed(1)}%",
                  color: accuracyColor,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: UtilsReponsive.height(24, context),
            color: color,
          ),
          SizedBox(height: UtilsReponsive.height(4, context)),
          TextConstant.titleH3(
            context,
            text: value,
            color: color,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(2, context)),
          TextConstant.subTile4(
            context,
            text: label,
            color: Colors.grey[600]!,
            size: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    dynamic quizWithAnswer,
    int questionNumber,
  ) {
    final quiz = quizWithAnswer.quiz;
    final attemptDetail = quizWithAnswer.attemptDetail;
    final isCorrect = quizWithAnswer.isCorrect;
    final userAnswerId = quizWithAnswer.userAnswerId;
    
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : (attemptDetail != null ? Colors.red : Colors.grey[300]!),
          width: 2,
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
                const Spacer(),
                if (attemptDetail != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(12, context),
                      vertical: UtilsReponsive.height(6, context),
                    ),
                    decoration: BoxDecoration(
                      color: isCorrect 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          size: UtilsReponsive.height(14, context),
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: UtilsReponsive.width(4, context)),
                        TextConstant.subTile3(
                          context,
                          text: isCorrect ? "Đúng" : "Sai",
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: UtilsReponsive.height(14, context),
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: UtilsReponsive.width(4, context)),
                      TextConstant.subTile3(
                        context,
                        text: controller.formatTime(attemptDetail.timeSpent),
                        color: Colors.grey[600]!,
                        size: 11,
                      ),
                    ],
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
            
            SizedBox(height: UtilsReponsive.height(16, context)),
            
            // Answer Options
            TextConstant.subTile2(
              context,
              text: "Các lựa chọn:",
              color: Colors.grey[700]!,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            
            // Sort options by orderIndex to ensure correct order (A, B, C, D)
            ...(() {
              final sortedOptions = List.from(quiz.answerOptions)
                ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
              return sortedOptions.map((option) {
              final isUserAnswer = userAnswerId == option.id;
              // Logic đúng: Kiểm tra option có isCorrect = true (thay vì so sánh với quiz.correctAnswer)
              final isCorrectAnswer = option.isCorrect == true;
              final isUserCorrectAnswer = isUserAnswer && isCorrectAnswer;
              
              // Kiểm tra nếu là placement test và câu hỏi sai thì không hiển thị đáp án đúng
              final isPlacement = controller.attemptType.value.toLowerCase() == 'placement';
              final shouldHideCorrectAnswer = isPlacement && !isCorrect;
              
              Color backgroundColor = Colors.white;
              Color borderColor = Colors.grey[300]!;
              Color textColor = Colors.black;
              IconData? icon;
              Color? iconColor;
              String? label;
              
              if (isUserCorrectAnswer) {
                // User chọn đúng
                backgroundColor = Colors.green.withOpacity(0.15);
                borderColor = Colors.green;
                textColor = Colors.green;
                icon = Icons.check_circle;
                iconColor = Colors.green;
                label = "Câu trả lời của bạn (Đúng)";
              } else if (isCorrectAnswer && !shouldHideCorrectAnswer) {
                // Đáp án đúng nhưng user không chọn (chỉ hiển thị nếu không phải placement sai)
                backgroundColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green;
                textColor = Colors.green;
                icon = Icons.check_circle;
                iconColor = Colors.green;
                label = "Đáp án đúng";
              } else if (isUserAnswer) {
                // User chọn sai
                backgroundColor = Colors.red.withOpacity(0.15);
                borderColor = Colors.red;
                textColor = Colors.red;
                icon = Icons.cancel;
                iconColor = Colors.red;
                label = "Câu trả lời của bạn (Sai)";
              }
              
              return Container(
                margin: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
                padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: isCorrectAnswer || isUserAnswer ? 2.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: UtilsReponsive.width(28, context),
                          height: UtilsReponsive.height(28, context),
                          decoration: BoxDecoration(
                            color: borderColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: borderColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: TextConstant.subTile3(
                              context,
                              text: option.optionLabel,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              size: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: UtilsReponsive.width(12, context)),
                        Expanded(
                          child: TextConstant.subTile2(
                            context,
                            text: option.optionText.isEmpty ? "Không có đáp án" : option.optionText,
                            color: textColor,
                            fontWeight: isCorrectAnswer || isUserAnswer ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (icon != null)
                          Container(
                            padding: EdgeInsets.all(UtilsReponsive.width(4, context)),
                            decoration: BoxDecoration(
                              color: iconColor!.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: UtilsReponsive.height(20, context),
                              color: iconColor,
                            ),
                          ),
                      ],
                    ),
                    if (label != null) ...[
                      SizedBox(height: UtilsReponsive.height(6, context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(8, context),
                          vertical: UtilsReponsive.height(4, context),
                        ),
                        decoration: BoxDecoration(
                          color: borderColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: UtilsReponsive.height(12, context),
                              color: iconColor,
                            ),
                            SizedBox(width: UtilsReponsive.width(4, context)),
                            TextConstant.subTile4(
                              context,
                              text: label,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
              }).toList();
            })(),
          ],
        ),
      ),
    );
  }
}

