import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/modules/home/models/subscription_plan_model.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/tab_home_controller.dart';

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
          text: "QuizUpLearn",
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
            // Subscription Plans Carousel
            _buildSubscriptionPlansCarousel(context),

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
                    tabController.startQuiz,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Play Game",
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
                    "Placement tests",
                    'assets/images/vocabulary.png',
                    Colors.green,
                    tabController.openPlacementTests,
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Tournament",
                    'assets/images/trophy.png',
                    Colors.purple,
                    tabController.viewTournament,
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

  Widget _buildSubscriptionPlansCarousel(BuildContext context) {
    return Obx(() {
      if (tabController.isLoadingPlans.value) {
        return Container(
          height: UtilsReponsive.height(200, context),
          child: Center(
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
            text: "Subscription Plans",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          SizedBox(
            height: UtilsReponsive.height(250, context),
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
      width: UtilsReponsive.width(280, context),
      margin: EdgeInsets.only(
        right: index < tabController.subscriptionPlans.length - 1
            ? UtilsReponsive.width(16, context)
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
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
                      TextConstant.titleH2(
                        context,
                        text: plan.name,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 24,
                      ),
                      SizedBox(height: UtilsReponsive.height(4, context)),
                      TextConstant.subTile1(
                        context,
                        text: plan.formattedPrice,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                    ],
                  ),
                ),
                if (isPro)
                  Container(
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
                      text: "POPULAR",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      size: 10,
                    ),
                  ),
              ],
            ),

                  SizedBox(height: UtilsReponsive.height(12, context)),

            // Features
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
                    children: [
                _buildFeatureItem(
                          context,
                  "Duration: ${plan.formattedDuration}",
                  Icons.calendar_today,
                ),
                SizedBox(height: UtilsReponsive.height(6, context)),
                _buildFeatureItem(
                          context,
                  plan.canAccessPremiumContent
                      ? "Premium Content"
                      : "Basic Content",
                  plan.canAccessPremiumContent
                      ? Icons.star
                      : Icons.star_border,
                ),
                SizedBox(height: UtilsReponsive.height(6, context)),
                _buildFeatureItem(
                          context,
                  "AI Features: ${plan.aiGenerateQuizSetMaxTimes} times",
                  Icons.auto_awesome,
                ),
              ],
            ),

                  SizedBox(height: UtilsReponsive.height(12, context)),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: tabController.isPurchasing.value
                    ? null
                    : () => tabController.purchaseSubscription(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: UtilsReponsive.height(12, context),
                  ),
                ),
                child: tabController.isPurchasing.value
                    ? SizedBox(
                        width: UtilsReponsive.width(20, context),
                        height: UtilsReponsive.width(20, context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                        ),
                      )
                    : TextConstant.subTile2(
                        context,
                        text: plan.price == 0 ? "Get Started" : "Subscribe",
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                      ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String text,
    IconData icon,
  ) {
    return Row(
        children: [
          Icon(
            icon,
          color: Colors.white,
            size: UtilsReponsive.height(16, context),
          ),
        SizedBox(width: UtilsReponsive.width(8, context)),
        Expanded(
          child: TextConstant.subTile3(
            context,
            text: text,
            color: Colors.white.withOpacity(0.9),
            size: 12,
          ),
        ),
      ],
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
