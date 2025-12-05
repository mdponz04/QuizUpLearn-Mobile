import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  late PageController pageController;
  var currentIndex = 0.obs;

  // Onboarding data for English learning app
  final List<OnBoardingModel> onBoardingPages = [
    OnBoardingModel(
      title: "Học qua Sách nói",
      description: "Nghe các câu chuyện tiếng Anh và cải thiện phát âm với sách nói tương tác của chúng tôi",
      image: "assets/images/AUDIO_BOOK.png",
    ),
    OnBoardingModel(
      title: "Học qua Sách điện tử",
      description: "Đọc những câu chuyện hấp dẫn và mở rộng vốn từ vựng với thư viện sách điện tử toàn diện",
      image: "assets/images/E_BOOK_LEARNING.png",
    ),
    OnBoardingModel(
      title: "Học trực tuyến",
      description: "Học tiếng Anh mọi lúc, mọi nơi với các bài học tương tác thân thiện trên điện thoại",
      image: "assets/images/ONLINE_LEARNING_ON_PHONE.png",
    ),
    OnBoardingModel(
      title: "Thi trực tuyến",
      description: "Kiểm tra kỹ năng tiếng Anh của bạn với các bài quiz toàn diện và theo dõi tiến độ",
      image: "assets/images/ONLINE_EXAM.png",
    ),
  ];

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentIndex.value < onBoardingPages.length - 1) {
      currentIndex.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Navigate to login screen
      Get.offAllNamed('/login');
    }
  }

  void previousPage() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void skipToEnd() {
    Get.offAllNamed('/login');
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}

class OnBoardingModel {
  final String title;
  final String description;
  final String image;

  OnBoardingModel({
    required this.title,
    required this.description,
    required this.image,
  });
}
