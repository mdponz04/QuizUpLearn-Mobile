import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

import '../controllers/home_controller.dart';
import '../../tab-home/views/tab_home_view.dart';
import '../../tab-home/controllers/tab_home_controller.dart';
import '../../explore-quiz/models/quiz_set_model.dart';
import '../../home/models/subscription_plan_model.dart';
import '../widgets/event_tab_widget.dart';

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
          const EventTabWidget(),
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
          text: "Quiz của tôi",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/quiz-history'),
            icon: Icon(
              Icons.history,
              color: ColorsManager.primary,
            ),
            tooltip: 'History',
          ),
          // IconButton(
          //   onPressed: () => controller.viewTournament(),
          //   icon: Icon(
          //     Icons.emoji_events,
          //     color: ColorsManager.primary,
          //   ),
          //   tooltip: 'Tournament',
          // ),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Subscription Info (if exists)
            Obx(() {
              if (controller.isLoadingSubscription.value) {
                return _buildSubscriptionLoadingState(context);
              }
              
              if (controller.userSubscription.value != null && 
                  controller.userSubscription.value!.isActive) {
                return Column(
                  children: [
                    _buildActiveSubscriptionInfo(context),
                  ],
                );
              }
              
              return SizedBox.shrink();
            }),
            
            // Subscription Plans Carousel
            Obx(() {
              final hasActiveSubscription = controller.userSubscription.value != null && 
                  controller.userSubscription.value!.isActive;
              
              // Nếu có active subscription, chỉ hiển thị khi showPlansCarousel = true
              if (hasActiveSubscription && !controller.showPlansCarousel.value) {
                return _buildViewPlansButton(context);
              }
              
              if (controller.isLoadingPlans.value) {
                return Container(
                  height: UtilsReponsive.height(200, context),
                  padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ColorsManager.primary,
                    ),
                  ),
                );
              }
              
              if (controller.subscriptionPlans.isEmpty) {
                return SizedBox.shrink();
              }
              
              return _buildSubscriptionPlansCarousel(context);
            }),
            
            SizedBox(height: UtilsReponsive.height(24, context)),
            
            // My Quiz List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: UtilsReponsive.width(16, context)),
              child: Obx(() {
                if (controller.isLoadingMyQuiz.value) {
                  return _buildMyQuizLoadingState(context);
                }
                
                if (controller.myQuizSets.isEmpty) {
                  return _buildMyQuizEmptyState(context);
                }
                
                return _buildMyQuizList(context);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/favorite-quizzes'),
        backgroundColor: Colors.red,
        child: const Icon(Icons.favorite, color: Colors.white),
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
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
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
          onTap: () async {
            final result = await Get.toNamed('/quiz-detail', arguments: quizSetModel.id);
            // If quiz was updated, refresh the list
            if (result == true) {
              controller.loadMyQuizSets();
            }
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
                    
                    // Chi tiết Button
                    GestureDetector(
                      onTap: () async {
                        final result = await Get.toNamed('/quiz-detail', arguments: quizSetModel.id);
                        // If quiz was updated, refresh the list
                        if (result == true) {
                          controller.loadMyQuizSets();
                        }
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

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
                      text: "Độ khó",
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: UtilsReponsive.height(4, context)),
                    TextConstant.subTile4(
                      context,
                      text: "Chọn mức độ khó phù hợp",
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


  Widget _buildAccountTab(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Tài khoản",
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
        child: FutureBuilder<Map<String, dynamic>?>(
          future: BaseCommon.instance.getUserInfo(),
          builder: (context, snapshot) {
            String username = "User Name";
            String email = "user@example.com";
            
            if (snapshot.hasData && snapshot.data != null) {
              final userInfo = snapshot.data!;
              username = userInfo['username']?.toString() ?? 
                        userInfo['email']?.toString().split('@').first ?? 
                        "User Name";
              email = userInfo['email']?.toString() ?? "user@example.com";
            }
            
            return Column(
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
                              text: username,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(height: UtilsReponsive.height(4, context)),
                            TextConstant.subTile2(
                              context,
                              text: email,
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
            );
          },
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

  Widget _buildSubscriptionLoadingState(BuildContext context) {
    return Container(
      height: UtilsReponsive.height(100, context),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Center(
        child: CircularProgressIndicator(
          color: ColorsManager.primary,
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionInfo(BuildContext context) {
    return Obx(() {
      final subscription = controller.userSubscription.value;
      final plan = controller.activeSubscriptionPlan.value;
      
      if (subscription == null) {
        return SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorsManager.primary,
                ColorsManager.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: UtilsReponsive.height(24, context),
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextConstant.titleH3(
                            context,
                            text: plan?.name ?? "Gói đang hoạt động",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 18,
                          ),
                          SizedBox(height: UtilsReponsive.height(4, context)),
                          TextConstant.subTile3(
                            context,
                            text: "Gói đang hoạt động",
                            color: Colors.white.withOpacity(0.9),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                    Container(
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
                        text: "ĐANG HOẠT ĐỘNG",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 10,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Info Row
                Row(
                  children: [
                    Expanded(
                      child: _buildSubscriptionInfoItem(
                        context,
                        Icons.calendar_today,
                        "Hết hạn",
                        _formatSubscriptionDate(subscription.endDate),
                      ),
                    ),
                    SizedBox(width: UtilsReponsive.width(12, context)),
                    Expanded(
                      child: _buildSubscriptionInfoItem(
                        context,
                        Icons.auto_awesome,
                        "AI còn lại",
                        "${subscription.aiGenerateQuizSetRemaining} lần",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSubscriptionInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: UtilsReponsive.height(14, context),
            ),
            SizedBox(width: UtilsReponsive.width(4, context)),
            TextConstant.subTile4(
              context,
              text: label,
              color: Colors.white.withOpacity(0.8),
              size: 10,
            ),
          ],
        ),
        SizedBox(height: UtilsReponsive.height(4, context)),
        TextConstant.subTile2(
          context,
          text: value,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          size: 13,
        ),
      ],
    );
  }

  String _formatSubscriptionDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return "$years ${years > 1 ? 'năm' : 'năm'}";
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return "$months ${months > 1 ? 'tháng' : 'tháng'}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} ${difference.inDays > 1 ? 'ngày' : 'ngày'}";
    } else {
      return "Đã hết hạn";
    }
  }

  Widget _buildViewPlansButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: UtilsReponsive.width(16, context)),
      child: OutlinedButton.icon(
        onPressed: () => controller.togglePlansCarousel(),
        icon: Icon(
          Icons.arrow_forward_ios,
          size: UtilsReponsive.height(12, context),
          color: ColorsManager.primary,
        ),
        label: TextConstant.subTile3(
          context,
          text: "Xem các gói",
          color: ColorsManager.primary,
          fontWeight: FontWeight.w600,
          size: 12,
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: ColorsManager.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.width(16, context),
            vertical: UtilsReponsive.height(8, context),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlansCarousel(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextConstant.titleH3(
                context,
                text: "Các gói đăng ký",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              Obx(() {
                final hasActiveSubscription = controller.userSubscription.value != null && 
                    controller.userSubscription.value!.isActive;
                if (hasActiveSubscription) {
                  return IconButton(
                    onPressed: () => controller.togglePlansCarousel(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: UtilsReponsive.height(20, context),
                    ),
                    tooltip: 'Đóng',
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          SizedBox(
            height: UtilsReponsive.height(220, context),
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.subscriptionPlans.length,
              itemBuilder: (context, index) {
                final plan = controller.subscriptionPlans[index];
                return _buildSubscriptionPlanCard(context, plan, index);
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlanCard(
    BuildContext context,
    SubscriptionPlanModel plan,
    int index,
  ) {
    final isPro = plan.name.toLowerCase() == 'pro';
    final cardColor = isPro ? ColorsManager.primary : Colors.grey[600]!;
    
    return Container(
      width: UtilsReponsive.width(240, context),
      margin: EdgeInsets.only(
        right: index < controller.subscriptionPlans.length - 1
            ? UtilsReponsive.width(12, context)
            : 0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPro
              ? [
            ColorsManager.primary,
            ColorsManager.primary.withOpacity(0.8),
                ]
              : [
                  Colors.grey[600]!,
                  Colors.grey[700]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConstant.titleH3(
                        context,
                        text: plan.name,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 18,
                      ),
                      SizedBox(height: UtilsReponsive.height(2, context)),
                      TextConstant.subTile2(
                        context,
                        text: plan.formattedPrice,
                        color: Colors.white.withOpacity(0.9),
                        size: 14,
                      ),
                    ],
                  ),
                ),
                if (isPro)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(6, context),
                      vertical: UtilsReponsive.height(2, context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextConstant.subTile4(
                      context,
                      text: "PHỔ BIẾN",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      size: 8,
                    ),
                  ),
              ],
            ),

            SizedBox(height: UtilsReponsive.height(8, context)),

            // Features
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSubscriptionFeatureItem(
                  context,
                  "Thời hạn: ${plan.formattedDuration}",
                  Icons.calendar_today,
                ),
                SizedBox(height: UtilsReponsive.height(4, context)),
                _buildSubscriptionFeatureItem(
                  context,
                  plan.canAccessPremiumContent
                      ? "Nội dung Premium"
                      : "Nội dung Cơ bản",
                  plan.canAccessPremiumContent
                      ? Icons.star
                      : Icons.star_border,
                ),
                SizedBox(height: UtilsReponsive.height(4, context)),
                _buildSubscriptionFeatureItem(
                  context,
                  "AI: ${plan.aiGenerateQuizSetMaxTimes} lần",
                  Icons.auto_awesome,
                ),
              ],
            ),

            SizedBox(height: UtilsReponsive.height(8, context)),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isPurchasing.value
                    ? null
                    : () => controller.purchaseSubscription(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: UtilsReponsive.height(8, context),
                  ),
                ),
                child: controller.isPurchasing.value
                    ? SizedBox(
                        width: UtilsReponsive.width(16, context),
                        height: UtilsReponsive.width(16, context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                        ),
                      )
                    : TextConstant.subTile3(
                        context,
                        text: plan.price == 0 ? "Bắt đầu" : "Đăng ký",
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                        size: 12,
                      ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionFeatureItem(
    BuildContext context,
    String text,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: UtilsReponsive.height(14, context),
        ),
        SizedBox(width: UtilsReponsive.width(6, context)),
        Expanded(
          child: TextConstant.subTile3(
            context,
            text: text,
            color: Colors.white.withOpacity(0.9),
            size: 11,
          ),
        ),
      ],
    );
  }
}
