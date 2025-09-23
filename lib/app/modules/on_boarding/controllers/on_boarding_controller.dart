import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  late PageController pageController;
  var currentIndex = 0.obs;

  // Onboarding data for English learning app
  final List<OnBoardingModel> onBoardingPages = [
    OnBoardingModel(
      title: "Audio Book Learning",
      description: "Listen to English stories and improve your pronunciation with our interactive audio books",
      image: "assets/images/AUDIO_BOOK.png",
    ),
    OnBoardingModel(
      title: "E-Book Learning",
      description: "Read engaging stories and expand your vocabulary with our comprehensive e-book library",
      image: "assets/images/E_BOOK_LEARNING.png",
    ),
    OnBoardingModel(
      title: "Online Learning",
      description: "Learn English anytime, anywhere with our mobile-friendly interactive lessons",
      image: "assets/images/ONLINE_LEARNING_ON_PHONE.png",
    ),
    OnBoardingModel(
      title: "Online Exam",
      description: "Test your English skills with our comprehensive quizzes and track your progress",
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
