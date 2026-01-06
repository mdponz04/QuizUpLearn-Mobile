import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

import '../controllers/home_controller.dart';
import '../../tab-home/views/tab_home_view.dart';
import '../../tab-home/controllers/tab_home_controller.dart';
import '../../tab-home/controllers/dashboard_detail_controller.dart';
import '../../explore-quiz/models/quiz_set_model.dart';
import '../../home/models/subscription_plan_model.dart';
import '../../home/models/dashboard_models.dart';
import '../../home/models/user_weak_point_model.dart';
import '../widgets/event_tab_widget.dart';
import '../../explore-quiz/views/favorite_quiz_view.dart';
import '../../explore-quiz/controllers/favorite_quiz_controller.dart';

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
    // Initialize FavoriteQuizController if not already initialized
    if (!Get.isRegistered<FavoriteQuizController>()) {
      Get.put(FavoriteQuizController());
    }
    // Use FavoriteQuizView instead of my-quiz list
    return const FavoriteQuizView();
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
    // Initialize DashboardDetailController
    Get.lazyPut<DashboardDetailController>(() => DashboardDetailController());
    final dashboardController = Get.find<DashboardDetailController>();
    
    // Load user subscription when entering profile tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkUserSubscription();
    });
    
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
          PopupMenuButton<String>(
            icon: Icon(
              Icons.settings_outlined,
              color: ColorsManager.primary,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                Get.offAllNamed('/on-boarding');
              } else if (value == 'settings') {
                // Settings action
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: ColorsManager.primary),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    TextConstant.subTile1(
                      context,
                      text: 'Cài đặt',
                      color: Colors.black,
          ),
        ],
      ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    TextConstant.subTile1(
                      context,
                      text: 'Đăng xuất',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
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
            
          return SingleChildScrollView(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            Row(
                              children: [
                                TextConstant.titleH3(
                                  context,
                                  text: username,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(width: UtilsReponsive.width(8, context)),
                                // Premium icon if user has active subscription with price > 0
                                Obx(() {
                                  final subscription = controller.userSubscription.value;
                                  
                                  // Check if user has active subscription
                                  if (subscription == null || !subscription.isActive) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  // Check if subscription plan ID exists in list of plans with price > 0
                                  final hasPremium = controller.subscriptionPlans.any(
                                    (plan) => plan.id == subscription.subscriptionPlanId && plan.price > 0,
                                  );
                                  
                                  if (hasPremium) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: UtilsReponsive.width(6, context),
                                        vertical: UtilsReponsive.height(2, context),
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.amber,
                                            Colors.orange,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: UtilsReponsive.height(14, context),
                                          ),
                                          SizedBox(width: UtilsReponsive.width(4, context)),
                                          TextConstant.subTile4(
                                            context,
                                            text: "PREMIUM",
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            size: 9,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
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
                      // Icon(
                      //   Icons.edit_outlined,
                      //   color: ColorsManager.primary,
                      // ),
                    ],
                  ),
                ),

                SizedBox(height: UtilsReponsive.height(24, context)),

                // Dashboard Stats Section
                Obx(() {
                  if (dashboardController.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
                        child: CircularProgressIndicator(
                          color: ColorsManager.primary,
                        ),
                      ),
                    );
                  }
                  
                  if (dashboardController.errorMessage.value.isNotEmpty) {
                    return Container(
                      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: UtilsReponsive.width(8, context)),
                          Expanded(
                            child: TextConstant.subTile2(
                  context,
                              text: dashboardController.errorMessage.value,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (dashboardController.dashboardData.value == null) {
                    return SizedBox.shrink();
                  }
                  
                  final data = dashboardController.dashboardData.value!;
                  final stats = data.stats;
                  final progress = data.progress;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Section
                      _buildStatsSection(context, stats, dashboardController),
                      
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      // Progress Section
                      _buildProgressSection(context, progress),
                      
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      // Weak Points Section
                      _buildWeakPointsSection(context, dashboardController),
                      
                      SizedBox(height: UtilsReponsive.height(24, context)),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // Dashboard Stats Section
  Widget _buildStatsSection(BuildContext context, DashboardStats stats, DashboardDetailController controller) {
    return Container(
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
        padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: UtilsReponsive.height(24, context),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                TextConstant.titleH2(
                  context,
                  text: "Thống kê tổng quan",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(20, context)),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                  context,
                    Icons.quiz,
                    "Tổng Quiz",
                    "${stats.totalQuizzes}",
                    Colors.white,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildStatCard(
                  context,
                    Icons.trending_up,
                    "Độ chính xác",
                    "${stats.accuracyRate.toStringAsFixed(1)}%",
                    Colors.white,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(12, context)),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                  context,
                    Icons.local_fire_department,
                    "Chuỗi ngày",
                    "${stats.currentStreak}",
                    Colors.white,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.emoji_events,
                    "Hạng",
                    "#${stats.currentRank}",
                    Colors.white,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(16, context)),
            
            // Answer Stats
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAnswerStat(
                    context,
                    Icons.check_circle,
                    "Đúng",
                    "${stats.totalCorrectAnswers}",
                    Colors.green[300]!,
                  ),
                  Container(
                    width: 1,
                    height: UtilsReponsive.height(30, context),
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildAnswerStat(
                    context,
                    Icons.cancel,
                    "Sai",
                    "${stats.totalWrongAnswers}",
                    Colors.red[300]!,
                  ),
                  Container(
                    width: 1,
                    height: UtilsReponsive.height(30, context),
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildAnswerStat(
                    context,
                    Icons.help_outline,
                    "Tổng câu",
                    "${stats.totalQuestions}",
                    Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: UtilsReponsive.height(24, context)),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextConstant.titleH3(
            context,
            text: value,
            color: color,
            fontWeight: FontWeight.bold,
            size: 18,
          ),
          SizedBox(height: UtilsReponsive.height(4, context)),
          TextConstant.subTile3(
            context,
            text: label,
            color: color.withOpacity(0.9),
            size: 11,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerStat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: UtilsReponsive.height(20, context)),
        SizedBox(height: UtilsReponsive.height(4, context)),
        TextConstant.subTile2(
          context,
          text: value,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          size: 14,
        ),
        SizedBox(height: UtilsReponsive.height(2, context)),
        TextConstant.subTile4(
          context,
          text: label,
          color: Colors.white.withOpacity(0.9),
          size: 10,
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, DashboardProgress progress) {
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
                Icons.timeline,
                color: ColorsManager.primary,
                size: UtilsReponsive.height(24, context),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              TextConstant.titleH2(
          context,
                text: "Tiến độ tuần",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(20, context)),
          
          // Weekly Progress Chart
          SizedBox(
            height: UtilsReponsive.height(200, context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: progress.weeklyProgress.map((day) {
                final percentage = day.scorePercentage;
                final maxHeight = UtilsReponsive.height(180, context);
                final barHeight = (percentage / 100) * maxHeight;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(4, context),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight > 0 ? barHeight : UtilsReponsive.height(4, context),
                          decoration: BoxDecoration(
                            color: ColorsManager.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: UtilsReponsive.height(8, context)),
                        TextConstant.subTile4(
                          context,
                          text: day.day,
                          color: Colors.grey[600]!,
                          size: 10,
                        ),
                        SizedBox(height: UtilsReponsive.height(4, context)),
                        TextConstant.subTile4(
                          context,
                          text: "${percentage.toStringAsFixed(0)}%",
                          color: ColorsManager.primary,
                          fontWeight: FontWeight.bold,
                          size: 9,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(20, context)),
          
          // Overall Stats
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: ColorsManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressStat(
                  context,
                  "Độ chính xác",
                  "${progress.overallAccuracy.toStringAsFixed(1)}%",
                  ColorsManager.primary,
                ),
                Container(
                  width: 1,
                  height: UtilsReponsive.height(30, context),
                  color: Colors.grey[300]!,
                ),
                _buildProgressStat(
                  context,
                  "Đúng",
                  "${progress.totalCorrectAnswers}",
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: UtilsReponsive.height(30, context),
                  color: Colors.grey[300]!,
                ),
                _buildProgressStat(
                  context,
                  "Sai",
                  "${progress.totalWrongAnswers}",
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        TextConstant.subTile2(
          context,
          text: value,
          color: color,
          fontWeight: FontWeight.bold,
          size: 16,
        ),
        SizedBox(height: UtilsReponsive.height(4, context)),
        TextConstant.subTile4(
          context,
          text: label,
          color: Colors.grey[600]!,
          size: 10,
        ),
      ],
    );
  }

  Widget _buildWeakPointsSection(BuildContext context, DashboardDetailController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: UtilsReponsive.height(24, context),
            ),
            SizedBox(width: UtilsReponsive.width(8, context)),
            TextConstant.titleH2(
              context,
              text: "Điểm yếu",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(width: UtilsReponsive.width(8, context)),
          ],
        ),
        Row(
          children: [
            Obx(() => Container(
              padding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(8, context),
                vertical: UtilsReponsive.height(4, context),
              ),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextConstant.subTile2(
                context,
                text: "Bạn có ${controller.mistakeQuizzesCount.value} lỗi",
                color: Colors.red,
                fontWeight: FontWeight.bold,
                size: 12,
              ),
            )),
            SizedBox(width: UtilsReponsive.width(8, context)),
            Obx(() {
              if (controller.mistakeQuizzesCount.value > 0) {
                return ElevatedButton.icon(
                  onPressed: () => _showConfirmDialog(context, controller),
                  icon: Icon(
                    Icons.build,
          size: UtilsReponsive.height(16, context),
                    color: Colors.white,
                  ),
                  label: TextConstant.subTile2(
                    context,
                    text: "Khắc phục ngay",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    size: 12,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(12, context),
                      vertical: UtilsReponsive.height(2, context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
        SizedBox(height: UtilsReponsive.height(16, context)),
        
        Obx(() {
          if (controller.isLoadingWeakPoints.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
                child: CircularProgressIndicator(
                  color: ColorsManager.primary,
                ),
              ),
            );
          }
          
          if (controller.weakPoints.isEmpty) {
            return Container(
              padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: UtilsReponsive.height(48, context),
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: UtilsReponsive.height(12, context)),
                    TextConstant.subTile2(
                      context,
                      text: "Bạn chưa có điểm yếu nào",
                      color: Colors.grey[600]!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.weakPoints.length,
            itemBuilder: (context, index) {
              final weakPoint = controller.weakPoints[index];
              return _buildWeakPointCard(context, weakPoint, index + 1);
            },
          );
        }),
      ],
    );
  }

  Widget _buildWeakPointCard(
    BuildContext context,
    UserWeakPointModel weakPoint,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextConstant.subTile3(
                  context,
                  text: "#$index",
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  size: 12,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(8, context),
                        vertical: UtilsReponsive.height(4, context),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextConstant.subTile4(
                        context,
                        text: weakPoint.toeicPart,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        size: 10,
                      ),
                    ),
                    SizedBox(height: UtilsReponsive.height(4, context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(8, context),
                        vertical: UtilsReponsive.height(4, context),
                      ),
                      decoration: BoxDecoration(
                        color: weakPoint.difficultyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextConstant.subTile4(
                        context,
                        text: weakPoint.difficultyLevel,
                        color: weakPoint.difficultyColor,
                        fontWeight: FontWeight.bold,
                        size: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          // Weak Point
          TextConstant.titleH3(
            context,
            text: weakPoint.weakPoint,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 15,
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          // Advice
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.green,
                  size: UtilsReponsive.height(20, context),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                Expanded(
                  child: TextConstant.subTile2(
                    context,
                    text: weakPoint.advice,
                    color: Colors.grey[700]!,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, DashboardDetailController controller) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: ColorsManager.primary,
                size: UtilsReponsive.height(24, context),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              TextConstant.titleH3(
                context,
                text: "Xác nhận",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: TextConstant.subTile2(
            context,
            text: "Bạn có muốn bắt đầu làm bài khắc phục để cải thiện điểm yếu không?",
            color: Colors.grey[700]!,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: TextConstant.subTile2(
                context,
                text: "Hủy",
                color: Colors.grey[600]!,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.startMistakeQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: TextConstant.subTile2(
                context,
                text: "Xác nhận",
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
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
                        "${subscription.aiGenerateQuizSetRemaining ?? 0} lần",
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
              ],
            ),

            SizedBox(height: UtilsReponsive.height(8, context)),

            // Subscribe Button (only show for paid plans)
            if (plan.price > 0)
              Obx(() {
                final hasActive = controller.userSubscription.value != null &&
                    controller.userSubscription.value!.isActive &&
                    controller.userSubscription.value!.subscriptionPlanId == plan.id;
                final buttonText = hasActive ? "Gia hạn" : "Đăng ký";
                final remainingDays = hasActive && controller.userSubscription.value != null
                    ? controller.userSubscription.value!.endDate.difference(DateTime.now()).inDays
                    : null;
                
                return Column(
                  children: [
                    if (hasActive && remainingDays != null && remainingDays > 0)
                      Padding(
                        padding: EdgeInsets.only(bottom: UtilsReponsive.height(4, context)),
                        child: TextConstant.subTile4(
                          context,
                          text: "Còn $remainingDays ngày",
                          color: Colors.white.withOpacity(0.9),
                          size: 10,
                        ),
                      ),
            SizedBox(
              width: double.infinity,
                      child: ElevatedButton(
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
                                text: buttonText,
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                        size: 12,
                      ),
                      ),
            ),
                  ],
                );
              }),
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
