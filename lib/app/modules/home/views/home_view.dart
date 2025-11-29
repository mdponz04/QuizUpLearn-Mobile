import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/home_controller.dart';
import '../../tab-home/views/tab_home_view.dart';
import '../../tab-home/controllers/tab_home_controller.dart';
import '../../explore-quiz/models/quiz_set_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          GetBuilder<TabHomeController>(
            init: TabHomeController(),
            builder: (tabController) => TabHomeView(controller: tabController),
          ),
          _buildMyQuizTab(context),
          _buildForumTab(context),
          _buildAccountTab(context),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        UtilsReponsive.width(20, context),
        UtilsReponsive.height(10, context),
        UtilsReponsive.width(20, context),
        UtilsReponsive.height(20, context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              controller.navigationItems.length,
              (index) => _buildNavItem(context, index),
            ),
          )),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final item = controller.navigationItems[index];
    final isActive = controller.currentIndex.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTabIndex(index),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: UtilsReponsive.height(12, context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(UtilsReponsive.height(10, context)),
                decoration: BoxDecoration(
                  color: isActive 
                      ? ColorsManager.primary
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: ColorsManager.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive 
                      ? Colors.white
                      : Colors.grey[600],
                  size: UtilsReponsive.height(20, context),
                ),
              ),
              SizedBox(height: UtilsReponsive.height(6, context)),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(10, context),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive 
                      ? ColorsManager.primary 
                      : Colors.grey[500],
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }











  Widget _buildMyQuizTab(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "My Quiz",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // IconButton(
          //   onPressed: () => controller.loadMyQuizSets(),
          //   icon: Icon(
          //     Icons.refresh,
          //     color: ColorsManager.primary,
          //   ),
          //   tooltip: 'Refresh',
          // ),
          IconButton(
            onPressed: () => controller.viewTournament(),
            icon: Icon(
              Icons.emoji_events,
              color: ColorsManager.primary,
            ),
            tooltip: 'Tournament',
          ),
          IconButton(
            onPressed: () => _showAIGenerateDialog(context),
            icon: Icon(
              Icons.auto_awesome,
              color: ColorsManager.primary,
            ),
            tooltip: 'AI Generate Quiz',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingMyQuiz.value) {
          return _buildMyQuizLoadingState(context);
        }
        
        if (controller.myQuizSets.isEmpty) {
          return _buildMyQuizEmptyState(context);
        }
        
        return _buildMyQuizList(context);
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAIGenerateDialog(context),
        backgroundColor: ColorsManager.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMyQuizLoadingState(BuildContext context) {
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
            text: "Loading your quizzes...",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildMyQuizEmptyState(BuildContext context) {
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
            text: "No quizzes yet",
            color: Colors.grey[600]!,
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextConstant.subTile2(
            context,
            text: "Create your first quiz to get started",
            color: Colors.grey[500]!,
          ),
        ],
      ),
    );
  }

  Widget _buildMyQuizList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadMyQuizSets,
      color: ColorsManager.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        itemCount: controller.myQuizSets.length,
        itemBuilder: (context, index) {
          final quizSet = controller.myQuizSets[index];
          return _buildMyQuizSetCard(context, quizSet);
        },
      ),
    );
  }

  Widget _buildMyQuizSetCard(BuildContext context, QuizSetModel quizSetModel) {
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
          onTap: () => controller.startQuiz(quizSetModel),
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
                        quizSetModel.quizTypeIcon,
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
                            text: quizSetModel.title,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            size: 16,
                          ),
                          SizedBox(height: UtilsReponsive.height(2, context)),
                          TextConstant.subTile3(
                            context,
                            text: quizSetModel.skillType.isNotEmpty 
                                ? quizSetModel.skillType 
                                : 'General',
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
                        // Published Badge
                        if (quizSetModel.isPublished)
                          Container(
                            margin: EdgeInsets.only(right: UtilsReponsive.width(4, context)),
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextConstant.subTile4(
                              context,
                              text: "PUBLISHED",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 8,
                            ),
                          ),
                        
                        // Unpublished Badge
                        if (!quizSetModel.isPublished)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextConstant.subTile4(
                              context,
                              text: "DRAFT",
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
                  text: quizSetModel.description,
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
                      "${quizSetModel.totalQuestions} questions",
                      Colors.blue,
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    if (quizSetModel.timeLimit > 0)
                      _buildStatChip(
                        context,
                        Icons.timer,
                        quizSetModel.formattedTimeLimit,
                        Colors.orange,
                      ),
                    if (quizSetModel.timeLimit > 0)
                      SizedBox(width: UtilsReponsive.width(8, context)),
                    _buildStatChip(
                      context,
                      Icons.trending_up,
                      quizSetModel.difficultyColor,
                      quizSetModel.difficultyColorValue,
                    ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(12, context)),
                
                // Footer Row
                Row(
                  children: [
                    // Created Date
                    Expanded(
                      child: TextConstant.subTile3(
                        context,
                        text: "Created: ${_formatDate(quizSetModel.createdAt)}",
                        color: Colors.grey[500]!,
                        size: 11,
                      ),
                    ),
                    
                    // Attempts
                    if (quizSetModel.totalAttempts > 0)
                      TextConstant.subTile3(
                        context,
                        text: "${quizSetModel.totalAttempts} attempts",
                        color: Colors.grey[500]!,
                        size: 11,
                      ),
                    
                    if (quizSetModel.totalAttempts > 0)
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
                            : () => _showGameModeDialog(context, quizSetModel),
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

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
                title: "1 vs 1 / Multiplayer",
                description: "Đấu trực tiếp hoặc nhiều người chơi\nPlayer1 tạo phòng, Players join",
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  controller.showOneVsOneModeDialog(quizSet);
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

  void _showAIGenerateDialog(BuildContext context) {
    final topicController = TextEditingController();
    final questionCountController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
          constraints: BoxConstraints(
            maxWidth: UtilsReponsive.width(400, context),
            maxHeight: UtilsReponsive.height(600, context),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: ColorsManager.primary,
                      size: UtilsReponsive.height(28, context),
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    Expanded(
                      child: TextConstant.titleH2(
                        context,
                        text: "Tạo Quiz với AI",
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
                SizedBox(height: UtilsReponsive.height(20, context)),
                
                // Part Dropdown
                TextConstant.subTile1(
                  context,
                  text: "Part",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                Obx(() => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedPart.value,
                      isExpanded: true,
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(12, context),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: ColorsManager.primary,
                      ),
                      items: controller.partOptions.map((String part) {
                        return DropdownMenuItem<String>(
                          value: part,
                          child: TextConstant.subTile2(
                            context,
                            text: part,
                            color: Colors.black,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.selectedPart.value = newValue;
                        }
                      },
                    ),
                  ),
                )),
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Difficulty Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConstant.subTile1(
                      context,
                      text: "Difficulty Range",
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: UtilsReponsive.height(4, context)),
                    TextConstant.subTile4(
                      context,
                      text: "Select difficulty range (e.g., 70-100)",
                      color: Colors.grey[600]!,
                      size: 10,
                    ),
                  ],
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                Obx(() {
                  // Ensure value is valid, fallback to first option if not
                  final currentValue = controller.difficultyOptions.contains(controller.selectedDifficulty.value)
                      ? controller.selectedDifficulty.value
                      : controller.difficultyOptions.first;
                  
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentValue,
                        isExpanded: true,
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(12, context),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: ColorsManager.primary,
                        ),
                        items: controller.difficultyOptions.map((String difficulty) {
                          return DropdownMenuItem<String>(
                            value: difficulty,
                            child: TextConstant.subTile2(
                              context,
                              text: difficulty,
                              color: Colors.black,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedDifficulty.value = newValue;
                          }
                        },
                      ),
                    ),
                  );
                }),
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Topic Content TextField
                TextConstant.subTile1(
                  context,
                  text: "Nội dung đề tài",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextField(
                  controller: topicController,
                  decoration: InputDecoration(
                    hintText: "Nhập nội dung đề tài...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ColorsManager.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(16, context),
                      vertical: UtilsReponsive.height(12, context),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    controller.topicContent.value = value;
                  },
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Question Count TextField
                TextConstant.subTile1(
                  context,
                  text: "Số lượng câu hỏi",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextField(
                  controller: questionCountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Nhập số lượng câu hỏi...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ColorsManager.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(16, context),
                      vertical: UtilsReponsive.height(12, context),
                    ),
                  ),
                  onChanged: (value) {
                    controller.questionCount.value = value;
                  },
                ),
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.resetAIDialogForm();
                          topicController.clear();
                          questionCountController.clear();
                          Get.back();
                        },
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
                    SizedBox(width: UtilsReponsive.width(12, context)),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                // Update controller values from text fields
                                controller.topicContent.value = topicController.text.trim();
                                controller.questionCount.value = questionCountController.text.trim();
                                
                                // Call API
                                await controller.generateQuizWithAI();
                                
                                // Close dialog if successful
                                if (!controller.isLoading.value) {
                                  Get.back();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.primary,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: UtilsReponsive.height(12, context),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: UtilsReponsive.height(20, context),
                                width: UtilsReponsive.height(20, context),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : TextConstant.subTile2(
                                context,
                                text: "Tạo Quiz",
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      )),
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

  Widget _buildForumTab(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Forum",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: UtilsReponsive.height(80, context),
              color: Colors.grey[400],
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            TextConstant.titleH3(
              context,
              text: "Forum coming soon",
              color: Colors.grey[600]!,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: "Connect with other learners",
              color: Colors.grey[500]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Account",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Settings action
            },
            icon: Icon(
              Icons.settings_outlined,
              color: ColorsManager.primary,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Column(
          children: [
            // Profile section
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: UtilsReponsive.height(30, context),
                    backgroundColor: ColorsManager.primary,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: UtilsReponsive.height(30, context),
                    ),
                  ),
                  SizedBox(width: UtilsReponsive.width(16, context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextConstant.titleH3(
                          context,
                          text: "User Name",
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: UtilsReponsive.height(4, context)),
                        TextConstant.subTile2(
                          context,
                          text: "user@example.com",
                          color: Colors.grey[600]!,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    color: ColorsManager.primary,
                  ),
                ],
              ),
            ),

            SizedBox(height: UtilsReponsive.height(24, context)),

            // Menu items
            _buildMenuItem(
              context,
              "My Progress",
              Icons.trending_up_outlined,
              () {},
            ),
            _buildMenuItem(
              context,
              "Achievements",
              Icons.emoji_events_outlined,
              () {},
            ),
            _buildMenuItem(
              context,
              "Study Plan",
              Icons.calendar_today_outlined,
              () {},
            ),
            _buildMenuItem(
              context,
              "Help & Support",
              Icons.help_outline,
              () {},
            ),
            _buildMenuItem(
              context,
              "Logout",
              Icons.logout,
              () {
                Get.offAllNamed('/on-boarding');
              },
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : ColorsManager.primary,
        ),
        title: TextConstant.subTile1(
          context,
          text: title,
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: UtilsReponsive.height(16, context),
          color: Colors.grey[400],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
      ),
    );
  }
}
