import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.primary,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/images/login.png',
            width: UtilsReponsive.width(200, context),
            height: UtilsReponsive.width(200, context),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.school,
                size: UtilsReponsive.width(120, context),
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }
}
