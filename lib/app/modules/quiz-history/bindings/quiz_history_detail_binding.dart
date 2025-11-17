import 'package:get/get.dart';
import '../controllers/quiz_history_detail_controller.dart';

class QuizHistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizHistoryDetailController>(
      () => QuizHistoryDetailController(),
    );
  }
}

