import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/favorite_quiz_controller.dart';
import '../models/quiz_set_model.dart';

class FavoriteQuizView extends GetView<FavoriteQuizController> {
  const FavoriteQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Quiz yêu thích",
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
            onPressed: controller.refreshFavorites,
            icon: Icon(
              Icons.refresh,
              color: ColorsManager.primary,
            ),
            tooltip: 'Làm mới',
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
        
        if (controller.favoriteQuizSets.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildFavoritesList(context);
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
            text: "Đang tải quiz yêu thích...",
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
              onPressed: controller.loadFavorites,
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
              Icons.favorite_border,
              size: UtilsReponsive.height(80, context),
              color: Colors.grey[400],
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.titleH3(
              context,
              text: "Chưa có quiz yêu thích",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: "Hãy thêm quiz vào yêu thích để xem lại sau!",
              color: Colors.grey[600]!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshFavorites,
      color: ColorsManager.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        itemCount: controller.favoriteQuizSets.length,
        itemBuilder: (context, index) {
          final quizSet = controller.favoriteQuizSets[index];
          return _buildQuizSetCard(context, quizSet);
        },
      ),
    );
  }

  Widget _buildQuizSetCard(BuildContext context, QuizSetModel quizSet) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Get.toNamed('/quiz-detail', arguments: quizSet.id);
            // Always reload favorites when back from detail
            controller.loadFavorites();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Quiz Type Icon
                    Container(
                      padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
                      decoration: BoxDecoration(
                        color: ColorsManager.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quizSet.quizTypeIcon,
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(20, context),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: UtilsReponsive.width(12, context)),
                    
                    // Title and Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextConstant.titleH3(
                            context,
                            text: quizSet.title,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            size: 16,
                          ),
                          SizedBox(height: UtilsReponsive.height(2, context)),
                          TextConstant.subTile3(
                            context,
                            text: _getQuizTypeText(quizSet.quizType),
                            color: ColorsManager.primary,
                            fontWeight: FontWeight.w600,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                    
                    // Favorite Icon
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: UtilsReponsive.height(24, context),
                    ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(12, context)),
                
                // Description
                TextConstant.subTile2(
                  context,
                  text: quizSet.description,
                  color: Colors.grey[600]!,
                  size: 13,
                ),
                
                SizedBox(height: UtilsReponsive.height(12, context)),
                
                // Stats Row
                Row(
                  children: [
                    _buildStatChip(
                      context,
                      Icons.quiz,
                      "${quizSet.totalQuestions} câu hỏi",
                      Colors.blue,
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    _buildStatChip(
                      context,
                      Icons.timer,
                      quizSet.formattedTimeLimit,
                      Colors.orange,
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    _buildStatChip(
                      context,
                      Icons.trending_up,
                      quizSet.difficultyColor,
                      quizSet.difficultyColorValue,
                    ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(12, context)),
                
                // Footer Row
                Row(
                  children: [
                    // Skill Type
                    Expanded(
                      child: TextConstant.subTile3(
                        context,
                        text: quizSet.skillType,
                        color: Colors.grey[500]!,
                        size: 11,
                      ),
                    ),
                    
                    // Attempts
                    if (quizSet.totalAttempts > 0)
                      TextConstant.subTile3(
                        context,
                        text: "${quizSet.totalAttempts} lượt làm",
                        color: Colors.grey[500]!,
                        size: 11,
                      ),
                    
                    if (quizSet.totalAttempts > 0)
                      SizedBox(width: UtilsReponsive.width(8, context)),
                    
                    // Chi tiết Button
                    GestureDetector(
                      onTap: () async {
                        await Get.toNamed('/quiz-detail', arguments: quizSet.id);
                        // Always reload favorites when back from detail
                        controller.loadFavorites();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(12, context),
                          vertical: UtilsReponsive.height(6, context),
                        ),
                        decoration: BoxDecoration(
                          color: ColorsManager.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextConstant.subTile3(
                              context,
                              text: "Chi tiết",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 12,
                            ),
                            SizedBox(width: UtilsReponsive.width(4, context)),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: UtilsReponsive.height(12, context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
    String text,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.width(8, context),
        vertical: UtilsReponsive.height(4, context),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: UtilsReponsive.height(12, context),
          ),
          SizedBox(width: UtilsReponsive.width(4, context)),
          TextConstant.subTile4(
            context,
            text: text,
            color: color,
            fontWeight: FontWeight.w600,
            size: 10,
          ),
        ],
      ),
    );
  }

  String _getQuizTypeText(int quizType) {
    switch (quizType) {
      case 1:
        return 'TOEIC';
      case 2:
        return 'IELTS';
      case 3:
        return 'TOEFL';
      case 4:
        return 'Grammar';
      default:
        return 'Other';
    }
  }
}

