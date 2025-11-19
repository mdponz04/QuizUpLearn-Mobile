import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/explore_quiz_controller.dart';
import '../models/quiz_set_model.dart';

class ExploreQuizView extends GetView<ExploreQuizController> {
  const ExploreQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Explore Quiz",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.refreshQuizSets,
            icon: Icon(
              Icons.refresh,
              color: ColorsManager.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilterSection(context),
          
          // Quiz Sets List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(context);
              }
              
              if (controller.filteredQuizSets.isEmpty) {
                return _buildEmptyState(context);
              }
              
              return _buildQuizSetsList(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: controller.searchQuizSets,
              decoration: InputDecoration(
                hintText: "Search quizzes...",
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        onPressed: controller.clearSearch,
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                      )
                    : const SizedBox.shrink()),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(16, context),
                  vertical: UtilsReponsive.height(12, context),
                ),
              ),
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          // Filter Chips
          SizedBox(
            height: UtilsReponsive.height(40, context),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.filterOptions.length,
              itemBuilder: (context, index) {
                final filter = controller.filterOptions[index];
                return Obx(() => Container(
                  margin: EdgeInsets.only(right: UtilsReponsive.width(8, context)),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(12, context),
                        fontWeight: controller.selectedFilter.value == filter
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: controller.selectedFilter.value == filter,
                    onSelected: (selected) {
                      controller.filterQuizSets(filter);
                    },
                    selectedColor: ColorsManager.primary.withOpacity(0.2),
                    checkmarkColor: ColorsManager.primary,
                    backgroundColor: Colors.grey[100],
                    side: BorderSide(
                      color: controller.selectedFilter.value == filter
                          ? ColorsManager.primary
                          : Colors.grey[300]!,
                    ),
                  ),
                ));
              },
            ),
          ),
        ],
      ),
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
            text: "Loading quiz sets...",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: UtilsReponsive.height(80, context),
            color: Colors.grey[400],
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.titleH3(
            context,
            text: "No quiz sets found",
            color: Colors.grey[600]!,
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextConstant.subTile2(
            context,
            text: "Try adjusting your search or filter",
            color: Colors.grey[500]!,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSetsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshQuizSets,
      color: ColorsManager.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        itemCount: controller.filteredQuizSets.length,
        itemBuilder: (context, index) {
          final quizSet = controller.filteredQuizSets[index];
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
          onTap: () => controller.startQuiz(quizSet)
              ,
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
                            text: controller.filterOptions[quizSet.quizType],
                            color: ColorsManager.primary,
                            fontWeight: FontWeight.w600,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                    
                    // Badges Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Premium Badge
                        if (quizSet.isPremiumOnly)
                          Container(
                            margin: EdgeInsets.only(right: UtilsReponsive.width(4, context)),
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextConstant.subTile4(
                              context,
                              text: "PREMIUM",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 8,
                            ),
                          ),
                        
                        // Active Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: UtilsReponsive.width(8, context),
                            vertical: UtilsReponsive.height(4, context),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green ,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextConstant.subTile4(
                            context,
                            text:  "ACTIVE",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 8,
                          ),
                        ),
                      ],
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
                      "${quizSet.totalQuestions} questions",
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
                        text: "${quizSet.totalAttempts} attempts",
                        color: Colors.grey[500]!,
                        size: 11,
                      ),
                    
                    if (quizSet.totalAttempts > 0)
                      SizedBox(width: UtilsReponsive.width(8, context)),
                    
                    // Room Game Button
                    Obx(() => Container(
                      margin: EdgeInsets.only(right: UtilsReponsive.width(8, context)),
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(12, context),
                        vertical: UtilsReponsive.height(6, context),
                      ),
                      decoration: BoxDecoration(
                        color: controller.isLoadingGame.value 
                            ? Colors.grey[300] 
                            : Colors.purple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: controller.isLoadingGame.value 
                            ? null 
                            : () => _showGameModeDialog(context, quizSet),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (controller.isLoadingGame.value)
                              SizedBox(
                                width: UtilsReponsive.height(12, context),
                                height: UtilsReponsive.height(12, context),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              Icon(
                                Icons.meeting_room,
                                color: Colors.white,
                                size: UtilsReponsive.height(12, context),
                              ),
                            if (!controller.isLoadingGame.value) ...[
                              SizedBox(width: UtilsReponsive.width(4, context)),
                              TextConstant.subTile3(
                                context,
                                text: "Room",
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                size: 12,
                              ),
                            ],
                          ],
                        ),
                      ),
                    )),
                    
                    // Start Button
                    Container(
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
                            text: "Start",
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

  void _showGameModeDialog(BuildContext context, QuizSetModel quizSet) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
          constraints: BoxConstraints(
            maxWidth: UtilsReponsive.width(400, context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.videogame_asset,
                    color: ColorsManager.primary,
                    size: UtilsReponsive.height(28, context),
                  ),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  Expanded(
                    child: TextConstant.titleH2(
                      context,
                      text: "Chọn chế độ chơi",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: UtilsReponsive.height(20, context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: UtilsReponsive.height(24, context)),
              
              // Multi Mode Option
              _buildGameModeOption(
                context,
                icon: Icons.people,
                title: "Multi Player",
                description: "Nhiều người chơi cùng lúc\nHost tạo phòng, players join bằng PIN",
                color: Colors.purple,
                onTap: () {
                  Get.back();
                  controller.createGameRoom(quizSet);
                },
              ),
              
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // 1vs1 Mode Option
              _buildGameModeOption(
                context,
                icon: Icons.person,
                title: "1 vs 1",
                description: "Đấu trực tiếp với 1 người chơi\nPlayer1 tạo phòng, Player2 join",
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  controller.createOneVsOneRoom(quizSet);
                },
              ),
              
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: UtilsReponsive.height(12, context),
                    ),
                  ),
                  child: TextConstant.subTile2(
                    context,
                    text: "Hủy",
                    color: Colors.grey[600]!,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: UtilsReponsive.height(24, context),
                ),
              ),
              SizedBox(width: UtilsReponsive.width(16, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConstant.titleH3(
                      context,
                      text: title,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: UtilsReponsive.height(4, context)),
                    TextConstant.subTile3(
                      context,
                      text: description,
                      color: Colors.grey[600]!,
                      size: 11,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: UtilsReponsive.height(16, context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
