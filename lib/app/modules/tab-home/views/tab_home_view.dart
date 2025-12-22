import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/tab_home_controller.dart';
import '../../home/models/dashboard_models.dart';
import '../../home/models/subscription_plan_model.dart';
import '../../home/controllers/home_controller.dart';

class TabHomeView extends StatelessWidget {
  final TabHomeController? controller;
  
  const TabHomeView({super.key, this.controller});
  
  TabHomeController get tabController => controller ?? Get.find<TabHomeController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Trang chủ",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: tabController.showNotifications,
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
            // Dashboard Stats Section
            Obx(() {
              if (tabController.isLoadingDashboard.value) {
                return _buildDashboardLoading(context);
              }
              if (tabController.dashboardData.value != null) {
                return _buildDashboardStats(context, tabController.dashboardData.value!);
              }
              return const SizedBox.shrink();
            }),
            
            SizedBox(height: UtilsReponsive.height(24, context)),
            
            // Subscription Plans Section
            _buildSubscriptionPlansSection(context),
            
            SizedBox(height: UtilsReponsive.height(24, context)),
            
            // Quick actions
            TextConstant.titleH3(
              context,
              text: "Thao tác nhanh",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: UtilsReponsive.height(16, context)),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Tìm Quiz",
                    'assets/images/do_quiz.png',
                    ColorsManager.primary,
                    tabController.startQuiz,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Trò chơi",
                    'assets/images/practice.png',
                    Colors.orange,
                    tabController.playGame,
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
                    "Kiểm tra xếp lớp",
                    'assets/images/vocabulary.png',
                    Colors.green,
                    tabController.openPlacementTests,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Giải đấu",
                    'assets/images/trophy.png',
                    Colors.purple,
                    tabController.viewTournament,
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
                    "Lịch sử",
                    'assets/images/progress.png',
                    Colors.blue,
                    tabController.viewQuizHistory,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildWelcomeProgressSection(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           ColorsManager.primary,
  //           ColorsManager.primary.withOpacity(0.8),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: ColorsManager.primary.withOpacity(0.2),
  //           blurRadius: 10,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Welcome Header
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     TextConstant.titleH2(
  //                       context,
  //                       text: "Welcome Back!",
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       size: 20,
  //                     ),
  //                     SizedBox(height: UtilsReponsive.height(2, context)),
  //                     TextConstant.subTile1(
  //                       context,
  //                       text: "Ready to learn English today?",
  //                       color: Colors.white.withOpacity(0.9),
  //                       size: 12,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Image.asset('assets/images/astrorocket.png', width: UtilsReponsive.height(70, context), height: UtilsReponsive.height(70, context)),
  //             ],
  //           ),

  //           SizedBox(height: UtilsReponsive.height(16, context)),

  //           // Progress Section
  //           Container(
  //             padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [

  //                 // EXP Progress Bar
  //                 _buildCompactExpProgress(context),

  //                 SizedBox(height: UtilsReponsive.height(12, context)),

  //                 // Stats Row
  //                 Obx(() => Row(
  //                   children: [
  //                     Expanded(
  //                       child: _buildCompactStatCard(
  //                         context,
  //                         "Level",
  //                         tabController.currentLevel.value.toString(),
  //                         Icons.star,
  //                         Colors.amber,
  //                       ),
  //                     ),
  //                     SizedBox(width: UtilsReponsive.width(6, context)),
  //                     Expanded(
  //                       child: _buildCompactStatCard(
  //                         context,
  //                         "Streak",
  //                         tabController.formattedStreak,
  //                         Icons.local_fire_department,
  //                         Colors.orange,
  //                       ),
  //                     ),
  //                     SizedBox(width: UtilsReponsive.width(6, context)),
  //                     Expanded(
  //                       child: _buildCompactStatCard(
  //                         context,
  //                         "Badges",
  //                         tabController.totalBadges.value.toString(),
  //                         Icons.emoji_events,
  //                         Colors.purple,
  //                       ),
  //                     ),
  //                   ],
  //                 )),

  //                 SizedBox(height: UtilsReponsive.height(12, context)),

  //                 // Recent Badge
  //                 GestureDetector(
  //                   onTap: () => Get.toNamed('/badge'),
  //                   child: _buildCompactRecentBadge(context),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildCompactExpProgress(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           TextConstant.subTile3(
  //             context,
  //             text: "Experience",
  //             color: Colors.grey[600]!,
  //             fontWeight: FontWeight.w500,
  //             size: 11,
  //           ),
  //           Obx(() => TextConstant.subTile3(
  //             context,
  //             text: tabController.formattedExp,
  //             color: ColorsManager.primary,
  //             fontWeight: FontWeight.bold,
  //             size: 11,
  //           )),
  //         ],
  //       ),
  //       SizedBox(height: UtilsReponsive.height(6, context)),
  //       Container(
  //         height: UtilsReponsive.height(6, context),
  //         decoration: BoxDecoration(
  //           color: Colors.grey[200],
  //           borderRadius: BorderRadius.circular(3),
  //         ),
  //         child: Obx(() => FractionallySizedBox(
  //           alignment: Alignment.centerLeft,
  //           widthFactor: tabController.progressPercentage,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 colors: [
  //                   ColorsManager.primary,
  //                   ColorsManager.primary.withOpacity(0.8),
  //                 ],
  //               ),
  //               borderRadius: BorderRadius.circular(3),
  //             ),
  //           ),
  //         )),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildCompactStatCard(
  //   BuildContext context,
  //   String label,
  //   String value,
  //   IconData icon,
  //   Color color,
  // ) {
  //   return Container(
  //     padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(
  //         color: color.withOpacity(0.2),
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         Icon(
  //           icon,
  //           color: color,
  //           size: UtilsReponsive.height(16, context),
  //         ),
  //         SizedBox(height: UtilsReponsive.height(4, context)),
  //         TextConstant.subTile3(
  //           context,
  //           text: value,
  //           color: color,
  //           fontWeight: FontWeight.bold,
  //           size: 12,
  //         ),
  //         SizedBox(height: UtilsReponsive.height(2, context)),
  //         TextConstant.subTile4(
  //           context,
  //           text: label,
  //           color: Colors.grey[600]!,
  //           size: 8,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCompactRecentBadge(BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Colors.amber.withOpacity(0.1),
  //           Colors.orange.withOpacity(0.1),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(
  //         color: Colors.amber.withOpacity(0.3),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(UtilsReponsive.width(6, context)),
  //           decoration: BoxDecoration(
  //             color: Colors.amberAccent,
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.1),
  //                 blurRadius: 10,
  //                 offset: const Offset(0, 3),
  //               ),
  //             ],
  //             borderRadius: BorderRadius.circular(6),
  //           ),
  //           child:Image.asset('assets/images/trophy.png', width: UtilsReponsive.height(30, context), height: UtilsReponsive.height(30, context)),
  //         ),
  //         SizedBox(width: UtilsReponsive.width(8, context)),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               TextConstant.subTile4(
  //                 context,
  //                 text: "Recent",
  //                 color: Colors.grey[600]!,
  //                 size: 8,
  //               ),
  //               SizedBox(height: UtilsReponsive.height(1, context)),
  //               Obx(() => TextConstant.subTile3(
  //                 context,
  //                 text: tabController.recentBadge.value,
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.bold,
  //                 size: 10,
  //               )),
  //             ],
  //           ),
  //         ),
  //         Icon(
  //           Icons.arrow_forward_ios,
  //           color: Colors.grey[400],
  //           size: UtilsReponsive.height(10, context),
  //         ),
  //       ],
  //     ),
  //   );
  // }


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

  Widget _buildDashboardLoading(BuildContext context) {
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
      child: Center(
        child: CircularProgressIndicator(
          color: ColorsManager.primary,
        ),
      ),
    );
  }

  Widget _buildDashboardStats(BuildContext context, DashboardData data) {
    final stats = data.stats;
    
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
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: UtilsReponsive.height(20, context),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                Expanded(
                  child: TextConstant.titleH3(
                    context,
                    text: "Thống kê",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    size: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to account tab (index 3)
                    final homeController = Get.find<HomeController>();
                    homeController.changeTabIndex(3);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(12, context),
                      vertical: UtilsReponsive.height(6, context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextConstant.subTile3(
                          context,
                          text: "Xem chi tiết",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          size: 12,
                        ),
                        SizedBox(width: UtilsReponsive.width(4, context)),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: UtilsReponsive.height(14, context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: UtilsReponsive.height(16, context)),
            
            // Compact Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildCompactStat(
                    context,
                    Icons.quiz,
                    "Quiz",
                    "${stats.totalQuizzes}",
                  ),
                ),
                Container(
                  width: 1,
                  height: UtilsReponsive.height(40, context),
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildCompactStat(
                    context,
                    Icons.trending_up,
                    "Độ chính xác",
                    "${stats.accuracyRate.toStringAsFixed(1)}%",
                  ),
                ),
                Container(
                  width: 1,
                  height: UtilsReponsive.height(40, context),
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildCompactStat(
                    context,
                    Icons.local_fire_department,
                    "Chuỗi",
                    "${stats.currentStreak}",
                  ),
                ),
                Container(
                  width: 1,
                  height: UtilsReponsive.height(40, context),
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildCompactStat(
                    context,
                    Icons.emoji_events,
                    "Hạng",
                    "#${stats.currentRank}",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: UtilsReponsive.height(20, context)),
        SizedBox(height: UtilsReponsive.height(6, context)),
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

  Widget _buildSubscriptionPlansSection(BuildContext context) {
    return Obx(() {
      if (tabController.isLoadingPlans.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
            child: CircularProgressIndicator(
              color: ColorsManager.primary,
            ),
          ),
        );
      }

      if (tabController.subscriptionPlans.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConstant.titleH3(
            context,
            text: "Các gói đăng ký",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          SizedBox(
            height: UtilsReponsive.height(220, context),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabController.subscriptionPlans.length,
              itemBuilder: (context, index) {
                final plan = tabController.subscriptionPlans[index];
                return _buildSubscriptionPlanCard(context, plan, index);
              },
            ),
          ),
        ],
      );
    });
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
        right: index < tabController.subscriptionPlans.length - 1
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
                final buttonText = tabController.getButtonText(plan);
                final remainingDays = tabController.getRemainingDays();
                final hasActive = tabController.hasActiveSubscriptionForPlan(plan.id);
                
                return Column(
                  children: [
                    if (hasActive && remainingDays != null)
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
                        onPressed: tabController.isPurchasing.value
                            ? null
                            : () => tabController.purchaseSubscription(plan),
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
                        child: tabController.isPurchasing.value
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
          color: Colors.white.withOpacity(0.9),
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

