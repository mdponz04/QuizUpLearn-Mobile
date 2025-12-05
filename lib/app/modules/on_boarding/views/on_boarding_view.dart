import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/on_boarding_controller.dart';

class OnBoardingView extends GetView<OnBoardingController> {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: controller.skipToEnd,
                    child: TextConstant.subTile1(
                      context,
                      text: "Bỏ qua",
                      color: ColorsManager.primary,
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onBoardingPages.length,
                itemBuilder: (context, index) {
                  final page = controller.onBoardingPages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(24, context),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        Container(
                          height: UtilsReponsive.height(300, context),
                          width: UtilsReponsive.width(300, context),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              page.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        SizedBox(height: UtilsReponsive.height(40, context)),

                        // Title
                        TextConstant.titleH1(
                          context,
                          text: page.title,
                          color: ColorsManager.primary,
                          size: 28,
                          fontWeight: FontWeight.bold,
                        ),

                        SizedBox(height: UtilsReponsive.height(16, context)),

                        // Description
                        TextConstant.subTile1(
                          context,
                          text: page.description,
                          color: Colors.grey[600]!,
                          size: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicator
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dots indicator
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.onBoardingPages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(4, context),
                            ),
                            height: UtilsReponsive.height(8, context),
                            width: controller.currentIndex.value == index
                                ? UtilsReponsive.width(24, context)
                                : UtilsReponsive.width(8, context),
                            decoration: BoxDecoration(
                              color: controller.currentIndex.value == index
                                  ? ColorsManager.primary
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      )),

                  SizedBox(height: UtilsReponsive.height(32, context)),

                  // Navigation buttons
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(24, context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous button
                        Obx(() => controller.currentIndex.value > 0
                            ? TextButton.icon(
                                onPressed: controller.previousPage,
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: ColorsManager.primary,
                                  size: UtilsReponsive.height(20, context),
                                ),
                                label: TextConstant.subTile1(
                                  context,
                                  text: "Trước",
                                  color: ColorsManager.primary,
                                ),
                              )
                            : const SizedBox(width: 100)),

                        // Next/Get Started button
                        Obx(() => ElevatedButton(
                              onPressed: controller.nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsManager.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: UtilsReponsive.width(32, context),
                                  vertical: UtilsReponsive.height(16, context),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextConstant.subTile1(
                                    context,
                                    text: controller.currentIndex.value ==
                                            controller.onBoardingPages.length - 1
                                        ? "Bắt đầu"
                                        : "Tiếp theo",
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  if (controller.currentIndex.value <
                                      controller.onBoardingPages.length - 1)
                                    SizedBox(
                                        width: UtilsReponsive.width(8, context)),
                                  if (controller.currentIndex.value <
                                      controller.onBoardingPages.length - 1)
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: UtilsReponsive.height(20, context),
                                    ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  SizedBox(height: UtilsReponsive.height(24, context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
