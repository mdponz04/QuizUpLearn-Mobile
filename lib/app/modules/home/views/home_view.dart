import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          _buildHomeTab(context),
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

  Widget _buildHomeTab(BuildContext context) {
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
            onPressed: () {
              // Notification action
            },
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
                    "Start Quiz",
                    'assets/images/do_quiz.png',
                    ColorsManager.primary,
                    () {
                      // Navigate to quiz
                    },
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Practice",
                    'assets/images/practice.png',
                    Colors.orange,
                    () {
                      // Navigate to practice
                    },
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
                    () {
                      // Navigate to vocabulary
                    },
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Progress",
                    'assets/images/progress.png',
                    Colors.purple,
                    () {
                      // Navigate to progress
                    },
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactStatCard(
                          context,
                          "Level",
                          "12",
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(6, context)),
                      Expanded(
                        child: _buildCompactStatCard(
                          context,
                          "Streak",
                          "7d",
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(6, context)),
                      Expanded(
                        child: _buildCompactStatCard(
                          context,
                          "Badges",
                          "5",
                          Icons.emoji_events,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: UtilsReponsive.height(12, context)),

                  // Recent Badge
                  _buildCompactRecentBadge(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
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
          // Header
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: ColorsManager.primary,
                size: UtilsReponsive.height(20, context),
              ),
              SizedBox(width: UtilsReponsive.width(8, context)),
              TextConstant.titleH3(
                context,
                text: "Your Progress",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),

          SizedBox(height: UtilsReponsive.height(16, context)),

          // EXP Progress Bar
          _buildExpProgress(context),

          SizedBox(height: UtilsReponsive.height(16, context)),

          // Stats Row
          Row(
            children: [
              // Level
              Expanded(
                child: _buildStatCard(
                  context,
                  "Level",
                  "12",
                  Icons.star,
                  Colors.amber,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(12, context)),
              // Streak
              Expanded(
                child: _buildStatCard(
                  context,
                  "Streak",
                  "7 days",
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(12, context)),
              // Achievements
              Expanded(
                child: _buildStatCard(
                  context,
                  "Badges",
                  "5",
                  Icons.emoji_events,
                  Colors.purple,
                ),
              ),
            ],
          ),

          SizedBox(height: UtilsReponsive.height(16, context)),

          // Recent Badge
          _buildRecentBadge(context),
        ],
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
            TextConstant.subTile3(
              context,
              text: "2,450/3,000",
              color: ColorsManager.primary,
              fontWeight: FontWeight.bold,
              size: 11,
            ),
          ],
        ),
        SizedBox(height: UtilsReponsive.height(6, context)),
        Container(
          height: UtilsReponsive.height(6, context),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.82,
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
          ),
        ),
      ],
    );
  }

  Widget _buildExpProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextConstant.subTile2(
              context,
              text: "Experience Points",
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
            TextConstant.subTile2(
              context,
              text: "2,450 / 3,000 XP",
              color: ColorsManager.primary,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        SizedBox(height: UtilsReponsive.height(8, context)),
        Container(
          height: UtilsReponsive.height(8, context),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.82, // 2450/3000
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorsManager.primary,
                    ColorsManager.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
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

  Widget _buildStatCard(
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: UtilsReponsive.height(20, context),
          ),
          SizedBox(height: UtilsReponsive.height(4, context)),
          TextConstant.subTile3(
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
            size: 9,
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
                TextConstant.subTile3(
                  context,
                  text: "Quiz Master",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  size: 10,
                ),
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

  Widget _buildRecentBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: UtilsReponsive.height(16, context),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.subTile2(
                  context,
                  text: "Recent Achievement",
                  color: Colors.grey[600]!,
                  size: 10,
                ),
                SizedBox(height: UtilsReponsive.height(2, context)),
                TextConstant.subTile2(
                  context,
                  text: "Quiz Master",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  size: 12,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: UtilsReponsive.height(12, context),
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
      ),
      body: Center(
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create quiz action
        },
        backgroundColor: ColorsManager.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
