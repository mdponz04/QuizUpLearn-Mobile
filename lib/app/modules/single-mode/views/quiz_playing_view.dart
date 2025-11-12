import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/single_mode_controller.dart';
import '../models/start_quiz_response.dart';

class QuizPlayingView extends GetView<SingleModeController> {
  const QuizPlayingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.currentQuestion.value == null) {
          return _buildLoadingState(context);
        }
        
        return _buildQuizContent(context);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: TextConstant.titleH3(
        context,
        text: "Quiz Playing",
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: true,
      backgroundColor: ColorsManager.primary,
      elevation: 0,
      leading: IconButton(
        onPressed: () => _showExitDialog(context),
        icon: const Icon(Icons.close, color: Colors.white),
      ),
      actions: [
        Obx(() => Container(
          margin: EdgeInsets.only(right: UtilsReponsive.width(16, context)),
          padding: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.width(12, context),
            vertical: UtilsReponsive.height(6, context),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextConstant.subTile3(
            context,
            text: controller.formattedTimeRemaining,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            size: 14,
          ),
        )),
      ],
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
            text: "Loading quiz...",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        _buildProgressBar(context),
        
        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question header
                _buildQuestionHeader(context),
                
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Question text
                _buildQuestionText(context),
                
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Answer options
                _buildAnswerOptions(context),
                
                SizedBox(height: UtilsReponsive.height(32, context)),
              ],
            ),
          ),
        ),
        
        // Bottom navigation
        _buildBottomNavigation(context),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextConstant.subTile2(
                context,
                text: "Question ${controller.currentQuestionNumber} of ${controller.totalQuestions}",
                color: Colors.grey[600]!,
                size: 14,
              ),
              TextConstant.subTile2(
                context,
                text: "${(controller.progress * 100).toInt()}%",
                color: ColorsManager.primary,
                fontWeight: FontWeight.bold,
                size: 14,
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          LinearProgressIndicator(
            value: controller.progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primary),
            minHeight: UtilsReponsive.height(6, context),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(BuildContext context) {
    return Container(
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
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
            decoration: BoxDecoration(
              color: ColorsManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.quiz,
              color: ColorsManager.primary,
              size: UtilsReponsive.height(20, context),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.subTile3(
                  context,
                  text: "Question ${controller.currentQuestionNumber}",
                  color: ColorsManager.primary,
                  fontWeight: FontWeight.bold,
                  size: 12,
                ),
                if (controller.currentQuestion.value?.toeicPart?.isNotEmpty == true)
                  TextConstant.subTile4(
                    context,
                    text: controller.currentQuestion.value!.toeicPart!,
                    color: Colors.grey[600]!,
                    size: 10,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionText(BuildContext context) {
    return Container(
      width: double.infinity,
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
            text: controller.currentQuestion.value?.questionText ?? '',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          
          // Audio player (if available)
          if (controller.currentQuestion.value?.audioUrl?.isNotEmpty == true)
            Container(
              margin: EdgeInsets.only(top: UtilsReponsive.height(16, context)),
              child: _buildAudioPlayer(context),
            ),
          
          // Image (if available)
          if (controller.currentQuestion.value?.imageUrl?.isNotEmpty == true)
            Container(
              margin: EdgeInsets.only(top: UtilsReponsive.height(16, context)),
              child: _buildImage(context),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        color: ColorsManager.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.toggleAudio,
            child: Container(
              padding: EdgeInsets.all(UtilsReponsive.width(4, context)),
              child: controller.isAudioLoading.value
                  ? SizedBox(
                      width: UtilsReponsive.height(24, context),
                      height: UtilsReponsive.height(24, context),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorsManager.primary,
                      ),
                    )
                  : Icon(
                      controller.isAudioPlaying.value
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: ColorsManager.primary,
                      size: UtilsReponsive.height(32, context),
                    ),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.subTile3(
                  context,
                  text: controller.isAudioPlaying.value
                      ? "Playing audio..."
                      : "Tap to play audio",
                  color: ColorsManager.primary,
                  fontWeight: FontWeight.w600,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildImage(BuildContext context) {
    final imageUrl = controller.currentQuestion.value?.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: UtilsReponsive.height(300, context),
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            height: UtilsReponsive.height(200, context),
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                color: ColorsManager.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: UtilsReponsive.height(200, context),
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  color: Colors.grey[400],
                  size: UtilsReponsive.height(48, context),
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextConstant.subTile3(
                  context,
                  text: "Failed to load image",
                  color: Colors.grey[600]!,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextConstant.titleH3(
          context,
          text: "Choose your answer:",
          color: Colors.black,
          fontWeight: FontWeight.bold,
          size: 16,
        ),
        SizedBox(height: UtilsReponsive.height(16, context)),
        Obx(() => Column(
          children: controller.currentQuestion.value?.answerOptions
              ?.map((option) => _buildAnswerOption(context, option))
              .toList() ?? [],
        )),
      ],
    );
  }

  Widget _buildAnswerOption(BuildContext context, AnswerOption option) {
    final optionLabelString = option.optionLabel?.toString().split('.').last ?? '';
    final optionId = option.id ?? '';
    final isSelected = controller.selectedAnswer.value == optionId;
    
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectAnswer(optionId),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              color: isSelected ? ColorsManager.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? ColorsManager.primary : Colors.grey[300]!,
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
            child: Row(
              children: [
                Container(
                  width: UtilsReponsive.height(32, context),
                  height: UtilsReponsive.height(32, context),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : ColorsManager.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: TextConstant.subTile2(
                      context,
                      text: optionLabelString,
                      color: isSelected ? ColorsManager.primary : Colors.white,
                      fontWeight: FontWeight.bold,
                      size: 14,
                    ),
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(16, context)),
                Expanded(
                  child: TextConstant.subTile1(
                    context,
                    text: (option.optionText?.isNotEmpty == true) 
                        ? option.optionText! 
                        : 'Option ${optionLabelString}',
                    color: isSelected ? Colors.white : Colors.black,
                    size: 15,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: UtilsReponsive.height(20, context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
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
      child: Row(
        children: [
          // Previous button
          if (!controller.isFirstQuestion)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousQuestion,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ColorsManager.primary),
                  padding: EdgeInsets.symmetric(
                    vertical: UtilsReponsive.height(12, context),
                  ),
                ),
                child: TextConstant.subTile2(
                  context,
                  text: "Previous",
                  color: ColorsManager.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          if (!controller.isFirstQuestion)
            SizedBox(width: UtilsReponsive.width(12, context)),
          
          // Skip button
          Expanded(
            child: OutlinedButton(
              onPressed: controller.skipQuestion,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orange),
                padding: EdgeInsets.symmetric(
                  vertical: UtilsReponsive.height(12, context),
                ),
              ),
              child: TextConstant.subTile2(
                context,
                text: "Skip",
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          SizedBox(width: UtilsReponsive.width(12, context)),
          
          // Next/Finish button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: controller.nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                padding: EdgeInsets.symmetric(
                  vertical: UtilsReponsive.height(12, context),
                ),
              ),
              child: TextConstant.subTile2(
                context,
                text: controller.isLastQuestion ? "Finish" : "Next",
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: TextConstant.titleH3(
          context,
          text: "Exit Quiz?",
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        content: TextConstant.subTile1(
          context,
          text: "Are you sure you want to exit? Your progress will be lost.",
          color: Colors.grey[600]!,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: TextConstant.subTile2(
              context,
              text: "Cancel",
              color: Colors.grey[600]!,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Exit quiz
            },
            child: TextConstant.subTile2(
              context,
              text: "Exit",
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
