import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/tab_home_controller.dart';

class TabHomeView extends GetView<TabHomeController> {
  const TabHomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "QuizUpLearn",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.showNotifications,
            icon: Icon(
              Icons.notifications_outlined,
              color: ColorsManager.primary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome & Progress Section
            _buildWelcomeProgressSection(context),

            SizedBox(height: UtilsReponsive.height(24, context)),

            // Quick actions
            TextConstant.titleH3(
              context,
              text: "Quick Actions",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: UtilsReponsive.height(16, context)),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Explore Quiz",
                    'assets/images/do_quiz.png',
                    ColorsManager.primary,
                    controller.startQuiz,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Practice",
                    'assets/images/practice.png',
                    Colors.orange,
                    controller.startPractice,
                  ),
                ),
              ],
            ),

            SizedBox(height: UtilsReponsive.height(16, context)),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Vocabulary",
                    'assets/images/vocabulary.png',
                    Colors.green,
                    controller.openVocabulary,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Progress",
                    'assets/images/progress.png',
                    Colors.purple,
                    controller.viewProgress,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeProgressSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primary,
            ColorsManager.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConstant.titleH2(
                        context,
                        text: "Welcome Back!",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 20,
                      ),
                      SizedBox(height: UtilsReponsive.height(2, context)),
                      TextConstant.subTile1(
                        context,
                        text: "Ready to learn English today?",
                        color: Colors.white.withOpacity(0.9),
                        size: 12,
                      ),
                    ],
                  ),
                ),
                Image.asset('assets/images/astrorocket.png', width: UtilsReponsive.height(70, context), height: UtilsReponsive.height(70, context)),
              ],
            ),

            SizedBox(height: UtilsReponsive.height(16, context)),

            // Progress Section
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // EXP Progress Bar
                  _buildCompactExpProgress(context),

                  SizedBox(height: UtilsReponsive.height(12, context)),

                  // Stats Row
                  Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildCompactStatCard(
                          context,
                          "Level",
                          controller.currentLevel.value.toString(),
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(6, context)),
                      Expanded(
                        child: _buildCompactStatCard(
                          context,
                          "Streak",
                          controller.formattedStreak,
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(6, context)),
                      Expanded(
                        child: _buildCompactStatCard(
                          context,
                          "Badges",
                          controller.totalBadges.value.toString(),
                          Icons.emoji_events,
                          Colors.purple,
                        ),
                      ),
                    ],
                  )),

                  SizedBox(height: UtilsReponsive.height(12, context)),

                  // Recent Badge
                  GestureDetector(
                    onTap: () => Get.toNamed('/badge'),
                    child: _buildCompactRecentBadge(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactExpProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextConstant.subTile3(
              context,
              text: "Experience",
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
              size: 11,
            ),
            Obx(() => TextConstant.subTile3(
              context,
              text: controller.formattedExp,
              color: ColorsManager.primary,
              fontWeight: FontWeight.bold,
              size: 11,
            )),
          ],
        ),
        SizedBox(height: UtilsReponsive.height(6, context)),
        Container(
          height: UtilsReponsive.height(6, context),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Obx(() => FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: controller.progressPercentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorsManager.primary,
                    ColorsManager.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildCompactStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: UtilsReponsive.height(16, context),
          ),
          SizedBox(height: UtilsReponsive.height(4, context)),
          TextConstant.subTile3(
            context,
            text: value,
            color: color,
            fontWeight: FontWeight.bold,
            size: 12,
          ),
          SizedBox(height: UtilsReponsive.height(2, context)),
          TextConstant.subTile4(
            context,
            text: label,
            color: Colors.grey[600]!,
            size: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRecentBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(6, context)),
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(6),
            ),
            child:Image.asset('assets/images/trophy.png', width: UtilsReponsive.height(30, context), height: UtilsReponsive.height(30, context)),
          ),
          SizedBox(width: UtilsReponsive.width(8, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.subTile4(
                  context,
                  text: "Recent",
                  color: Colors.grey[600]!,
                  size: 8,
                ),
                SizedBox(height: UtilsReponsive.height(1, context)),
                Obx(() => TextConstant.subTile3(
                  context,
                  text: controller.recentBadge.value,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  size: 10,
                )),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: UtilsReponsive.height(10, context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
           Image.asset(icon, width: UtilsReponsive.height(50, context), height: UtilsReponsive.height(50, context)),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: title,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}
