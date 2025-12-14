import 'dart:async';
import 'package:get/get.dart';
import 'package:quizkahoot/app/routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Đợi 2 giây để hiển thị splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    // Chuyển đến màn hình onboarding
    Get.offAllNamed(Routes.ON_BOARDING);
  }
}
