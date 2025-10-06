import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/home_controller.dart';
import '../../tab-home/views/tab_home_view.dart';
import '../../tab-home/controllers/tab_home_controller.dart';

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
            builder: (controller) => const TabHomeView(),
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
